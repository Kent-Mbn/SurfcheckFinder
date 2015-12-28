//
//  Common.h
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "AppDelegate.h"
#import "Define.h"
#import <AVFoundation/AVFoundation.h>


@interface Common : NSObject

+ (void) circleImageView:(UIView *) imgV;
+ (BOOL) checkIphoneVersion:(NSString *) strVersion;
+ (CGFloat) getHeightOfText:(NSInteger)widthS andText:(NSString *) strText andFont:(UIFont *)font;

+ (NSArray *) arrContentPosts;
+ (NSArray *) arrComments;

+ (CGFloat) heightScreen;
+ (CGFloat) widthScreen;

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag;

+ (void) showNetworkActivityIndicator;
+ (void) hideNetworkActivityIndicator;
+ (void) showLoadingViewGlobal:(NSString *) titleaLoading;
+ (void) hideLoadingViewGlobal;


+ (void)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;
+ (void) radiusRoundView:(UIView *) imgV andRadius:(float) radius;
+ (void) changeY:(UIView *) viewChange andY:(float) y;
+ (void) changeX:(UIView *) viewChange andX:(float) x;
+ (void) changeWidth:(UIView *) viewChange andWidth:(float) width;
+ (void) changeHeight:(UIView *) viewChange andHeight:(float) height;

+ (void) changeXY:(UIView *) viewChange andX:(float) x andY:(float) y;
+ (void) changeWidthHeight:(UIView *) viewChange andWidth:(float) width andHeight:(float) height;

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn;
+ (void) requestSuccessWithReponse:(id)result didFinish:(void(^)(BOOL success, NSMutableDictionary *object))block;

+ (BOOL) validateRespone:(id) respone;
+ (BOOL) validateLocationCoordinate2DIsValid:(CLLocationCoordinate2D) coordinate;
+ (UIImage*)resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time;
+ (BOOL) validateAuthenFailed:(id) respone;
+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString;
+(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to;
+ (float)metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to;

+ (NSMutableDictionary *)mutableArray:(id)response;
+ (NSString *) convertTimeStampToDate:(double) unixTimeStamp;

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;

@end
