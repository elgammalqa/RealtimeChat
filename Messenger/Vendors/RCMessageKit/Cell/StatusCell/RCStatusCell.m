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

#import "RCStatusCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCStatusCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCStatusCell

@synthesize viewBubble;
@synthesize textView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	indexPath = indexPath_; messagesView = messagesView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.backgroundColor = [UIColor clearColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (viewBubble == nil)
	{
		viewBubble = [[UIView alloc] init];
		viewBubble.backgroundColor = [RCMessages statusBubbleColor];
		viewBubble.layer.cornerRadius = [RCMessages statusBubbleRadius];
		[self.contentView addSubview:viewBubble];
		[self bubbleGestureRecognizer];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (textView == nil)
	{
		textView = [[UITextView alloc] init];
		textView.font = [RCMessages statusFont];
		textView.textColor = [RCMessages statusTextColor];
		textView.editable = NO;
		textView.selectable = NO;
		textView.scrollEnabled = NO;
		textView.userInteractionEnabled = NO;
		textView.backgroundColor = [UIColor clearColor];
		textView.textContainer.lineFragmentPadding = 0;
		textView.textContainerInset = [RCMessages statusInset];
		[self.viewBubble addSubview:textView];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	textView.text = rcmessage.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGSize size = [RCStatusCell size:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat yBubble = [RCMessages sectionHeaderMargin];
	CGFloat xBubble = (widthTable - size.width) / 2;
	viewBubble.frame = CGRectMake(xBubble, yBubble, size.width, size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	textView.frame = CGRectMake(0, 0, size.width, size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [self size:indexPath messagesView:messagesView];
	return size.height;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGSize)size:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat maxwidth = (0.95 * widthTable) - [RCMessages statusInsetLeft] - [RCMessages statusInsetRight];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect rect = [rcmessage.text boundingRectWithSize:CGSizeMake(maxwidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin
											attributes:@{NSFontAttributeName:[RCMessages statusFont]} context:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = rect.size.width + [RCMessages statusInsetLeft] + [RCMessages statusInsetRight];
	CGFloat height = rect.size.height + [RCMessages statusInsetTop] + [RCMessages statusInsetBottom];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return CGSizeMake(width, height);
}

#pragma mark - Gesture recognizer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bubbleGestureRecognizer
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapBubble)];
	[self.viewBubble addGestureRecognizer:tapGesture];
	tapGesture.cancelsTouchesInView = NO;
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapBubble
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[messagesView.view endEditing:YES];
	[messagesView actionTapBubble:indexPath];
}

@end
