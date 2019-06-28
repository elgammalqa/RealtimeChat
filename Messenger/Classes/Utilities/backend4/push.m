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

#import "utilities.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification1(FObject *message)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *type = message[FMESSAGE_TYPE];
	NSString *text = message[FMESSAGE_SENDERNAME];
	NSString *chatId = message[FMESSAGE_CHATID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([type isEqualToString:MESSAGE_TEXT])		text = [text stringByAppendingString:@" sent you a text message."];
	if ([type isEqualToString:MESSAGE_EMOJI])		text = [text stringByAppendingString:@" sent you an emoji."];
	if ([type isEqualToString:MESSAGE_PICTURE])		text = [text stringByAppendingString:@" sent you a picture."];
	if ([type isEqualToString:MESSAGE_VIDEO])		text = [text stringByAppendingString:@" sent you a video."];
	if ([type isEqualToString:MESSAGE_AUDIO])		text = [text stringByAppendingString:@" sent you an audio."];
	if ([type isEqualToString:MESSAGE_LOCATION])	text = [text stringByAppendingString:@" sent you a location."];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase = [[[FIRDatabase database] referenceWithPath:FMUTEDUNTIL_PATH] child:chatId];
	[firebase observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSMutableArray *userIds = [NSMutableArray arrayWithArray:message[FMESSAGE_MEMBERS]];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (snapshot.exists)
		{
			NSDictionary *mutedUntil = snapshot.value;
			for (NSString *userId in message[FMESSAGE_MEMBERS])
			{
				if ([mutedUntil[userId] longLongValue] > [[NSDate date] timestamp])
					[userIds removeObject:userId];
			}
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[userIds removeObject:[FUser currentId]];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		SendPushNotification2(userIds, text);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification2(NSArray *userIds, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBUser *dbuser in [DBUser allObjects])
	{
		if ([userIds containsObject:dbuser.objectId])
		{
			if ([dbuser.oneSignalId length] != 0)
				[oneSignalIds addObject:dbuser.oneSignalId];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal postNotification:@{@"contents":@{@"en":text}, @"include_player_ids":oneSignalIds}];
}
