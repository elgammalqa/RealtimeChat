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

#import "RCBubbleHeaderCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCBubbleHeaderCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCBubbleHeaderCell

@synthesize labelBubbleHeader;

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
	if (labelBubbleHeader == nil)
	{
		labelBubbleHeader = [[UILabel alloc] init];
		labelBubbleHeader.font = [RCMessages bubbleHeaderFont];
		labelBubbleHeader.textColor = [RCMessages bubbleHeaderColor];
		[self.contentView addSubview:labelBubbleHeader];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelBubbleHeader.textAlignment = rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelBubbleHeader.text = [messagesView textBubbleHeader:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = widthTable - [RCMessages bubbleHeaderLeft] - [RCMessages bubbleHeaderRight];
	CGFloat height = (labelBubbleHeader.text != nil) ? [RCMessages bubbleHeaderHeight] : 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelBubbleHeader.frame = CGRectMake([RCMessages bubbleHeaderLeft], 0, width, height);
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([messagesView textBubbleHeader:indexPath] != nil) ? [RCMessages bubbleHeaderHeight] : 0;
}

@end
