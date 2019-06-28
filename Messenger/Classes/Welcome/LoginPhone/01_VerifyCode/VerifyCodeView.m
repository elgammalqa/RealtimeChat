//
// Copyright (c) 2016 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VerifyCodeView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface VerifyCodeView()
{
	NSString *countryCode;
	NSString *phoneNumber;
}

@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UITextField *fieldCode;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation VerifyCodeView

@synthesize delegate;
@synthesize labelHeader, fieldCode;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)countryCode_ phoneNumber:(NSString *)phoneNumber_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	countryCode = countryCode_;
	phoneNumber = phoneNumber_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"SMS Verification";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.view addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelHeader.text = [NSString stringWithFormat:@"Enter the verification code sent to\n\n%@ %@", countryCode, phoneNumber];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[fieldCode becomeFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *code = [textField.text stringByReplacingCharactersInRange:range withString:string];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([code length] == 6)
	{
		[self dismissKeyboard];
		[ProgressHUD show:nil Interaction:NO];

		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
		dispatch_after(time, dispatch_get_main_queue(), ^{
			[self dismissViewControllerAnimated:YES completion:^{
				if (delegate != nil) [delegate didVerifyCode:code];
			}];
		});
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return ([code length] <= 6);
}

@end
