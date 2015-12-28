//
//  AppDelegate.h
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Common.h"
#import "LocationTracker.h"
#import "LocationShareModel.h"
#import "Define.h"
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate> {
    //Variable to detect killed app process
    BOOL isKilledAppProcess;
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) CLLocationCoordinate2D lastLocation;
@property (nonatomic) CLLocationAccuracy lastLocationAccuracy;

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CLLocationAccuracy locationAccuracy;

@property LocationTracker *locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;

@property (strong,nonatomic) LocationShareModel * shareModel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) setRootViewLogoutWithCompletion:(dispatch_block_t)block;
- (void) setRootViewLoginWithCompletion:(dispatch_block_t)block;

- (BOOL)connect;
- (void)disconnect;

@end

