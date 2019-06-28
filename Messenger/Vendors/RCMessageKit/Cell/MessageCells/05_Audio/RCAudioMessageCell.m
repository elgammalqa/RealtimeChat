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

#import "RCAudioMessageCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RCAudioMessageCell()
{
	NSIndexPath *indexPath;
	RCMessagesView *messagesView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RCAudioMessageCell

@synthesize imageStatus, labelDuration, spinner, imageManual;

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
	self.viewBubble.backgroundColor = rcmessage.incoming ? [RCMessages audioBubbleColorIncoming] : [RCMessages audioBubbleColorOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (imageStatus == nil)
	{
		imageStatus = [[UIImageView alloc] init];
		[self.viewBubble addSubview:imageStatus];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (labelDuration == nil)
	{
		labelDuration = [[UILabel alloc] init];
		labelDuration.font = [RCMessages audioFont];
		labelDuration.textAlignment = NSTextAlignmentRight;
		[self.viewBubble addSubview:labelDuration];
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
		imageManual = [[UIImageView alloc] initWithImage:[RCMessages audioImageManual]];
		[self.viewBubble addSubview:imageManual];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED) imageStatus.image = [RCMessages audioImagePlay];
	if (rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING) imageStatus.image = [RCMessages audioImagePause];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelDuration.textColor = rcmessage.incoming ? [RCMessages audioTextColorIncoming] : [RCMessages audioTextColorOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.audio_duration < 60)
		labelDuration.text = [NSString stringWithFormat:@"0:%02ld", (long) rcmessage.audio_duration];
	else labelDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long) rcmessage.audio_duration / 60, (long) rcmessage.audio_duration % 60];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_LOADING)
	{
		imageStatus.hidden = YES;
		labelDuration.hidden = YES;
		[spinner startAnimating];
		imageManual.hidden = YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_SUCCEED)
	{
		imageStatus.hidden = NO;
		labelDuration.hidden = NO;
		[spinner stopAnimating];
		imageManual.hidden = YES;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (rcmessage.status == RC_STATUS_MANUAL)
	{
		imageStatus.hidden = YES;
		labelDuration.hidden = YES;
		[spinner stopAnimating];
		imageManual.hidden = NO;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = [RCAudioMessageCell size:indexPath messagesView:messagesView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[super layoutSubviews:size];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widthStatus = imageStatus.image.size.width;
	CGFloat heightStatus = imageStatus.image.size.height;
	CGFloat yStatus = (size.height - heightStatus) / 2;
	imageStatus.frame = CGRectMake(10, yStatus, widthStatus, heightStatus);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelDuration.frame = CGRectMake(size.width - 100, 0, 90, size.height);
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
	return CGSizeMake([RCMessages audioBubbleWidht], [RCMessages audioBubbleHeight]);
}

@end
