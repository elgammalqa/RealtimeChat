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
@interface RelayManager()
{
	NSTimer *timer;
	BOOL inProgress;
	RLMResults *dbmessages;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RelayManager

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (RelayManager *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once;
	static RelayManager *relayManager;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ relayManager = [[RelayManager alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return relayManager;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(relayMessages) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	inProgress	= NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", TEXT_QUEUED];
	dbmessages = [[DBMessage objectsWithPredicate:predicate] sortedResultsUsingKeyPath:FMESSAGE_CREATEDAT ascending:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)relayMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FUser currentId] != nil)
	{
		if ([Connection isReachable])
		{
			if (inProgress == NO)
			{
				[self relayNextMessage];
			}
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)relayNextMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBMessage *dbmessage = [dbmessages firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbmessage != nil)
	{
		inProgress = YES;
		[MessageRelay send:dbmessage completion:^(NSError *error)
		{
			if (error == nil)
			{
				RLMRealm *realm = [RLMRealm defaultRealm];
				[realm beginWriteTransaction];
				dbmessage.status = TEXT_SENT;
				[realm commitWriteTransaction];
			}
			inProgress = NO;
		}];
	}
}

@end
