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

#import "RCSectionFooterCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCSectionFooterCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCSectionFooterCell

@synthesize labelSectionFooter;

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
	if (labelSectionFooter == nil)
	{
		labelSectionFooter = [[UILabel alloc] init];
		labelSectionFooter.font = [RCMessages sectionFooterFont];
		labelSectionFooter.textColor = [RCMessages sectionFooterColor];
		[self.contentView addSubview:labelSectionFooter];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelSectionFooter.textAlignment = rcmessage.incoming ? NSTextAlignmentLeft : NSTextAlignmentRight;
	labelSectionFooter.text = [messagesView textSectionFooter:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = widthTable - [RCMessages sectionFooterLeft] - [RCMessages sectionFooterRight];
	CGFloat height = (labelSectionFooter.text != nil) ? [RCMessages sectionFooterHeight] : 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelSectionFooter.frame = CGRectMake([RCMessages sectionFooterLeft], 0, width, height);
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([messagesView textSectionFooter:indexPath] != nil) ? [RCMessages sectionFooterHeight] : 0;
}

@end
