//
//  UserDefault.h
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenFacebook.h"

@interface UserDefault : NSObject<NSCoding>

@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *avatar;
@property(nonatomic,strong) NSString *created_date;
@property(nonatomic,strong) NSString *fb_id;
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *u_id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *timezone;
@property(nonatomic,strong) NSString *isFirstTime;
@property(nonatomic,strong) NSString *strLong;
@property(nonatomic,strong) NSString *strLat;


+ (UserDefault *) user;
- (void) setUser:(NSDictionary *) dicParamUser;
- (void) update;
+ (void) update;
+ (void) clearInfo;
- (void) logoutUser;
- (BOOL) isSignIned;
- (void) setIsFirstTime;

@end
