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
 
@implementation Shortcut

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)create
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([[[UIApplication sharedApplication] shortcutItems] count] == 0)
	{
		NSMutableArray *items = [[NSMutableArray alloc] init];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[items addObject:[self createItem:@"newchat" title:@"New Chat" iconType:UIApplicationShortcutIconTypeCompose userInfo:nil]];
		[items addObject:[self createItem:@"newgroup" title:@"New Group" iconType:UIApplicationShortcutIconTypeAdd userInfo:nil]];
		[items addObject:[self createItem:@"shareapp" title:@"Share Chat" iconType:UIApplicationShortcutIconTypeShare userInfo:nil]];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[UIApplication sharedApplication] setShortcutItems:items];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)update:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *items = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", userId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *fullname = dbuser.fullname;
	NSDictionary *userInfo = @{@"userId":dbuser.objectId};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[items addObject:[self createItem:@"newchat" title:@"New Chat" iconType:UIApplicationShortcutIconTypeCompose userInfo:nil]];
	[items addObject:[self createItem:@"newgroup" title:@"New Group" iconType:UIApplicationShortcutIconTypeAdd userInfo:nil]];
	[items addObject:[self createItem:@"recentuser" title:fullname iconType:UIApplicationShortcutIconTypeContact userInfo:userInfo]];
	[items addObject:[self createItem:@"shareapp" title:@"Share Chat" iconType:UIApplicationShortcutIconTypeShare userInfo:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[UIApplication sharedApplication] setShortcutItems:items];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (UIApplicationShortcutItem *)createItem:(NSString *)type title:(NSString *)title iconType:(UIApplicationShortcutIconType)iconType
								 userInfo:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:iconType];
	return [[UIApplicationShortcutItem alloc] initWithType:type localizedTitle:title localizedSubtitle:nil icon:icon userInfo:userInfo];
}

@end
