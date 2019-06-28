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

@implementation LinkedId

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId1 = [FUser currentId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase = [[[[FIRDatabase database] referenceWithPath:FUSER_PATH] child:userId1] child:FUSER_LINKEDIDS];
	[firebase updateChildValues:@{userId1:@YES}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId1 = [FUser currentId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase1 = [[[[FIRDatabase database] referenceWithPath:FUSER_PATH] child:userId1] child:FUSER_LINKEDIDS];
	[firebase1 updateChildValues:@{userId2:@YES}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[[FIRDatabase database] referenceWithPath:FUSER_PATH] child:userId2] child:FUSER_LINKEDIDS];
	[firebase2 updateChildValues:@{userId1:@YES}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId1 userId2:(NSString *)userId2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FIRDatabaseReference *firebase1 = [[[[FIRDatabase database] referenceWithPath:FUSER_PATH] child:userId1] child:FUSER_LINKEDIDS];
	[firebase1 updateChildValues:@{userId2:@YES}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[[FIRDatabase database] referenceWithPath:FUSER_PATH] child:userId2] child:FUSER_LINKEDIDS];
	[firebase2 updateChildValues:@{userId1:@YES}];
}

@end
