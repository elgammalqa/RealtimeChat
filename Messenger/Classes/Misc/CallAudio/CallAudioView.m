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

#import "CallAudioView.h"
#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallAudioView()
{
	DBUser *dbuser;
	NSTimer *timer;
	BOOL incoming, outgoing;
	BOOL muted, speaker;

	id<SINCall> call;
	id<SINAudioController> audioController;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) IBOutlet UIView *viewButtons;
@property (strong, nonatomic) IBOutlet UIButton *buttonMute;
@property (strong, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;

@property (strong, nonatomic) IBOutlet UIView *viewButtons1;
@property (strong, nonatomic) IBOutlet UIView *viewButtons2;

@property (strong, nonatomic) IBOutlet UIView *viewEnded;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CallAudioView

@synthesize imageUser, labelInitials, labelName, labelStatus;
@synthesize viewButtons, buttonMute, buttonVideo, buttonSpeaker;
@synthesize viewButtons1, viewButtons2;
@synthesize viewEnded;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCall:(id<SINCall>)call_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	call = call_;
	call.delegate = self;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	audioController = app.sinchService.audioController;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithUserId:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	call = [app.sinchService.callClient callUserWithId:userId];
	call.delegate = self;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	audioController = app.sinchService.audioController;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[audioController unmute];
	[audioController disableSpeaker];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute1"] forState:UIControlStateNormal];
	[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute1"] forState:UIControlStateHighlighted];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker1"] forState:UIControlStateNormal];
	[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker1"] forState:UIControlStateHighlighted];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonVideo setImage:[UIImage imageNamed:@"callaudio_video1"] forState:UIControlStateNormal];
	[buttonVideo setImage:[UIImage imageNamed:@"callaudio_video1"] forState:UIControlStateHighlighted];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	incoming = ([call direction] == SINCallDirectionIncoming);
	outgoing = ([call direction] == SINCallDirectionOutgoing);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (incoming) [audioController startPlayingSoundFile:[Dir application:@"call_incoming.wav"] loop:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails1];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIInterfaceOrientationMaskPortrait;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIInterfaceOrientationPortrait;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return NO;
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", [call remoteUserId]];
	dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelInitials.text = [dbuser initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbuser.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			labelInitials.text = nil;
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = dbuser.fullname;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveCallHistory
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[CallHistory createItem:[FUser currentId] recipientId:dbuser.objectId name:dbuser.fullname details:call.details];
	[CallHistory createItem:dbuser.objectId recipientId:dbuser.objectId name:[FUser fullname] details:call.details];
}

#pragma mark - SINCallDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)callDidProgress:(id<SINCall>)call_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[audioController startPlayingSoundFile:[Dir application:@"call_ringback.wav"] loop:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)callDidEstablish:(id<SINCall>)call_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self timerStart];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[audioController stopPlayingSoundFile];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails2];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)callDidEnd:(id<SINCall>)call_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self timerStop];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[audioController stopPlayingSoundFile];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails3];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (outgoing) [self saveCallHistory];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^{ [self dismissViewControllerAnimated:YES completion:nil]; });
}

#pragma mark - Timer methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)timerStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateStatus) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)timerStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[timer invalidate];
	timer = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateStatus
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:[[call details] establishedTime]];
	int seconds = (int) interval % 60;
	int minutes = (int) interval / 60;
	labelStatus.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionMute:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (muted)
	{
		muted = NO;
		[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute1"] forState:UIControlStateNormal];
		[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute1"] forState:UIControlStateHighlighted];
		[audioController unmute];
	}
	else
	{
		muted = YES;
		[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute2"] forState:UIControlStateNormal];
		[buttonMute setImage:[UIImage imageNamed:@"callaudio_mute2"] forState:UIControlStateHighlighted];
		[audioController mute];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSpeaker:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (speaker)
	{
		speaker = NO;
		[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker1"] forState:UIControlStateNormal];
		[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker1"] forState:UIControlStateHighlighted];
		[audioController disableSpeaker];
	}
	else
	{
		speaker = YES;
		[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker2"] forState:UIControlStateNormal];
		[buttonSpeaker setImage:[UIImage imageNamed:@"callaudio_speaker2"] forState:UIControlStateHighlighted];
		[audioController enableSpeaker];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionVideo:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionHangup:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (call != nil) [call hangup];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionAnswer:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (call != nil) [call answer];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (incoming) labelStatus.text = @"Ringing...";
	if (outgoing) labelStatus.text = @"Calling...";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewButtons.hidden = incoming;
	viewButtons1.hidden = outgoing;
	viewButtons2.hidden = incoming;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelStatus.text = @"00:00";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewButtons.hidden = NO;
	viewButtons1.hidden = YES;
	viewButtons2.hidden = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails3
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelStatus.text = @"Ended";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = NO;
}

@end
