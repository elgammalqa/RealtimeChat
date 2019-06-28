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

#import "MessageQueue.h"

@implementation MessageQueue

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)send:(NSString *)chatId recipientId:(NSString *)recipientId
	  status:(NSString *)status text:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", recipientId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *senderPicture		= ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	NSString *recipientPicture	= (dbuser.thumbnail != nil) ? dbuser.thumbnail : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[message objectIdInit];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CHATID] = chatId;
	message[FMESSAGE_MEMBERS] = @[[FUser currentId], recipientId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_SENDERID] = [FUser currentId];
	message[FMESSAGE_SENDERNAME] = [FUser fullname];
	message[FMESSAGE_SENDERINITIALS] = [FUser initials];
	message[FMESSAGE_SENDERPICTURE] = senderPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_RECIPIENTID] = recipientId;
	message[FMESSAGE_RECIPIENTNAME] = dbuser.fullname;
	message[FMESSAGE_RECIPIENTINITIALS] = [dbuser initials];
	message[FMESSAGE_RECIPIENTPICTURE] = recipientPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = @"";
	message[FMESSAGE_GROUPNAME] = @"";
	message[FMESSAGE_GROUPPICTURE] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_TYPE] = @"";
	message[FMESSAGE_TEXT] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = @"";
	message[FMESSAGE_PICTUREWIDTH] = @0;
	message[FMESSAGE_PICTUREHEIGHT] = @0;
	message[FMESSAGE_PICTUREMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = @"";
	message[FMESSAGE_VIDEODURATION] = @0;
	message[FMESSAGE_VIDEOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = @"";
	message[FMESSAGE_AUDIODURATION] = @0;
	message[FMESSAGE_AUDIOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @0;
	message[FMESSAGE_LONGITUDE] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_STATUS] = TEXT_QUEUED;
	message[FMESSAGE_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	long long timestamp = [[NSDate date] timestamp];
	message[FMESSAGE_CREATEDAT] = @(timestamp);
	message[FMESSAGE_UPDATEDAT] = @(timestamp);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (status != nil)			[self sendStatusMessage:message status:status];
	else if (text != nil)		[self sendTextMessage:message text:text];
	else if (picture != nil)	[self sendPictureMessage:message picture:picture];
	else if (video != nil)		[self sendVideoMessage:message video:video];
	else if (audio != nil)		[self sendAudioMessage:message audio:audio];
	else						[self sendLoactionMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)send:(NSString *)chatId groupId:(NSString *)groupId
	  status:(NSString *)status text:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", groupId];
	DBGroup *dbgroup = [[DBGroup objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *senderPicture	= ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	NSString *groupPicture	= (dbgroup.picture != nil) ? dbgroup.picture : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[message objectIdInit];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CHATID] = chatId;
	message[FMESSAGE_MEMBERS] = [dbgroup.members componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_SENDERID] = [FUser currentId];
	message[FMESSAGE_SENDERNAME] = [FUser fullname];
	message[FMESSAGE_SENDERINITIALS] = [FUser initials];
	message[FMESSAGE_SENDERPICTURE] = senderPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_RECIPIENTID] = @"";
	message[FMESSAGE_RECIPIENTNAME] = @"";
	message[FMESSAGE_RECIPIENTINITIALS] = @"";
	message[FMESSAGE_RECIPIENTPICTURE] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = groupId;
	message[FMESSAGE_GROUPNAME] = dbgroup.name;
	message[FMESSAGE_GROUPPICTURE] = groupPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_TYPE] = @"";
	message[FMESSAGE_TEXT] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = @"";
	message[FMESSAGE_PICTUREWIDTH] = @0;
	message[FMESSAGE_PICTUREHEIGHT] = @0;
	message[FMESSAGE_PICTUREMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = @"";
	message[FMESSAGE_VIDEODURATION] = @0;
	message[FMESSAGE_VIDEOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = @"";
	message[FMESSAGE_AUDIODURATION] = @0;
	message[FMESSAGE_AUDIOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @0;
	message[FMESSAGE_LONGITUDE] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_STATUS] = TEXT_QUEUED;
	message[FMESSAGE_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	long long timestamp = [[NSDate date] timestamp];
	message[FMESSAGE_CREATEDAT] = @(timestamp);
	message[FMESSAGE_UPDATEDAT] = @(timestamp);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (status != nil)			[self sendStatusMessage:message status:status];
	else if (text != nil)		[self sendTextMessage:message text:text];
	else if (picture != nil)	[self sendPictureMessage:message picture:picture];
	else if (video != nil)		[self sendVideoMessage:message video:video];
	else if (audio != nil)		[self sendAudioMessage:message audio:audio];
	else						[self sendLoactionMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)forward:(NSString *)chatId recipientId:(NSString *)recipientId dbmessage:(DBMessage *)dbmessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", recipientId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *senderPicture		= ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	NSString *recipientPicture	= (dbuser.thumbnail != nil) ? dbuser.thumbnail : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[message objectIdInit];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CHATID] = chatId;
	message[FMESSAGE_MEMBERS] = @[[FUser currentId], recipientId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_SENDERID] = [FUser currentId];
	message[FMESSAGE_SENDERNAME] = [FUser fullname];
	message[FMESSAGE_SENDERINITIALS] = [FUser initials];
	message[FMESSAGE_SENDERPICTURE] = senderPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_RECIPIENTID] = recipientId;
	message[FMESSAGE_RECIPIENTNAME] = dbuser.fullname;
	message[FMESSAGE_RECIPIENTINITIALS] = [dbuser initials];
	message[FMESSAGE_RECIPIENTPICTURE] = recipientPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = @"";
	message[FMESSAGE_GROUPNAME] = @"";
	message[FMESSAGE_GROUPPICTURE] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_TYPE] = dbmessage.type;
	message[FMESSAGE_TEXT] = dbmessage.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = dbmessage.picture;
	message[FMESSAGE_PICTUREWIDTH] = @(dbmessage.pictureWidth);
	message[FMESSAGE_PICTUREHEIGHT] = @(dbmessage.pictureHeight);
	message[FMESSAGE_PICTUREMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = dbmessage.video;
	message[FMESSAGE_VIDEODURATION] = @(dbmessage.videoDuration);
	message[FMESSAGE_VIDEOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = dbmessage.audio;
	message[FMESSAGE_AUDIODURATION] = @(dbmessage.audioDuration);
	message[FMESSAGE_AUDIOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @(dbmessage.latitude);
	message[FMESSAGE_LONGITUDE] = @(dbmessage.longitude);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_STATUS] = TEXT_QUEUED;
	message[FMESSAGE_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	long long timestamp = [[NSDate date] timestamp];
	message[FMESSAGE_CREATEDAT] = @(timestamp);
	message[FMESSAGE_UPDATEDAT] = @(timestamp);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)forward:(NSString *)chatId groupId:(NSString *)groupId dbmessage:(DBMessage *)dbmessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", groupId];
	DBGroup *dbgroup = [[DBGroup objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *senderPicture	= ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	NSString *groupPicture	= (dbgroup.picture != nil) ? dbgroup.picture : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[message objectIdInit];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CHATID] = chatId;
	message[FMESSAGE_MEMBERS] = [dbgroup.members componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_SENDERID] = [FUser currentId];
	message[FMESSAGE_SENDERNAME] = [FUser fullname];
	message[FMESSAGE_SENDERINITIALS] = [FUser initials];
	message[FMESSAGE_SENDERPICTURE] = senderPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_RECIPIENTID] = @"";
	message[FMESSAGE_RECIPIENTNAME] = @"";
	message[FMESSAGE_RECIPIENTINITIALS] = @"";
	message[FMESSAGE_RECIPIENTPICTURE] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = groupId;
	message[FMESSAGE_GROUPNAME] = dbgroup.name;
	message[FMESSAGE_GROUPPICTURE] = groupPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_TYPE] = dbmessage.type;
	message[FMESSAGE_TEXT] = dbmessage.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = dbmessage.picture;
	message[FMESSAGE_PICTUREWIDTH] = @(dbmessage.pictureWidth);
	message[FMESSAGE_PICTUREHEIGHT] = @(dbmessage.pictureHeight);
	message[FMESSAGE_PICTUREMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = dbmessage.video;
	message[FMESSAGE_VIDEODURATION] = @(dbmessage.videoDuration);
	message[FMESSAGE_VIDEOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = dbmessage.audio;
	message[FMESSAGE_AUDIODURATION] = @(dbmessage.audioDuration);
	message[FMESSAGE_AUDIOMD5] = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @(dbmessage.latitude);
	message[FMESSAGE_LONGITUDE] = @(dbmessage.longitude);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_STATUS] = TEXT_QUEUED;
	message[FMESSAGE_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	long long timestamp = [[NSDate date] timestamp];
	message[FMESSAGE_CREATEDAT] = @(timestamp);
	message[FMESSAGE_UPDATEDAT] = @(timestamp);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendStatusMessage:(FObject *)message status:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = MESSAGE_STATUS;
	message[FMESSAGE_TEXT] = status;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendTextMessage:(FObject *)message text:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = [Emoji isEmoji:text] ? MESSAGE_EMOJI : MESSAGE_TEXT;
	message[FMESSAGE_TEXT] = text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendPictureMessage:(FObject *)message picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = MESSAGE_PICTURE;
	message[FMESSAGE_TEXT] = @"[Picture message]";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataPicture = UIImageJPEGRepresentation(picture, 0.6);
	[DownloadManager saveImage:dataPicture link:[message objectId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_PICTURE] = [message objectId];
	message[FMESSAGE_PICTUREWIDTH] = @((NSInteger) picture.size.width);
	message[FMESSAGE_PICTUREHEIGHT] = @((NSInteger) picture.size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendVideoMessage:(FObject *)message video:(NSURL *)video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = MESSAGE_VIDEO;
	message[FMESSAGE_TEXT] = @"[Video message]";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataVideo = [NSData dataWithContentsOfFile:video.path];
	[DownloadManager saveVideo:dataVideo link:[message objectId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_VIDEO] = [message objectId];
	message[FMESSAGE_VIDEODURATION] = [Video duration:video.path];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendAudioMessage:(FObject *)message audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = MESSAGE_AUDIO;
	message[FMESSAGE_TEXT] = @"[Audio message]";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataAudio = [NSData dataWithContentsOfFile:audio];
	[DownloadManager saveAudio:dataAudio link:[message objectId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_AUDIO] = [message objectId];
	message[FMESSAGE_AUDIODURATION] = [Audio duration:audio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendLoactionMessage:(FObject *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	message[FMESSAGE_TYPE] = MESSAGE_LOCATION;
	message[FMESSAGE_TEXT] = @"[Location message]";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_LATITUDE] = @([Location latitude]);
	message[FMESSAGE_LONGITUDE] = @([Location longitude]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self createMessage:message];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createMessage:(FObject *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self updateRealm:message.dictionary];
	[self updateChat:message.dictionary];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter post:NOTIFICATION_REFRESH_MESSAGES1];
	[NotificationCenter post:NOTIFICATION_REFRESH_CHATS];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self playMessageOutgoing:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateRealm:(NSDictionary *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:message];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	temp[FMESSAGE_MEMBERS] = [message[FMESSAGE_MEMBERS] componentsJoinedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBMessage createOrUpdateInRealm:realm withValue:temp];
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateChat:(NSDictionary *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Chat updateChat:message[FMESSAGE_CHATID]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)playMessageOutgoing:(FObject *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([message[FMESSAGE_TYPE] isEqualToString:MESSAGE_STATUS] == NO)
	{
		[Audio playMessageOutgoing];
	}
}

@end
