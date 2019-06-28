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

@implementation Chat

#pragma mark - Update methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateChat:(NSString *)chatId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@ AND isDeleted == NO", chatId];
	DBMessage *dbmessage = [[[DBMessage objectsWithPredicate:predicate] sortedResultsUsingKeyPath:FMESSAGE_CREATEDAT ascending:YES] lastObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbmessage != nil) [self updateItem:dbmessage];
	if (dbmessage == nil) [self removeChat:chatId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)removeChat:(NSString *)chatId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@", chatId];
	DBChat *dbchat = [[DBChat objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbchat != nil) [self deleteItem:dbchat];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateItem:(DBMessage *)dbmessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBChat *dbchat = [self fetchOrCreateItem:dbmessage.chatId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	BOOL outgoing = [dbmessage.senderId isEqualToString:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.recipientId length] != 0)
	{
		dbchat.groupId		= @"";
		dbchat.recipientId	= outgoing ? dbmessage.recipientId		 : dbmessage.senderId;
		dbchat.initials		= outgoing ? dbmessage.recipientInitials : dbmessage.senderInitials;
		dbchat.picture		= outgoing ? dbmessage.recipientPicture	 : dbmessage.senderPicture;
		dbchat.details		= outgoing ? dbmessage.recipientName	 : dbmessage.senderName;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([dbmessage.groupId length] != 0)
	{
		dbchat.recipientId	= @"";
		dbchat.groupId		= dbmessage.groupId;
		dbchat.initials		= @"";
		dbchat.picture		= dbmessage.groupPicture;
		dbchat.details		= dbmessage.groupName;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dbchat.lastMessage = dbmessage.text;
	dbchat.lastMessageDate = dbmessage.createdAt;
	if (outgoing == NO) dbchat.lastIncoming = dbmessage.createdAt;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dbchat.isArchived = NO;
	dbchat.isDeleted = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dbchat.createdAt = [[NSDate date] timestamp];
	dbchat.updatedAt = [[NSDate date] timestamp];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[realm addOrUpdateObject:dbchat];
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (DBChat *)fetchOrCreateItem:(NSString *)chatId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@", chatId];
	DBChat *dbchat = [[DBChat objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbchat == nil)
	{
		dbchat = [[DBChat alloc] init];
		dbchat.chatId = chatId;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return dbchat;
}

#pragma mark - Delete, Archive methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(DBChat *)dbchat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbchat.isDeleted = YES;
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)archiveItem:(DBChat *)dbchat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbchat.isArchived = YES;
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)unarchiveItem:(DBChat *)dbchat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbchat.isArchived = NO;
	[realm commitWriteTransaction];
}

#pragma mark - ChatId methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)chatIdPrivate:(NSString *)recipientId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *currentId = [FUser currentId];
	NSArray *members = @[currentId, recipientId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [members sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	return [Checksum md5HashOfString:[sorted componentsJoinedByString:@""]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)chatIdGroup:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [Checksum md5HashOfString:groupId];
}

@end
