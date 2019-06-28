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
@interface MessageQueue : NSObject
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (void)send:(NSString *)chatId recipientId:(NSString *)recipientId
	  status:(NSString *)status text:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audio;

+ (void)send:(NSString *)chatId groupId:(NSString *)groupId
	  status:(NSString *)status text:(NSString *)text picture:(UIImage *)picture video:(NSURL *)video audio:(NSString *)audio;

+ (void)forward:(NSString *)chatId recipientId:(NSString *)recipientId dbmessage:(DBMessage *)dbmessage;

+ (void)forward:(NSString *)chatId groupId:(NSString *)groupId dbmessage:(DBMessage *)dbmessage;

@end
