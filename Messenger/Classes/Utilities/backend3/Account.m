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

@implementation Account

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)add:(NSString *)email password:(NSString *)password
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *accounts = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults objectForKey:USER_ACCOUNTS]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *userId = [FUser currentId];
	NSString *fullname = ([FUser fullname] != nil) ? [FUser fullname] : @"";
	NSString *initials = ([FUser initials] != nil) ? [FUser initials] : @"";
	NSString *picture = ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	accounts[userId] = @{@"email":email, @"password":password, @"fullname":fullname, @"initials":initials, @"picture":picture};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UserDefaults setObject:accounts forKey:USER_ACCOUNTS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)update
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([[FUser loginMethod] isEqualToString:LOGIN_EMAIL] == NO) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableDictionary *accounts = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults objectForKey:USER_ACCOUNTS]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *userId = [FUser currentId];
	NSString *fullname = ([FUser fullname] != nil) ? [FUser fullname] : @"";
	NSString *initials = ([FUser initials] != nil) ? [FUser initials] : @"";
	NSString *picture = ([FUser thumbnail] != nil) ? [FUser thumbnail] : @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *account = accounts[userId];
	NSString *email = account[@"email"];
	NSString *password = account[@"password"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	accounts[userId] = @{@"email":email, @"password":password, @"fullname":fullname, @"initials":initials, @"picture":picture};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UserDefaults setObject:accounts forKey:USER_ACCOUNTS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)delOne
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *accounts = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults objectForKey:USER_ACCOUNTS]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[accounts removeObjectForKey:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UserDefaults setObject:accounts forKey:USER_ACCOUNTS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)delAll
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[UserDefaults removeObjectForKey:USER_ACCOUNTS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSInteger)count
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *accounts = [UserDefaults objectForKey:USER_ACCOUNTS];
	return [accounts count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSArray *)userIds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *accounts = [UserDefaults objectForKey:USER_ACCOUNTS];
	return [[accounts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDictionary *)account:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *accounts = [UserDefaults objectForKey:USER_ACCOUNTS];
	return accounts[userId];
}

@end
