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

@implementation Group

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)name picture:(NSString *)picture members:(NSArray *)members completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FGROUP_USERID] = [FUser currentId];
	object[FGROUP_NAME] = name;
	object[FGROUP_PICTURE] = (picture != nil) ? picture : @"";
	object[FGROUP_MEMBERS] = members;
	object[FGROUP_ISDELETED] = @NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object saveInBackground:^(NSError *error)
	{
		if (error == nil) [self deployMembers:members];
		if (completion != nil) completion(error);
	}];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateName:(NSString *)groupId name:(NSString *)name completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FGROUP_OBJECTID] = groupId;
	object[FGROUP_NAME] = name;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object updateInBackground:^(NSError *error)
	{
		if (completion != nil) completion(error);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updatePicture:(NSString *)groupId picture:(NSString *)picture completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FGROUP_OBJECTID] = groupId;
	object[FGROUP_PICTURE] = picture;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object updateInBackground:^(NSError *error)
	{
		if (completion != nil) completion(error);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateMembers:(NSString *)groupId members:(NSArray *)members completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FGROUP_OBJECTID] = groupId;
	object[FGROUP_MEMBERS] = members;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object updateInBackground:^(NSError *error)
	{
		if (error == nil) [self deployMembers:members];
		if (completion != nil) completion(error);
	}];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deleteItem:(NSString *)groupId completion:(void (^)(NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FObject *object = [FObject objectWithPath:FGROUP_PATH];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	object[FGROUP_OBJECTID] = groupId;
	object[FGROUP_ISDELETED] = @YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[object updateInBackground:^(NSError *error)
	{
		if (completion != nil) completion(error);
	}];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)deployMembers:(NSArray *)members
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *currentId = [FUser currentId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *userId1 in members)
	{
		if ([userId1 isEqualToString:currentId] == NO)
		{
			for (NSString *userId2 in members)
			{
				if ([userId2 isEqualToString:userId1] == NO)
				{
					[LinkedId createItem:userId1 userId2:userId2];
				}
			}
		}
	}
}

@end
