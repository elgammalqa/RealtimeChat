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

#import "RCVideoMessageCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCVideoMessageCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCVideoMessageCell

@synthesize imageView, imagePlay, spinner, imageManual;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSIndexPath *)indexPath_ messagesView:(RCMessagesView *)messagesView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	indexPath = indexPath_; messagesView = messagesView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RCMessage *rcmessage = [messagesView rcmessage:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super bindData:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.viewBubble.backgroundColor = rcmessage.incoming ? [RCMessages videoBubbleColorIncoming] : [RCMessages videoBubbleColorOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imageView == nil)
	{
		imageView = [[UIImageView alloc] init];
		imageView.layer.masksToBounds = YES;
		imageView.layer.cornerRadius = [RCMessages bubbleRadius];
		[self.viewBubble addSubview:imageView];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imagePlay == nil)
	{
		imagePlay = [[UIImageView alloc] initWithImage:[RCMessages videoImagePlay]];
		[self.viewBubble addSubview:imagePlay];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (spinner == nil)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self.viewBubble addSubview:spinner];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imageManual == nil)
	{
		imageManual = [[UIImageView alloc] initWithImage:[RCMessages videoImageManual]];
		[self.viewBubble addSubview:imageManual];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_LOADING)
	{
		imageView.image = nil;
		imagePlay.hidden = YES;
		[spinner startAnimating];
		imageManual.hidden = YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_SUCCEED)
	{
		imageView.image = rcmessage.video_thumbnail;
		imagePlay.hidden = NO;
		[spinner stopAnimating];
		imageManual.hidden = YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_MANUAL)
	{
		imageView.image = nil;
		imagePlay.hidden = YES;
		[spinner stopAnimating];
		imageManual.hidden = NO;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [RCVideoMessageCell size:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super layoutSubviews:size];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageView.frame = CGRectMake(0, 0, size.width, size.height);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthPlay = imagePlay.image.size.width;
	CGFloat heightPlay = imagePlay.image.size.height;
	CGFloat xPlay = (size.width - widthPlay) / 2;
	CGFloat yPlay = (size.height - heightPlay) / 2;
	imagePlay.frame = CGRectMake(xPlay, yPlay, widthPlay, heightPlay);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthSpinner = spinner.frame.size.width;
	CGFloat heightSpinner = spinner.frame.size.height;
	CGFloat xSpinner = (size.width - widthSpinner) / 2;
	CGFloat ySpinner = (size.height - heightSpinner) / 2;
	spinner.frame = CGRectMake(xSpinner, ySpinner, widthSpinner, heightSpinner);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthManual = imageManual.image.size.width;
	CGFloat heightManual = imageManual.image.size.height;
	CGFloat xManual = (size.width - widthManual) / 2;
	CGFloat yManual = (size.height - heightManual) / 2;
	imageManual.frame = CGRectMake(xManual, yManual, widthManual, heightManual);
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
	return CGSizeMake([RCMessages videoBubbleWidth], [RCMessages videoBubbleHeight]);
}

@end
