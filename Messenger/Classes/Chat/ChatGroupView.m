//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ChatGroupView.h"
#import "GroupView.h"
#import "ProfileView.h"
#import "PictureView.h"
#import "VideoView.h"
#import "MapView.h"
#import "AudioView.h"
#import "StickersView.h"
#import "SelectUsersView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatGroupView()
{
	NSString *groupId;
	NSString *chatId;

	RLMResults *dbmessages;
	NSMutableDictionary *rcmessages;
	NSMutableDictionary *avatarImages;
	NSMutableArray *avatarIds;

	NSInteger insertCounter;
	NSInteger typingCounter;
	long long lastRead;

	FIRDatabaseReference *firebase1;
	FIRDatabaseReference *firebase2;

	NSIndexPath *indexForward;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatGroupView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groupId = groupId_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	chatId = [Chat chatIdGroup:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationController.interactivePopGestureRecognizer.delegate = self;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_back"]
																		style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([FUser wallpaper] != nil)
		self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[FUser wallpaper]]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_CLEANUP_CHATVIEW];
	[NotificationCenter addObserver:self selector:@selector(refreshTableView1) name:NOTIFICATION_REFRESH_MESSAGES1];
	[NotificationCenter addObserver:self selector:@selector(refreshTableView2) name:NOTIFICATION_REFRESH_MESSAGES2];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	rcmessages = [[NSMutableDictionary alloc] init];
	avatarImages = [[NSMutableDictionary alloc] init];
	avatarIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	insertCounter = INSERT_MESSAGES;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadMessages];
	[self refreshTableView2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self typingIndicatorObserver];
	[self createLastReadObservers];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Messages assignChatId:chatId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Status updateLastRead:chatId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateTitleDetails];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self isMovingFromParentViewController])
	{
		[self actionCleanup];
	}
}

#pragma mark - Realm methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@ AND isDeleted == NO", chatId];
	dbmessages = [[DBMessage objectsWithPredicate:predicate] sortedResultsUsingKeyPath:FMESSAGE_CREATEDAT ascending:YES];
}

#pragma mark - DBMessage methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)index:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger count = MIN(insertCounter, [dbmessages count]);
	NSInteger offset = [dbmessages count] - count;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return (indexPath.section + offset);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (DBMessage *)dbmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger index = [self index:indexPath];
	return dbmessages[index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (DBMessage *)dbmessageAbove:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.section > 0)
	{
		NSIndexPath *indexAbove = [NSIndexPath indexPathForRow:0 inSection:indexPath.section-1];
		return [self dbmessage:indexAbove];
	}
	return nil;
}

#pragma mark - Message methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (RCMessage *)rcmessage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *messageId = dbmessage.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessages[messageId] == nil)
	{
		RCMessage *rcmessage;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		BOOL incoming = ([dbmessage.senderId isEqualToString:[FUser currentId]] == NO);
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_STATUS])
			rcmessage = [[RCMessage alloc] initWithStatus:dbmessage.text];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_TEXT])
			rcmessage = [[RCMessage alloc] initWithText:dbmessage.text incoming:incoming];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_EMOJI])
			rcmessage = [[RCMessage alloc] initWithEmoji:dbmessage.text incoming:incoming];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])
		{
			rcmessage = [[RCMessage alloc] initWithPicture:nil width:dbmessage.pictureWidth height:dbmessage.pictureHeight incoming:incoming];
			[MediaLoader loadPicture:rcmessage dbmessage:dbmessage tableView:self.tableView];
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])
		{
			rcmessage = [[RCMessage alloc] initWithVideo:nil durarion:dbmessage.videoDuration incoming:incoming];
			[MediaLoader loadVideo:rcmessage dbmessage:dbmessage tableView:self.tableView];
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])
		{
			rcmessage = [[RCMessage alloc] initWithAudio:nil durarion:dbmessage.audioDuration incoming:incoming];
			[MediaLoader loadAudio:rcmessage dbmessage:dbmessage tableView:self.tableView];
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([dbmessage.type isEqualToString:MESSAGE_LOCATION])
		{
			rcmessage = [[RCMessage alloc] initWithLatitude:dbmessage.latitude longitude:dbmessage.longitude incoming:incoming completion:^{
				[self.tableView reloadData];
			}];
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		rcmessages[messageId] = rcmessage;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return rcmessages[messageId];
}

#pragma mark - Avatar methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)avatarInitials:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	return dbmessage.senderInitials;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage *)avatarImage:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (avatarImages[dbmessage.senderId] == nil)
	{
		[self loadAvatarImage:dbmessage];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return avatarImages[dbmessage.senderId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatarImage:(DBMessage *)dbmessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId = dbmessage.senderId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([avatarIds containsObject:userId]) return;
	else [avatarIds addObject:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbmessage.senderPicture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			avatarImages[userId] = [[UIImage alloc] initWithContentsOfFile:path];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadData];
			});
		}
		else if (error.code != 100) [avatarIds removeObject:userId];
	}];
}

#pragma mark - Header, Footer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.section % 3 == 0)
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		NSDate *date = [NSDate dateWithTimestamp:dbmessage.createdAt];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd MMMM, HH:mm"];
		return [dateFormatter stringFromDate:date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [self rcmessage:indexPath];
	if (rcmessage.incoming)
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		DBMessage *dbmessageAbove = [self dbmessageAbove:indexPath];
		if (dbmessageAbove != nil)
		{
			if ([dbmessage.senderId isEqualToString:dbmessageAbove.senderId])
				return nil;
		}
		return dbmessage.senderName;
	}
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)textSectionFooter:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [self rcmessage:indexPath];
	if (rcmessage.outgoing)
	{
		DBMessage *dbmessage = [self dbmessage:indexPath];
		return (dbmessage.createdAt > lastRead) ? dbmessage.status : TEXT_READ;
	}
	return nil;
}

#pragma mark - Menu controller methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)menuItems:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMenuItem *menuItemCopy = [[RCMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionMenuCopy:)];
	RCMenuItem *menuItemSave = [[RCMenuItem alloc] initWithTitle:@"Save" action:@selector(actionMenuSave:)];
	RCMenuItem *menuItemDelete = [[RCMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionMenuDelete:)];
	RCMenuItem *menuItemForward = [[RCMenuItem alloc] initWithTitle:@"Forward" action:@selector(actionMenuForward:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	menuItemCopy.indexPath = indexPath;
	menuItemSave.indexPath = indexPath;
	menuItemDelete.indexPath = indexPath;
	menuItemForward.indexPath = indexPath;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *array = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_TEXT)		[array addObject:menuItemCopy];
	if (rcmessage.type == RC_TYPE_EMOJI)	[array addObject:menuItemCopy];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_PICTURE)	[array addObject:menuItemSave];
	if (rcmessage.type == RC_TYPE_VIDEO)	[array addObject:menuItemSave];
	if (rcmessage.type == RC_TYPE_AUDIO)	[array addObject:menuItemSave];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[array addObject:menuItemDelete];
	[array addObject:menuItemForward];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return array;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (action == @selector(actionMenuCopy:))		return YES;
	if (action == @selector(actionMenuSave:))		return YES;
	if (action == @selector(actionMenuDelete:))		return YES;
	if (action == @selector(actionMenuForward:))	return YES;
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

#pragma mark - Typing indicator methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorObserver
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	firebase1 = [[[FIRDatabase database] referenceWithPath:FTYPING_PATH] child:chatId];
	[firebase1 observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		if ([snapshot.key isEqualToString:[FUser currentId]] == NO)
		{
			BOOL typing = [snapshot.value boolValue];
			[self typingIndicatorShow:typing animated:YES];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorUpdate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter++;
	[self typingIndicatorSave:@YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^{ [self typingIndicatorStop]; });
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter--;
	if (typingCounter == 0) [self typingIndicatorSave:@NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorSave:(NSNumber *)typing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase1 updateChildValues:@{[FUser currentId]:typing}];
}

#pragma mark - LastRead methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createLastReadObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	firebase2 = [[[FIRDatabase database] referenceWithPath:FLASTREAD_PATH] child:chatId];
	[firebase2 observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
	{
		if (snapshot.exists)
		{
			NSDictionary *dictionary = snapshot.value;
			for (NSString *userId in [dictionary allKeys])
			{
				if ([userId isEqualToString:[FUser currentId]] == NO)
				{
					if ([dictionary[userId] longLongValue] > lastRead)
						lastRead = [dictionary[userId] longLongValue];
				}
			}
			[self.tableView reloadData];
		}
	}];
}

#pragma mark - Title details methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTitleDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", groupId];
	DBGroup *dbgroup = [[DBGroup objectsWithPredicate:predicate] firstObject];
	//-----------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = [dbgroup.members componentsSeparatedByString:@","];
	//-----------------------------------------------------------------------------------------------------------------------------------------
	self.labelTitle1.text = dbgroup.name;
	self.labelTitle2.text = [NSString stringWithFormat:@"%ld members", (long) [members count]];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView2];
	[self scrollToBottom:YES];
	[Status updateLastRead:chatId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BOOL show = insertCounter < [dbmessages count];
	[self loadEarlierShow:show];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - Message send methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageSend:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[MessageQueue send:chatId groupId:groupId status:nil text:text picture:picture video:video audio:audio];
}

#pragma mark - Message delete methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageDelete:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	[Message deleteItem:dbmessage];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTitle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	GroupView *groupView = [[GroupView alloc] initWith:groupId];
	[self.navigationController pushViewController:groupView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAttachMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIAlertAction *alertCamera	 = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { PresentMultiCamera(self, YES); }];
	UIAlertAction *alertPicture	 = [UIAlertAction actionWithTitle:@"Picture" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { PresentPhotoLibrary(self, YES); }];
	UIAlertAction *alertVideo	 = [UIAlertAction actionWithTitle:@"Video" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { PresentVideoLibrary(self, YES); }];
	UIAlertAction *alertAudio	 = [UIAlertAction actionWithTitle:@"Audio" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { [self actionAudio]; }];
	UIAlertAction *alertStickers = [UIAlertAction actionWithTitle:@"Sticker" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { [self actionStickers]; }];
	UIAlertAction *alertLocation = [UIAlertAction actionWithTitle:@"Location" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) { [self actionLocation]; }];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alertCamera setValue:[UIImage imageNamed:@"chat_camera"] forKey:@"image"];			[alert addAction:alertCamera];
	[alertPicture setValue:[UIImage imageNamed:@"chat_picture"] forKey:@"image"];		[alert addAction:alertPicture];
	[alertVideo setValue:[UIImage imageNamed:@"chat_video"] forKey:@"image"];			[alert addAction:alertVideo];
	[alertAudio setValue:[UIImage imageNamed:@"chat_audio"] forKey:@"image"];			[alert addAction:alertAudio];
	[alertStickers setValue:[UIImage imageNamed:@"chat_sticker"] forKey:@"image"];		[alert addAction:alertStickers];
	[alertLocation setValue:[UIImage imageNamed:@"chat_location"] forKey:@"image"];		[alert addAction:alertLocation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSendMessage:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:text picture:nil video:nil audio:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAudio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AudioView *audioView = [[AudioView alloc] init];
	audioView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:audioView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStickers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StickersView *stickersView = [[StickersView alloc] init];
	stickersView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:stickersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:nil picture:nil video:nil audio:nil];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self messageSend:nil picture:picture video:video audio:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AudioDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didRecordAudio:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:nil picture:nil video:nil audio:path];
}

#pragma mark - StickersDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSticker:(NSString *)sticker
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *picture = [UIImage imageNamed:sticker];
	[self messageSend:nil picture:picture video:nil audio:nil];
}

#pragma mark - User actions (load earlier)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLoadEarlier
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	insertCounter += INSERT_MESSAGES;
	[self refreshTableView2];
}

#pragma mark - User actions (bubble tap)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapBubble:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_STATUS)
	{

	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_PICTURE)
	{
		if (rcmessage.status == RC_STATUS_MANUAL)
		{
			[MediaLoader loadPictureManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
			[self.tableView reloadData];
		}
		if (rcmessage.status == RC_STATUS_SUCCEED)
		{
			PictureView *pictureView = [[PictureView alloc] initWith:dbmessage.objectId chatId:chatId];
			[self presentViewController:pictureView animated:YES completion:nil];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_VIDEO)
	{
		if (rcmessage.status == RC_STATUS_MANUAL)
		{
			[MediaLoader loadVideoManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
			[self.tableView reloadData];
		}
		if (rcmessage.status == RC_STATUS_SUCCEED)
		{
			NSURL *url = [NSURL fileURLWithPath:rcmessage.video_path];
			VideoView *videoView = [[VideoView alloc] initWith:url];
			[self presentViewController:videoView animated:YES completion:nil];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_AUDIO)
	{
		if (rcmessage.status == RC_STATUS_MANUAL)
		{
			[MediaLoader loadAudioManual:rcmessage dbmessage:dbmessage tableView:self.tableView];
			[self.tableView reloadData];
		}
		if (rcmessage.status == RC_STATUS_SUCCEED)
		{
			if (rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED)
			{
				Sound *sound = [Sound soundWithContentsOfFile:rcmessage.audio_path];
				sound.completionHandler = ^(BOOL didFinish) {
					if (didFinish) {
						rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
						[self.tableView reloadData];
					}
				};
				[[SoundManager sharedManager] playSound:sound];
				rcmessage.audio_status = RC_AUDIOSTATUS_PLAYING;
				[self.tableView reloadData];
			}
			else if (rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING)
			{
				[[SoundManager sharedManager] stopAllSounds:NO];
				rcmessage.audio_status = RC_AUDIOSTATUS_STOPPED;
				[self.tableView reloadData];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_LOCATION)
	{
		CLLocation *location = [[CLLocation alloc] initWithLatitude:rcmessage.latitude longitude:rcmessage.longitude];
		MapView *mapView = [[MapView alloc] initWith:location];
		NavigationController *navController = [[NavigationController alloc] initWithRootViewController:mapView];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

#pragma mark - User actions (avatar tap)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapAvatar:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexPath];
	NSString *senderId = dbmessage.senderId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([senderId isEqualToString:[FUser currentId]] == NO)
	{
		ProfileView *profileView = [[ProfileView alloc] initWith:senderId Chat:NO];
		[self.navigationController pushViewController:profileView animated:YES];
	}
}

#pragma mark - User actions (menu)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuCopy:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[UIPasteboard generalPasteboard] setString:rcmessage.text];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuSave:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
	RCMessage *rcmessage = [self rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_PICTURE)
	{
		if (rcmessage.status == RC_STATUS_SUCCEED)
			UIImageWriteToSavedPhotosAlbum(rcmessage.picture_image, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_VIDEO)
	{
		if (rcmessage.status == RC_STATUS_SUCCEED)
			UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.video_path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.type == RC_TYPE_AUDIO)
	{
		if (rcmessage.status == RC_STATUS_SUCCEED)
		{
			NSString *path = [File temp:@"mp4"];
			[File copy:rcmessage.audio_path dest:path overwrite:YES];
			UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuDelete:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSIndexPath *indexPath = [RCMenuItem indexPath:sender];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self messageDelete:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenuForward:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	indexForward = [RCMenuItem indexPath:sender];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SelectUsersView *selectUsersView = [[SelectUsersView alloc] init];
	selectUsersView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectUsersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (error != nil)
		[ProgressHUD showError:@"Saving failed."];
	else [ProgressHUD showSuccess:@"Successfully saved."];
}

#pragma mark - SelectUsersDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectUsers:(NSMutableArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [self dbmessage:indexForward];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBUser *dbuser in users)
	{
		NSString *recipientId = dbuser.objectId;
		NSString *chatId = [Chat chatIdPrivate:recipientId];
		[MessageQueue forward:chatId recipientId:recipientId dbmessage:dbmessage];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Audio playMessageOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	indexForward = nil;
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return MIN(insertCounter, [dbmessages count]);
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Messages resignChatId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self typingIndicatorSave:@NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[SoundManager sharedManager] stopAllSounds:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 removeAllObservers]; firebase1 = nil;
	[firebase2 removeAllObservers]; firebase2 = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter removeObserver:self];
}

@end
