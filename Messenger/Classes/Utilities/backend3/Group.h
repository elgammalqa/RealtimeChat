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

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Group : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)createItem:(NSString *)name picture:(NSString *)picture members:(NSArray *)members completion:(void (^)(NSError *error))completion;

+ (void)updateName:(NSString *)groupId name:(NSString *)name completion:(void (^)(NSError *error))completion;

+ (void)updatePicture:(NSString *)groupId picture:(NSString *)picture completion:(void (^)(NSError *error))completion;

+ (void)updateMembers:(NSString *)groupId members:(NSArray *)members completion:(void (^)(NSError *error))completion;

+ (void)deleteItem:(NSString *)groupId completion:(void (^)(NSError *error))completion;

+ (void)deployMembers:(NSArray *)members;

@end
