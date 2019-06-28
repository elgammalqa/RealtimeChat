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

#import "MessageRelay.h"

@implementation MessageRelay

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)send:(DBMessage *)dbmessage completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *message = [FObject objectWithPath:FMESSAGE_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_OBJECTID] = dbmessage.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CHATID] = dbmessage.chatId;
	message[FMESSAGE_MEMBERS] = [dbmessage.members componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_SENDERID] = dbmessage.senderId;
	message[FMESSAGE_SENDERNAME] = dbmessage.senderName;
	message[FMESSAGE_SENDERINITIALS] = dbmessage.senderInitials;
	message[FMESSAGE_SENDERPICTURE] = dbmessage.senderPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_RECIPIENTID] = dbmessage.recipientId;
	message[FMESSAGE_RECIPIENTNAME] = dbmessage.recipientName;
	message[FMESSAGE_RECIPIENTINITIALS] = dbmessage.recipientInitials;
	message[FMESSAGE_RECIPIENTPICTURE] = dbmessage.recipientPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_GROUPID] = dbmessage.groupId;
	message[FMESSAGE_GROUPNAME] = dbmessage.groupName;
	message[FMESSAGE_GROUPPICTURE] = dbmessage.groupPicture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_TYPE] = dbmessage.type;
	message[FMESSAGE_TEXT] = [Cryptor encryptText:dbmessage.text chatId:dbmessage.chatId];
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
	message[FMESSAGE_STATUS] = TEXT_SENT;
	message[FMESSAGE_ISDELETED] = @(dbmessage.isDeleted);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	message[FMESSAGE_CREATEDAT] = @(dbmessage.createdAt);
	message[FMESSAGE_UPDATEDAT] = @(dbmessage.updatedAt);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.type isEqualToString:MESSAGE_TEXT])		[self sendMessage:message completion:completion];
	if ([dbmessage.type isEqualToString:MESSAGE_EMOJI])		[self sendMessage:message completion:completion];
	if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])	[self sendPictureMessage:message completion:completion];
	if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])		[self sendVideoMessage:message completion:completion];
	if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])		[self sendAudioMessage:message completion:completion];
	if ([dbmessage.type isEqualToString:MESSAGE_LOCATION])	[self sendMessage:message completion:completion];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendPictureMessage:(FObject *)message completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *chatId = message[FMESSAGE_CHATID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *link = message[FMESSAGE_PICTURE];
	NSString *path = [DownloadManager pathImage:link];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataPicture = [NSData dataWithContentsOfFile:path];
	NSData *cryptedPicture = [Cryptor encryptData:dataPicture chatId:chatId];
	NSString *md5Picture = [Checksum md5HashOfData:cryptedPicture];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UploadManager upload:cryptedPicture name:@"message_image" ext:@"jpg" progress:nil completion:^(NSString *link, NSError *error)
	{
		if (error == nil)
		{
			[DownloadManager saveImage:dataPicture link:link];
			message[FMESSAGE_PICTURE] = link;
			message[FMESSAGE_PICTUREMD5] = md5Picture;
			[self sendMessage:message completion:completion];
		}
		else if (completion != nil) completion([NSError description:@"Media upload error." code:100]);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendVideoMessage:(FObject *)message completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *chatId = message[FMESSAGE_CHATID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *link = message[FMESSAGE_VIDEO];
	NSString *path = [DownloadManager pathVideo:link];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataVideo = [NSData dataWithContentsOfFile:path];
	NSData *cryptedVideo = [Cryptor encryptData:dataVideo chatId:chatId];
	NSString *md5Video = [Checksum md5HashOfData:cryptedVideo];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UploadManager upload:cryptedVideo name:@"message_video" ext:@"mp4" progress:nil completion:^(NSString *link, NSError *error)
	{
		if (error == nil)
		{
			[DownloadManager saveVideo:dataVideo link:link];
			message[FMESSAGE_VIDEO] = link;
			message[FMESSAGE_VIDEOMD5] = md5Video;
			[self sendMessage:message completion:completion];
		}
		else if (completion != nil) completion([NSError description:@"Media upload error." code:100]);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendAudioMessage:(FObject *)message completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *chatId = message[FMESSAGE_CHATID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *link = message[FMESSAGE_AUDIO];
	NSString *path = [DownloadManager pathAudio:link];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataAudio = [NSData dataWithContentsOfFile:path];
	NSData *cryptedAudio = [Cryptor encryptData:dataAudio chatId:chatId];
	NSString *md5Audio = [Checksum md5HashOfData:cryptedAudio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UploadManager upload:cryptedAudio name:@"message_audio" ext:@"m4a" progress:nil completion:^(NSString *link, NSError *error)
	{
		if (error == nil)
		{
			[DownloadManager saveAudio:dataAudio link:link];
			message[FMESSAGE_AUDIO] = link;
			message[FMESSAGE_AUDIOMD5] = md5Audio;
			[self sendMessage:message completion:completion];
		}
		else if (completion != nil) completion([NSError description:@"Media upload error." code:100]);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)sendMessage:(FObject *)message completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *multiple = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *userId in message[FMESSAGE_MEMBERS])
	{
		NSString *path = [NSString stringWithFormat:@"%@/%@", userId, [message objectId]];
		multiple[path] = message.dictionary;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *reference = [[FIRDatabase database] referenceWithPath:FMESSAGE_PATH];
	[reference updateChildValues:multiple withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref)
	{
		if (error == nil)
		{
			SendPushNotification1(message);
			if (completion != nil) completion(nil);
		}
		else if (completion != nil) completion([NSError description:@"Message sending failed." code:101]);
	}];
}

@end
