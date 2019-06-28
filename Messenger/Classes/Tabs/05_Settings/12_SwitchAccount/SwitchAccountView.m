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

#import "SwitchAccountView.h"
#import "SwitchAccountCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SwitchAccountView()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SwitchAccountView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"Switch Account";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"SwitchAccountCell" bundle:nil] forCellReuseIdentifier:@"SwitchAccountCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitch:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *userIds = [Account userIds];
	NSString *userId = userIds[index];
	NSDictionary *account = [Account account:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FUser signInWithEmail:account[@"email"] password:account[@"password"] completion:^(FUser *user, NSError *error)
	{
		if (error == nil)
		{
			UserLoggedIn(LOGIN_EMAIL);
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		else [ProgressHUD showError:[error description]];
	}];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [Account count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SwitchAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchAccountCell" forIndexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *userIds = [Account userIds];
	NSString *userId = userIds[indexPath.row];
	NSDictionary *account = [Account account:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[cell bindData:account];
	[cell loadImage:account tableView:tableView indexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.accessoryType = [[FUser currentId] isEqualToString:userId] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([Connection isReachable])
	{
		LogoutUser(DEL_ACCOUNT_NONE);
		[self actionSwitch:indexPath.row];
	}
	else [ProgressHUD showError:@"No network connection."];
}

@end
