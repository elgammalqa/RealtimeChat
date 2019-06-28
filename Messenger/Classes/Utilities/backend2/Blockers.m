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
@interface Blockers()
{
	NSTimer *timer;
	BOOL refreshUIBlockers;
	FIRDatabaseReference *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Blockers

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (Blockers *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static Blockers *blockers;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ blockers = [[Blockers alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return blockers;
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
	long long lastUpdatedAt = [DBBlocker lastUpdatedAt];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase = [[[FIRDatabase database] referenceWithPath:FBLOCKER_PATH] child:[FUser currentId]];
	FIRDatabaseQuery *query = [[firebase queryOrderedByChild:FBLOCKER_UPDATEDAT] queryStartingAtValue:@(lastUpdatedAt+1)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *blocker = snapshot.value;
		if (blocker[FBLOCKER_CREATEDAT] != nil)
		{
			dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
				[self updateRealm:blocker];
				refreshUIBlockers = YES;
			});
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot)
	{
		NSDictionary *blocker = snapshot.value;
		if (blocker[FBLOCKER_CREATEDAT] != nil)
		{
			dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL), ^{
				[self updateRealm:blocker];
				refreshUIBlockers = YES;
			});
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateRealm:(NSDictionary *)blocker
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	[DBBlocker createOrUpdateInRealm:realm withValue:blocker];
	[realm commitWriteTransaction];
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
	if (refreshUIBlockers)
	{
		[NotificationCenter post:NOTIFICATION_REFRESH_BLOCKERS];
		refreshUIBlockers = NO;
	}
}

@end
