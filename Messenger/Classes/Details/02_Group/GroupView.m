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

#import "GroupView.h"
#import "SelectUsersView.h"
#import "AllMediaView.h"
#import "ProfileView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupView()
{
	NSString *groupId;
	DBGroup *dbgroup;
	RLMResults *dbusers;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellDetails;
@property (strong, nonatomic) IBOutlet UIImageView *imageGroup;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLeave;

@property (strong, nonatomic) IBOutlet UIView *viewFooter;
@property (strong, nonatomic) IBOutlet UILabel *labelFooter1;
@property (strong, nonatomic) IBOutlet UILabel *labelFooter2;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupView

@synthesize cellDetails, imageGroup, labelName;
@synthesize cellMedia, cellLeave;
@synthesize viewFooter, labelFooter1, labelFooter2;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groupId = groupId_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"Group";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group_more"]
																	  style:UIBarButtonItemStylePlain target:self action:@selector(actionMore)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = viewFooter;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadGroup];
	[self loadUsers];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(loadGroup) name:NOTIFICATION_REFRESH_GROUPS];
	[NotificationCenter addObserver:self selector:@selector(loadUsers) name:NOTIFICATION_REFRESH_GROUPS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter removeObserver:self];
}

#pragma mark - Realm actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicateGroup = [NSPredicate predicateWithFormat:@"objectId == %@", groupId];
	dbgroup = [[DBGroup objectsWithPredicate:predicateGroup] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbgroup.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil) imageGroup.image = [[UIImage alloc] initWithContentsOfFile:path];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = dbgroup.name;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicateUser = [NSPredicate predicateWithFormat:@"objectId == %@", dbgroup.userId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicateUser] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelFooter1.text = [NSString stringWithFormat:@"Created by %@", dbuser.fullname];
	labelFooter2.text = Date2MediumTime([NSDate dateWithTimestamp:dbgroup.createdAt]);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSArray *members = [dbgroup.members componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", members];
	dbusers = [[DBUser objectsWithPredicate:predicate] sortedResultsUsingKeyPath:FUSER_FULLNAME ascending:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveGroupName:(NSString *)name
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Group updateName:groupId name:name completion:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveGroupPicture:(NSString *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Group updatePicture:groupId picture:picture completion:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - Backend actions (members)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addGroupMembers:(NSArray *)userIds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *members = [NSMutableArray arrayWithArray:[dbgroup.members componentsSeparatedByString:@","]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *userId in userIds)
	{
		if ([members containsObject:userId] == NO)
			[members addObject:userId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Group updateMembers:groupId members:members completion:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delGroupMember:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *members = [NSMutableArray arrayWithArray:[dbgroup.members componentsSeparatedByString:@","]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[members removeObject:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Group updateMembers:groupId members:members completion:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)leaveGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *members = [NSMutableArray arrayWithArray:[dbgroup.members componentsSeparatedByString:@","]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[members removeObject:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Group updateMembers:groupId members:members completion:^(NSError *error)
	{
		if (error == nil)
		{
			[ProgressHUD dismiss];
			[self.navigationController popToRootViewControllerAnimated:YES];
			[NotificationCenter post:NOTIFICATION_CLEANUP_CHATVIEW];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - Backend actions (delete)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Group deleteItem:groupId completion:^(NSError *error)
	{
		if (error == nil)
		{
			[ProgressHUD dismiss];
			[self.navigationController popToRootViewControllerAnimated:YES];
			[NotificationCenter post:NOTIFICATION_CLEANUP_CHATVIEW];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMore
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self isGroupOwner]) [self actionMoreOwner]; else [self actionMoreMember];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMoreOwner
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Add Members" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionAddMembers]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Rename Group" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionRenameGroup]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Change Picture" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionChangePicture]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Delete Group" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self deleteGroup]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMoreMember
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Leave Group" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self leaveGroup]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAddMembers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectUsersView *selectUsersView = [[SelectUsersView alloc] init];
	selectUsersView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectUsersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionRenameGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Group" message:@"Enter a new name for this Group"
															preferredStyle:UIAlertControllerStyleAlert];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
	{
		textField.text = dbgroup.name;
		textField.placeholder = @"Name";
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
	{
		UITextField *textField = alert.textFields[0];
		NSString *name = textField.text;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if ([name length] != 0) [self saveGroupName:name];
		else [ProgressHUD showError:@"Group name must be specified."];
	}]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChangePicture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Open Camera" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { PresentPhotoCamera(self, YES); }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { PresentPhotoLibrary(self, YES); }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *chatId = [Chat chatIdGroup:groupId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AllMediaView *allMediaView = [[AllMediaView alloc] initWith:chatId];
	[self.navigationController pushViewController:allMediaView animated:YES];
}

#pragma mark - SelectUsersDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectUsers:(NSMutableArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *userIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBUser *dbuser in users)
	{
		[userIds addObject:dbuser.objectId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self addGroupMembers:userIds];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *squared = [Image square:image size:100];
	NSData *data = UIImageJPEGRepresentation(squared, 0.6);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UploadManager upload:data name:@"group" ext:@"jpg" progress:^(float progress)
	{
		hud.progress = progress;
	}
	completion:^(NSString *link, NSError *error)
	{
		[hud hideAnimated:YES];
		if (error == nil)
		{
			[DownloadManager saveImage:data link:link];
			[self saveGroupPicture:link];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 1;
	if (section == 1) return 1;
	if (section == 2) return [dbusers count];
	if (section == 3) return [self isGroupOwner] ? 0 : 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return nil;
	if (section == 1) return nil;
	if (section == 2) return [self titleForHeaderMembers];
	if (section == 3) return nil;
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellDetails;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellMedia;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 2)
	{
		return [self tableView:tableView cellForRowAtIndexPath2:indexPath];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 3) && (indexPath.row == 0)) return cellLeave;
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath2:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBUser *dbuser = dbusers[indexPath.row];
	cell.textLabel.text = dbuser.fullname;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.section == 2)
	{
		if ([self isGroupOwner])
		{
			DBUser *dbuser = dbusers[indexPath.row];
			return ([dbuser.objectId isEqualToString:[FUser currentId]] == NO);
		}
		else return NO;
	}
	else return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBUser *dbuser = dbusers[indexPath.row];
	[self delGroupMember:dbuser.objectId];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionMedia];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 2)
	{
		DBUser *dbuser = dbusers[indexPath.row];
		if ([dbuser.objectId isEqualToString:[FUser currentId]] == NO)
		{
			ProfileView *profileView = [[ProfileView alloc] initWith:dbuser.objectId Chat:YES];
			[self.navigationController pushViewController:profileView animated:YES];
		}
		else [ProgressHUD showSuccess:@"This is you."];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 3) && (indexPath.row == 0)) [self actionMoreMember];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)titleForHeaderMembers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = ([dbusers count] > 1) ? @"MEMBERS" : @"MEMBER";
	return [NSString stringWithFormat:@"%ld %@", (long) [dbusers count], text];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isGroupOwner
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [dbgroup.userId isEqualToString:[FUser currentId]];
}

@end
