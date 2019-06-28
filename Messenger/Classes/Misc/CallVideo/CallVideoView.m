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

#import "CallVideoView.h"
#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CallVideoView()
{
	DBUser *dbuser;
	BOOL incoming, outgoing;
	BOOL muted, switched;

	id<SINCall> call;
	id<SINAudioController> audioController;
	id<SINVideoController> videoController;
}

@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@property (strong, nonatomic) IBOutlet UIView *viewDetails;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) IBOutlet UIView *viewButtons1;
@property (strong, nonatomic) IBOutlet UIView *viewButtons2;

@property (strong, nonatomic) IBOutlet UIButton *buttonMute;
@property (strong, nonatomic) IBOutlet UIButton *buttonSwitch;

@property (strong, nonatomic) IBOutlet UIView *viewEnded;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CallVideoView

@synthesize viewBackground;
@synthesize viewDetails, imageUser, labelInitials, labelName, labelStatus;
@synthesize viewButtons1, viewButtons2;
@synthesize buttonMute, buttonSwitch;
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
	audioController = app.sinchService.client.audioController;
	videoController = app.sinchService.client.videoController;
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
	call = [app.sinchService.client.callClient callUserVideoWithId:userId];
	call.delegate = self;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	audioController = app.sinchService.client.audioController;
	videoController = app.sinchService.client.videoController;
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
	videoController.captureDevicePosition = AVCaptureDevicePositionFront;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[viewBackground addSubview:[videoController remoteView]];
	[viewBackground addSubview:[videoController localView]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[videoController localView] setContentMode:UIViewContentModeScaleAspectFill];
	[[videoController remoteView] setContentMode:UIViewContentModeScaleAspectFill];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
	[[videoController remoteView] addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute1"] forState:UIControlStateNormal];
	[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute1"] forState:UIControlStateHighlighted];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch1"] forState:UIControlStateNormal];
	[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch1"] forState:UIControlStateHighlighted];
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
	[audioController stopPlayingSoundFile];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[audioController enableSpeaker];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails2];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)callDidEnd:(id<SINCall>)call_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[audioController stopPlayingSoundFile];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[audioController disableSpeaker];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateViewDetails3];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (outgoing) [self saveCallHistory];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^{ [self dismissViewControllerAnimated:YES completion:nil]; });
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTap
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewButtons2.hidden = !viewButtons2.hidden;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionMute:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (muted)
	{
		muted = NO;
		[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute1"] forState:UIControlStateNormal];
		[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute1"] forState:UIControlStateHighlighted];
		[audioController unmute];
	}
	else
	{
		muted = YES;
		[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute2"] forState:UIControlStateNormal];
		[buttonMute setImage:[UIImage imageNamed:@"callvideo_mute2"] forState:UIControlStateHighlighted];
		[audioController mute];
	}
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSwitch:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (switched)
	{
		switched = NO;
		[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch1"] forState:UIControlStateNormal];
		[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch1"] forState:UIControlStateHighlighted];
		videoController.captureDevicePosition = AVCaptureDevicePositionFront;
	}
	else
	{
		switched = YES;
		[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch2"] forState:UIControlStateNormal];
		[buttonSwitch setImage:[UIImage imageNamed:@"callvideo_switch2"] forState:UIControlStateHighlighted];
		videoController.captureDevicePosition = AVCaptureDevicePositionBack;
	}
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[videoController remoteView] setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	[[videoController localView] setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewDetails.hidden = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (incoming) labelStatus.text = @"Ringing...";
	if (outgoing) labelStatus.text = @"Calling...";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewButtons1.hidden = outgoing;
	viewButtons2.hidden = incoming;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[videoController remoteView] setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	[[videoController localView] setFrame:CGRectMake(20, 20, 70, 100)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewDetails.hidden = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelStatus.text = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewButtons1.hidden = YES;
	viewButtons2.hidden = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails3
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewDetails.hidden = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelStatus.text = @"Ended";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEnded.hidden = NO;
}

@end
