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

#import "SettingsView.h"
#import "EditProfileView.h"
#import "PasswordView.h"
#import "StatusView.h"
#import "BlockedView.h"
#import "ArchiveView.h"
#import "CacheView.h"
#import "MediaView.h"
#import "WallpapersView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "AddAccountView.h"
#import "SwitchAccountView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellProfile;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellStatus;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlocked;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellArchive;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellWallpapers;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellAddAccount;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSwitchAccount;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogout;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogoutAll;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, imageUser, labelInitials, labelName;
@synthesize cellProfile, cellPassword;
@synthesize cellStatus;
@synthesize cellBlocked, cellArchive, cellCache, cellMedia, cellWallpapers;
@synthesize cellPrivacy, cellTerms;
@synthesize cellAddAccount, cellSwitchAccount;
@synthesize cellLogout, cellLogoutAll;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
	self.tabBarItem.title = @"Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(loadUser) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([FUser currentId] != nil)
	{
		if ([FUser isOnboardOk])
		{
			[self loadUser];
		}
		else OnboardUser(self);
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FUser *user = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelInitials.text = [user initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:user[FUSER_PICTURE] completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			labelInitials.text = nil;
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = user[FUSER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellStatus.textLabel.text = user[FUSER_STATUS];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionProfile
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	EditProfileView *editProfileView = [[EditProfileView alloc] initWith:NO];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:editProfileView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPassword
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PasswordView *passwordView = [[PasswordView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:passwordView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStatus
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StatusView *statusView = [[StatusView alloc] init];
	statusView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:statusView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlocked
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BlockedView *blockedView = [[BlockedView alloc] init];
	blockedView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:blockedView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionArchive
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ArchiveView *archiveView = [[ArchiveView alloc] init];
	archiveView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:archiveView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCache
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CacheView *cacheView = [[CacheView alloc] init];
	cacheView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:cacheView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MediaView *mediaView = [[MediaView alloc] init];
	mediaView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:mediaView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionWallpapers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	WallpapersView *wallpapersView = [[WallpapersView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:wallpapersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PrivacyView *privacyView = [[PrivacyView alloc] init];
	privacyView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:privacyView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTerms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	TermsView *termsView = [[TermsView alloc] init];
	termsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:termsView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAddAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AddAccountView *addAccountView = [[AddAccountView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addAccountView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SwitchAccountView *switchAccountView = [[SwitchAccountView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:switchAccountView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self actionLogoutUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAll
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Log out all accounts" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self actionLogoutAllUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LogoutUser(DEL_ACCOUNT_ONE);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([Account count] == 0)
	{
		[self.tabBarController setSelectedIndex:DEFAULT_TAB];
	}
	else [self actionSwitchNextUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchNextUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *userIds = [Account userIds];
	NSString *userId = [userIds firstObject];
	NSDictionary *account = [Account account:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FUser signInWithEmail:account[@"email"] password:account[@"password"] completion:^(FUser *user, NSError *error)
	{
		if (error == nil)
		{
			UserLoggedIn(LOGIN_EMAIL);
		}
		else [ProgressHUD showError:[error description]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAllUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LogoutUser(DEL_ACCOUNT_ALL);
	[self.tabBarController setSelectedIndex:DEFAULT_TAB];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.image = [UIImage imageNamed:@"settings_blank"];
	labelName.text = nil;
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 6;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BOOL emailLogin = [[FUser loginMethod] isEqualToString:LOGIN_EMAIL];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (section == 0) return emailLogin ? 2 : 1;
	if (section == 1) return 1;
	if (section == 2) return 5;
	if (section == 3) return 2;
	if (section == 4) return emailLogin ? 2 : 0;
	if (section == 5) return ([Account count] > 1) ? 2 : 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 1) return @"Status";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellProfile;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellPassword;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellStatus;
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellBlocked;
	if ((indexPath.section == 2) && (indexPath.row == 1)) return cellArchive;
	if ((indexPath.section == 2) && (indexPath.row == 2)) return cellCache;
	if ((indexPath.section == 2) && (indexPath.row == 3)) return cellMedia;
	if ((indexPath.section == 2) && (indexPath.row == 4)) return cellWallpapers;
	if ((indexPath.section == 3) && (indexPath.row == 0)) return cellPrivacy;
	if ((indexPath.section == 3) && (indexPath.row == 1)) return cellTerms;
	if ((indexPath.section == 4) && (indexPath.row == 0)) return cellAddAccount;
	if ((indexPath.section == 4) && (indexPath.row == 1)) return cellSwitchAccount;
	if ((indexPath.section == 5) && (indexPath.row == 0)) return cellLogout;
	if ((indexPath.section == 5) && (indexPath.row == 1)) return cellLogoutAll;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionProfile];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionPassword];
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionStatus];
	if ((indexPath.section == 2) && (indexPath.row == 0)) [self actionBlocked];
	if ((indexPath.section == 2) && (indexPath.row == 1)) [self actionArchive];
	if ((indexPath.section == 2) && (indexPath.row == 2)) [self actionCache];
	if ((indexPath.section == 2) && (indexPath.row == 3)) [self actionMedia];
	if ((indexPath.section == 2) && (indexPath.row == 4)) [self actionWallpapers];
	if ((indexPath.section == 3) && (indexPath.row == 0)) [self actionPrivacy];
	if ((indexPath.section == 3) && (indexPath.row == 1)) [self actionTerms];
	if ((indexPath.section == 4) && (indexPath.row == 0)) [self actionAddAccount];
	if ((indexPath.section == 4) && (indexPath.row == 1)) [self actionSwitchAccount];
	if ((indexPath.section == 5) && (indexPath.row == 0)) [self actionLogout];
	if ((indexPath.section == 5) && (indexPath.row == 1)) [self actionLogoutAll];
}

@end
