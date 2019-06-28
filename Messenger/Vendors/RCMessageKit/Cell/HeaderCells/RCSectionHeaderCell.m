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

#import "RCSectionHeaderCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCSectionHeaderCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCSectionHeaderCell

@synthesize labelSectionHeader;

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
	if (labelSectionHeader == nil)
	{
		labelSectionHeader = [[UILabel alloc] init];
		labelSectionHeader.font = [RCMessages sectionHeaderFont];
		labelSectionHeader.textColor = [RCMessages sectionHeaderColor];
		[self.contentView addSubview:labelSectionHeader];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelSectionHeader.textAlignment = rcmessage.incoming ? NSTextAlignmentCenter : NSTextAlignmentCenter;
	labelSectionHeader.text = [messagesView textSectionHeader:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat width = widthTable - [RCMessages sectionHeaderLeft] - [RCMessages sectionHeaderRight];
	CGFloat height = (labelSectionHeader.text != nil) ? [RCMessages sectionHeaderHeight] : 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelSectionHeader.frame = CGRectMake([RCMessages sectionHeaderLeft], 0, width, height);
}

#pragma mark - Size methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (CGFloat)height:(NSIndexPath *)indexPath messagesView:(RCMessagesView *)messagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([messagesView textSectionHeader:indexPath] != nil) ? [RCMessages sectionHeaderHeight] : 0;
}

@end
