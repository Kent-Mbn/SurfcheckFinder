//
//  AppDelegate.m
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Quickblox/Quickblox.h>
#import "ImportFiles.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "APIService.h"


#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit]];
    //Init isKilled app is NO;
    isKilledAppProcess = NO;
    
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;

    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        [Common showAlertView:APP_NAME message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" delegate:nil cancelButtonTitle:TITLE_CANCEL_BT_ALERT arrayTitleOtherButtons:nil tag:0];
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        [Common showAlertView:APP_NAME message:@"The functions of this app are limited because the Background App Refresh is disable." delegate:nil cancelButtonTitle:TITLE_CANCEL_BT_ALERT arrayTitleOtherButtons:nil tag:0];
        
    } else{
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            NSLog(@"UIApplicationLaunchOptionsLocationKey");
            //App forced relaunch by system when receive new event about location
            isKilledAppProcess = YES;
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
            
            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }
            
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
        }

        /*
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        
         
        //Send the best location to server every TIME_TO_RECALL_WS_UPDATE_LOCATION seconds
        //You may adjust the time interval depends on the need of your app.
        
        NSTimeInterval time = TIME_TO_RECALL_WS_UPDATE_LOCATION;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
         */
    }
    
    if ([[UserDefault user] isSignIned]) {
        [APP_DELEGATE setRootViewLoginWithCompletion:^{
            
        }];
    }
    
//    [QBApplication sharedApplication].applicationId = 22129;
//    [QBConnection registerServiceKey:@"gTEJ7HKRk8usjMO"];
//    [QBConnection registerServiceSecret:@"ADjwzF6rz2bQ5r-"];
//    [QBSettings setAccountKey:@"GBwNUT5exXP7cRQdUyeC"];
//    [QBChat instance].autoReconnectEnabled = YES;
//
//    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
//    } errorBlock:^(QBResponse *response) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
//                                                        message:[response.error description]
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
//                                              otherButtonTitles:nil];
//        [alert show];
//    }];
    
    [Parse setApplicationId:@"cegM1qaC47EgfbqOMnI6IIjYkPsfhVMV99tfD1Gi" clientKey:@"A4Enr3OL9PAt6ZkoEUVsUUyKmCra0zlKg4y975E6"];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [PFFacebookUtils initializeFacebook];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [PFImageView class];
    //---------------------------------------------------------------------------------------------------------------------------------------------

    
    return YES;
}

-(void)updateLocation {
    NSLog(@"updateLocation");
    [self.locationTracker updateLocationToServer];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"locationManager didUpdateLocations Appdelegate: %@",locations);
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.location = theLocation;
        self.locationAccuracy = theAccuracy;
    }
    
    //Call WS for updating location...
    //Call if isKilledAppprocess = YES, when app is relaunched by system after app is terminated by user
    if (CLLocationCoordinate2DIsValid(self.location) && [[UserDefault user].token length] > 0 && isKilledAppProcess) {
        [self callWSUpdateLocationWhenAppKilled:self.location];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
//    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
//    [[QBChat instance] logout];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //login QuickBlox with user infor
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *userLogin = [defaults objectForKey:@"loginQuickbloxID"];
//    NSString *userPassword = [defaults objectForKey:@"passwordQuickblox"];
//    
//    QBSessionParameters *parameters = [QBSessionParameters new];
//    parameters.userLogin = userLogin;
//    parameters.userPassword = userPassword;
//    
//    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
//        // Sign In to QuickBlox Chat
//        QBUUser *currentUser = [QBUUser user];
//        currentUser.ID = session.userID; // your current user's ID
//        currentUser.password = userPassword; // your current user's password
//        
//        // login to Chat
//        [[QBChat instance] loginWithUser:currentUser];
//        NSLog(@"successBlock: %@", response);
//    } errorBlock:^(QBResponse *response) {
//        // error handling
//        NSLog(@"errorBlock: %@", response.error);
//    }];
//
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    
//    [self connect];

}

- (void)applicationWillTerminate:(UIApplication *)application {
//    [[QBChat instance] logout];
    [self saveContext];
}

- (void) setRootViewLoginWithCompletion:(dispatch_block_t)block
{
    UIStoryboard *storyboard = [self.window.rootViewController storyboard];
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ROOT_LOGIN_SUCCESS"];
    
    if (![self.window.rootViewController isEqual:viewController]) {
        self.window.rootViewController = viewController;
        if (block) {
            block();
        }
    }
}

- (void) setRootViewLogoutWithCompletion:(dispatch_block_t)block
{
    UIStoryboard *storyboard = [self.window.rootViewController storyboard];
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ROOT_LOGOUT_SUCCESS"];
    
    if (![self.window.rootViewController isEqual:viewController]) {
        self.window.rootViewController = viewController;
        if (block) {
            block();
        }
    }
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.chauhuynh.gcs.Skope" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Skope" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Skope.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - FACEBOOK SECTION


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
//    return [FBSession.activeSession handleOpenURL:url];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //[PFPush handlePush:userInfo];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self performSelector:@selector(refreshMessagesView) withObject:nil afterDelay:4.0];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshMessagesView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    [self.messagesView loadMessages];
    NSLog(@"refreshMessagesView");
}


#pragma mark - Update location with app killed
- (void) callWSUpdateLocationWhenAppKilled:(CLLocationCoordinate2D) newLocation {
    NSString *strStatus = @"killed_app";
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"latitude":@(newLocation.latitude),
                                            @"longitude":@(newLocation.longitude),
                                            @"status":strStatus,
                                            @"created_date":[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000],
                                            } mutableCopy];
    NSLog(@"request_param KILL APP: %@ %@", request_param, [NSString stringWithFormat:@"%@?access_token=%@", URL_SERVER_API(API_UPDATE_LOCATION),[UserDefault user].token]);
    [manager PUT:[NSString stringWithFormat:@"%@?access_token=%@", URL_SERVER_API(API_UPDATE_LOCATION),[UserDefault user].token] parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        //First update when app live again after killed, here is background mode process
        isKilledAppProcess = NO;
        //Needed? save battery
        //if(self.shareModel.anotherLocationManager)
            //[self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
        
        NSLog(@"Tracking KILL Error: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            NSLog(@"Update lai location thanh cong...");
            [UserDefault user].strLat = [NSString stringWithFormat:@"%g", newLocation.latitude];
            [UserDefault user].strLong = [NSString stringWithFormat:@"%g", newLocation.longitude];
            [[UserDefault user] update];
        } else {
            if ([Common validateAuthenFailed:responseObject]) {
                [APP_DELEGATE setRootViewLogoutWithCompletion:^{
                    
                }];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
}

#pragma mark - XMPP Chat

- (void)setupStream {
//    xmppStream = [[XMPPStream alloc] init];
//    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline {
//    XMPPPresence *presence = [XMPPPresence presence];
//    [xmppStream sendElement:presence];
}

- (void)goOffline {
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
//    [xmppStream sendElement:presence];
}

- (BOOL)connect {
    
//    [self setupStream];
//    
//    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"chatID"];
//    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"chatPassword"];
//    
//    if (![xmppStream isDisconnected]) {
//        return YES;
//    }
//    
//    if (jabberID == nil || myPassword == nil) {
//        
//        return NO;
//    }
//    
//    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
//    password = myPassword;
//    
//    NSError *error = nil;
//    NSTimeInterval time = TIME_TO_RECALL_WS_UPDATE_LOCATION;
//
//    if (![xmppStream connectWithTimeout:time error:&error])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//        
//        
//        return NO;
//    }
//    
    return YES;
}

- (void)disconnect {
    
//    [self goOffline];
//    [xmppStream disconnect];
    
}

@end
