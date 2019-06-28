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
@interface Groups()
{
	NSTimer *timer;
	BOOL refreshUIGroups;
	BOOL refreshUIChats;
	FIRDatabaseReference *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Groups

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (Groups *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static Groups *groups;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ groups = [[Groups alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groups;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_APP_STARTED];
	[NotificationCenter addObserver:self selector:@selector(initObservers) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refreshUserInterface) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FUser currentId] != nil)
	{
		if (firebase == nil) [self createObservers];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createObservers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	long long lastUpdatedAt = [DBGroup lastUpdatedAt];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase = [[FIRDatabase database] referenceWithPath:FGROUP_PATH];
	FIRDatabaseQuery *query = [[firebase queryOrderedByChild:FGROUP_UPDATEDAT] queryStartingAtValue:@(lastUpdatedAt+1)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *group = snapshot.value;
		if (group[FGROUP_CREATEDAT] != nil)
		{
			dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
				[self updateRealm:group];
				[self updateChat:group];
				refreshUIGroups = YES;
			});
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *group = snapshot.value;
		if (group[FGROUP_CREATEDAT] != nil)
		{
			dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
				[self updateRealm:group];
				[self updateChat:group];
				refreshUIGroups = YES;
			});
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateRealm:(NSDictionary *)group
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:group];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	temp[FGROUP_MEMBERS] = [group[FGROUP_MEMBERS] componentsJoinedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBGroup createOrUpdateInRealm:realm withValue:temp];
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateChat:(NSDictionary *)group
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BOOL isDeleted	= [group[FGROUP_ISDELETED] boolValue];
	BOOL isMember	= [group[FGROUP_MEMBERS] containsObject:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((isDeleted == YES) || (isMember == NO))
	{
		NSString *chatId = [Chat chatIdGroup:group[FGROUP_OBJECTID]];
		[Chat removeChat:chatId];
		refreshUIChats = YES;
	}
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase removeAllObservers]; firebase = nil;
}

#pragma mark - Notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshUserInterface
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (refreshUIGroups)
	{
		[NotificationCenter post:NOTIFICATION_REFRESH_GROUPS];
		refreshUIGroups = NO;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (refreshUIChats)
	{
		[NotificationCenter post:NOTIFICATION_REFRESH_CHATS];
		refreshUIChats = NO;
	}
}

@end
