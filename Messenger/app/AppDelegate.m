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

#import "AppDelegate.h"
#import "ChatsView.h"
#import "CallsView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import "NavigationController.h"

#import "CallAudioView.h"
#import "CallVideoView.h"

@implementation AppDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Firebase initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FIRApp configure];
	[FIRDatabase database].persistenceEnabled = NO;
	[[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelError];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Dialogflow initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	id <AIConfiguration> configuration = [[AIDefaultConfiguration alloc] init];
	configuration.clientAccessToken = DIALOGFLOW_ACCESS_TOKEN;
	[ApiAI sharedApiAI].configuration = configuration;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Push notification initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge;
	UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	[userNotificationCenter requestAuthorizationWithOptions:authorizationOptions completionHandler:^(BOOL granted, NSError *error)
	{
		if (error == nil)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[[UIApplication sharedApplication] registerForRemoteNotifications];
			});
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// OneSignal initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APPID handleNotificationReceived:nil handleNotificationAction:nil
							settings:@{kOSSettingsKeyInAppAlerts:@NO}];
	[OneSignal setLogLevel:ONE_S_LL_NONE visualLevel:ONE_S_LL_NONE];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// This can be removed once Firebase auth issue is resolved
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UserDefaults boolForKey:@"Initialized"] == NO)
	{
		[UserDefaults setObject:@YES forKey:@"Initialized"];
		[FUser logOut];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Shortcut items initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Shortcut create];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Connection, Location initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Connection shared];
	[Location shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// RelayManager initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[RelayManager shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Realm initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Blockeds shared];
	[Blockers shared];
	[CallHistories shared];
	[Friends shared];
	[Groups shared];
	[Messages shared];
	[Statuses shared];
	[Users shared];
	[UserStatuses shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// UI initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.chatsView = [[ChatsView alloc] initWithNibName:@"ChatsView" bundle:nil];
	self.callsView = [[CallsView alloc] initWithNibName:@"CallsView" bundle:nil];
	self.peopleView = [[PeopleView alloc] initWithNibName:@"PeopleView" bundle:nil];
	self.groupsView = [[GroupsView alloc] initWithNibName:@"GroupsView" bundle:nil];
	self.settingsView = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];

	NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.chatsView];
	NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.callsView];
	NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
	NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
	NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.settingsView];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4, navController5];
	self.tabBarController.tabBar.translucent = NO;
	self.tabBarController.selectedIndex = DEFAULT_TAB;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.chatsView view];
	[self.callsView view];
	[self.peopleView view];
	[self.groupsView view];
	[self.settingsView view];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Sinch initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	id config = [[[SinchService configWithApplicationKey:SINCH_KEY applicationSecret:SINCH_SECRET environmentHost:SINCH_HOST]
				  pushNotificationsWithEnvironment:SINAPSEnvironmentAutomatic] disableMessaging];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.sinchService = [SinchService serviceWithConfig:config];
	self.sinchService.delegate = self;
	self.sinchService.callClient.delegate = self;
	[self.sinchService.push setDesiredPushType:SINPushTypeVoIP];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter addObserver:self selector:@selector(sinchLogInUser) name:NOTIFICATION_APP_STARTED];
	[NotificationCenter addObserver:self selector:@selector(sinchLogInUser) name:NOTIFICATION_USER_LOGGED_IN];
	[NotificationCenter addObserver:self selector:@selector(sinchLogOutUser) name:NOTIFICATION_USER_LOGGED_OUT];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Location stop];
	UpdateLastTerminate(YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Location start];
	UpdateLastActive();
	//---------------------------------------------------------------------------------------------------------------------------------------------
	OSPermissionSubscriptionState *status = [OneSignal getPermissionSubscriptionState];
	if (status.subscriptionStatus.pushToken != nil)
	{
		NSString *userId = status.subscriptionStatus.userId;
		[UserDefaults setObject:userId forKey:ONESIGNALID];
	}
	else [UserDefaults removeObjectForKey:ONESIGNALID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UpdateOneSignalId();
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[CacheManager cleanupExpired];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter post:NOTIFICATION_APP_STARTED];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - CoreSpotlight methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([userActivity.activityType isEqual:CSSearchableItemActionType])
	{
		NSString *activityIdentifier = [userActivity.userInfo valueForKey:CSSearchableItemActivityIdentifier];
		NSLog(@"AppDelegate continueUserActivity: %@", activityIdentifier);
		return YES;
	}
	return NO;
}

#pragma mark - Sinch user methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sinchLogInUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FUser currentId] != nil)
	{
		[self.sinchService logInUserWithId:[FUser currentId]];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sinchLogOutUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.sinchService logOutUser];
}

#pragma mark - SINServiceDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)service:(id<SINService>)service didFailWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - SINCallClientDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)client:(id<SINCallClient>)client didReceiveIncomingCall:(id<SINCall>)call
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (call.details.isVideoOffered)
	{
		CallVideoView *callVideoView = [[CallVideoView alloc] initWithCall:call];
		UIViewController *topViewController = [self topViewController];
		[topViewController presentViewController:callVideoView animated:YES completion:nil];
	}
	else
	{
		CallAudioView *callAudioView = [[CallAudioView alloc] initWithCall:call];
		UIViewController *topViewController = [self topViewController];
		[topViewController presentViewController:callAudioView animated:YES completion:nil];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (SINLocalNotification *)client:(id<SINCallClient>)client localNotificationForIncomingCall:(id<SINCall>)call
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SINLocalNotification *notification = [[SINLocalNotification alloc] init];
	notification.alertAction = @"Answer";
	notification.alertBody = @"Incoming call";
	notification.soundName = @"call_incoming.wav";
	return notification;
}

#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeUnknown];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([[FIRAuth auth] canHandleNotification:userInfo])
	{
		completionHandler(UIBackgroundFetchResultNoData);
	}
}

#pragma mark - Home screen dynamic quick action methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (shortcutItem == nil) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([shortcutItem.type isEqualToString:@"newchat"])
	{
		[self.chatsView actionNewChat];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([shortcutItem.type isEqualToString:@"newgroup"])
	{
		[self.groupsView actionNewGroup];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([shortcutItem.type isEqualToString:@"recentuser"])
	{
		NSDictionary *userInfo = shortcutItem.userInfo;
		NSString *userId = userInfo[@"userId"];
		[self.chatsView actionRecentUser:userId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([shortcutItem.type isEqualToString:@"shareapp"])
	{
		NSMutableArray *shareitems = [[NSMutableArray alloc] init];
		[shareitems addObject:TEXT_SHARE_APP];
		UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:shareitems applicationActivities:nil];
		UIViewController *topViewController = [self topViewController];
		[topViewController presentViewController:activityView animated:YES completion:nil];
	}
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIViewController *)topViewController
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (viewController.presentedViewController != nil) {
		viewController = viewController.presentedViewController;
	}
	return viewController;
}

@end
