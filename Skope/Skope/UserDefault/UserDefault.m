//
//  UserDefault.m
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import "UserDefault.h"
#define kUserDefault_Acc @"User_App"

@implementation UserDefault

static UserDefault *globalObject;

- (id)initWithId:(NSInteger)userID
{
    self.fb_id = [NSString stringWithFormat:@"%d", userID];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.created_date = [aDecoder decodeObjectForKey:@"created_date"];
        self.fb_id = [aDecoder decodeObjectForKey:@"fb_id"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.u_id = [aDecoder decodeObjectForKey:@"u_id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.timezone = [aDecoder decodeObjectForKey:@"timezone"];
        self.isFirstTime = [aDecoder decodeObjectForKey:@"isFirstTime"];
        self.strLat = [aDecoder decodeObjectForKey:@"strLat"];
        self.strLong = [aDecoder decodeObjectForKey:@"strLong"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.created_date forKey:@"created_date"];
    [aCoder encodeObject:self.fb_id forKey:@"fb_id"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.u_id forKey:@"u_id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.timezone forKey:@"timezone"];
    [aCoder encodeObject:self.isFirstTime forKey:@"isFirstTime"];
    [aCoder encodeObject:self.strLat forKey:@"strLat"];
    [aCoder encodeObject:self.strLong forKey:@"strLong"];
    
}

- (void) setTokenUser:(NSString *) strToken {
    self.token = strToken;
    [self update];
}

- (void) setIsFirstTime {
    self.isFirstTime = @"false";
    [self update];
}

- (void) setUser:(NSDictionary *) dicParamUser {
    
    self.email = dicParamUser[@"email"];
    self.avatar = dicParamUser[@"avatar"];
    self.created_date = dicParamUser[@"created_at"];
    self.fb_id = dicParamUser[@"fb_id"];
    self.gender = dicParamUser[@"gender"];
    self.u_id = dicParamUser[@"id"];
    self.name = dicParamUser[@"name"];
    self.timezone = dicParamUser[@"timezone"];
    self.isFirstTime = dicParamUser[@"isFirstTime"];
    self.strLat = dicParamUser[@"strLat"];
    self.strLong = dicParamUser[@"strLong"];
    
    [self update];
}

- (void) updateUserDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

+ (void) clearInfo{
    UserDefault *user = [UserDefault user];
    
    user.token = nil;
    user.email = nil;
    user.avatar = nil;
    user.created_date = nil;
    user.fb_id = nil;
    user.gender = nil;
    user.u_id = nil;
    user.name = nil;
    user.timezone = nil;
    user.isFirstTime = nil;
    user.strLat = nil;
    user.strLong = nil;
    
    [user update];
}

+ (UserDefault *) user
{
    if (!globalObject) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        globalObject = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefault dataForKey:kUserDefault_Acc]] ;
        if (!globalObject) {
            globalObject = [[UserDefault alloc] init] ;
            [globalObject update];
        }
    }
    
    return globalObject;
}
- (void) update
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:self]
                    forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

+ (void) update
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:globalObject]
                    forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

- (void) logoutUser {
    [UserDefault clearInfo];
    [AuthenFacebook clearSessionFB];
    NSLog(@"Logout User!");
}

- (BOOL) isSignIned {
    if (self.token.length > 0) {
        return true;
    }
    return false;
}

@end
