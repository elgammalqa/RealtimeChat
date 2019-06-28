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

#import "RCMessage.h"
#import "RCMenuItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCMessagesView : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) IBOutlet UIView *viewTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle1;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle2;
@property (strong, nonatomic) IBOutlet UIButton *buttonTitle;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *viewLoadEarlier;
@property (strong, nonatomic) IBOutlet UIView *viewTypingIndicator;

@property (strong, nonatomic) IBOutlet UIView *viewInput;
@property (strong, nonatomic) IBOutlet UIButton *buttonInputAttach;
@property (strong, nonatomic) IBOutlet UITextView *textInput;
@property (strong, nonatomic) IBOutlet UIButton *buttonInputSend;

#pragma mark - Load earlier methods

- (void)loadEarlierShow:(BOOL)show;

#pragma mark - Message methods

- (RCMessage *)rcmessage:(NSIndexPath *)indexPath;

#pragma mark - Avatar methods

- (NSString *)avatarInitials:(NSIndexPath *)indexPath;
- (UIImage *)avatarImage:(NSIndexPath *)indexPath;

#pragma mark - Header, Footer methods

- (NSString *)textSectionHeader:(NSIndexPath *)indexPath;
- (NSString *)textBubbleHeader:(NSIndexPath *)indexPath;
- (NSString *)textBubbleFooter:(NSIndexPath *)indexPath;
- (NSString *)textSectionFooter:(NSIndexPath *)indexPath;

#pragma mark - Menu controller methods

- (NSArray *)menuItems:(NSIndexPath *)indexPath;

#pragma mark - Typing indicator methods

- (void)typingIndicatorShow:(BOOL)show animated:(BOOL)animated;

#pragma mark - User actions (bubble tap)

- (void)actionTapBubble:(NSIndexPath *)indexPath;

#pragma mark - User actions (avatar tap)

- (void)actionTapAvatar:(NSIndexPath *)indexPath;

#pragma mark - Helper methods

- (void)scrollToBottom:(BOOL)animated;

@end
