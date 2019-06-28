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

@implementation UserStatus

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItems
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self createItem:@"Available"];
	[self createItem:@"Busy"];
	[self createItem:@"At school"];
	[self createItem:@"At the movies"];
	[self createItem:@"At work"];
	[self createItem:@"Battery about to die"];
	[self createItem:@"Can't talk now"];
	[self createItem:@"In a meeting"];
	[self createItem:@"At the gym"];
	[self createItem:@"Sleeping"];
	[self createItem:@"Urgent calls only"];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)name
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FUSERSTATUS_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FUSERSTATUS_NAME] = name;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object saveInBackground:^(NSError *error)
	{
		if (error != nil) NSLog(@"UserStatus createItem error: %@", error);
	}];
}

@end
