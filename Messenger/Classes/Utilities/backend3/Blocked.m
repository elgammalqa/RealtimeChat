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

@implementation Blocked

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FBLOCKED_PATH Subpath:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FBLOCKED_OBJECTID] = userId;
	object[FBLOCKED_BLOCKEDID] = userId;
	object[FBLOCKED_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object saveInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FBLOCKED_PATH Subpath:[FUser currentId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FBLOCKED_OBJECTID] = userId;
	object[FBLOCKED_ISDELETED] = @YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object updateInBackground:^(NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)isBlocked:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blockedId == %@ AND isDeleted == NO", userId];
	DBBlocked *dbblocked = [[DBBlocked objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return (dbblocked != nil);
}

@end
