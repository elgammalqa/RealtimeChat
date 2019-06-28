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

#import "RCBubbleFooterCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCBubbleFooterCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCBubbleFooterCell

@synthesize labelBubbleFooter;

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
	if (labelBubbleFooter == nil)
	{
		labelBubbleFooter = [[UILabel alloc] init];
		labelBubbleFooter.font = [RCMessages bubbleFooterFont];
		labelBubbleFooter.textColor = [RCMessages bubbleFooterColor];
		[self.contentView addSubview:labelBubbleFooter];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelBubbleFooter.textAlignment = rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelBubbleFooter.text = [messagesView textBubbleFooter:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = widthTable - [RCMessages bubbleFooterLeft] - [RCMessages bubbleFooterRight];
	CGFloat height = (labelBubbleFooter.text != nil) ? [RCMessages bubbleFooterHeight] : 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelBubbleFooter.frame = CGRectMake([RCMessages bubbleFooterLeft], 0, width, height);
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([messagesView textBubbleFooter:indexPath] != nil) ? [RCMessages bubbleFooterHeight] : 0;
}

@end
