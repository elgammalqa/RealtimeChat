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

#import "RCMessageCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCMessageCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCMessageCell

@synthesize viewBubble;
@synthesize imageAvatar, labelAvatar;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	indexPath = indexPath_; messagesView = messagesView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.backgroundColor = [UIColor clearColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (viewBubble == nil)
	{
		viewBubble = [[UIView alloc] init];
		viewBubble.layer.cornerRadius = [RCMessages bubbleRadius];
		[self.contentView addSubview:viewBubble];
		[self bubbleGestureRecognizer];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imageAvatar == nil)
	{
		imageAvatar = [[UIImageView alloc] init];
		imageAvatar.layer.masksToBounds = YES;
		imageAvatar.layer.cornerRadius = [RCMessages avatarDiameter] / 2;
		imageAvatar.backgroundColor = [RCMessages avatarBackColor];
		imageAvatar.userInteractionEnabled = YES;
		[self.contentView addSubview:imageAvatar];
		[self avatarGestureRecognizer];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageAvatar.image = [messagesView avatarImage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (labelAvatar == nil)
	{
		labelAvatar = [[UILabel alloc] init];
		labelAvatar.font = [RCMessages avatarFont];
		labelAvatar.textColor = [RCMessages avatarTextColor];
		labelAvatar.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:labelAvatar];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelAvatar.text = (imageAvatar.image == nil) ? [messagesView avatarInitials:indexPath] : nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews:(CGSize)size
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super layoutSubviews];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthTable = messagesView.tableView.frame.size.width;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat xBubble = rcmessage.incoming ? [RCMessages bubbleMarginLeft] : (widthTable - [RCMessages bubbleMarginRight] - size.width);
	viewBubble.frame = CGRectMake(xBubble, 0, size.width, size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat diameter = [RCMessages avatarDiameter];
	CGFloat xAvatar = rcmessage.incoming ? [RCMessages avatarMarginLeft] : (widthTable - [RCMessages avatarMarginRight] - diameter);
	imageAvatar.frame = CGRectMake(xAvatar, size.height - diameter, diameter, diameter);
	labelAvatar.frame = CGRectMake(xAvatar, size.height - diameter, diameter, diameter);
}

#pragma mark - Gesture recognizer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bubbleGestureRecognizer
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapBubble)];
	[self.viewBubble addGestureRecognizer:tapGesture];
	tapGesture.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongBubble:)];
	[self.viewBubble addGestureRecognizer:longGesture];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)avatarGestureRecognizer
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapAvatar)];
	[self.imageAvatar addGestureRecognizer:tapGesture];
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTapAvatar
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[messagesView.view endEditing:YES];
	[messagesView actionTapAvatar:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLongBubble:(UILongPressGestureRecognizer *)gestureRecognizer
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	switch (gestureRecognizer.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			[self actionMenu];
			break;
		}
		case UIGestureRecognizerStateChanged:	break;
		case UIGestureRecognizerStateEnded:		break;
		case UIGestureRecognizerStatePossible:	break;
		case UIGestureRecognizerStateCancelled:	break;
		case UIGestureRecognizerStateFailed:	break;
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMenu
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([messagesView.textInput isFirstResponder] == NO)
	{
		UIMenuController *menuController = [UIMenuController sharedMenuController];
		[menuController setMenuItems:[messagesView menuItems:indexPath]];
		[menuController setTargetRect:viewBubble.frame inView:self.contentView];
		[menuController setMenuVisible:YES animated:YES];
	}
	else [messagesView.textInput resignFirstResponder];
}

@end
