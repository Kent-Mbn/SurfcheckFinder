//
//  Common.m
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (void)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        view = roundedView;
    }
}

+ (void) radiusRoundView:(UIView *) view andRadius:(float) radius {
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

+ (void) circleImageView:(UIView *) imgV {
    imgV.layer.cornerRadius = imgV.frame.size.width / 2;
    imgV.clipsToBounds = YES;
    imgV.layer.borderWidth = 3.0f;
    imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
}

+ (BOOL) checkIphoneVersion:(NSString *) strVersion {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480 && ([strVersion isEqualToString:@"4"] || [strVersion isEqualToString:@"4S"]))
        {
            return true;
        }
        else if(result.height == 568 && ([strVersion isEqualToString:@"5"] || [strVersion isEqualToString:@"5S"]))
        {
            return true;
        }
        else if(result.height == 667 && [strVersion isEqualToString:@"6"])
        {
            return true;
        }
        else if(result.height == 736 && [strVersion isEqualToString:@"6P"])
        {
            return true;
        }
    }
    
    return false;
}

+ (NSArray *) arrContentPosts {
    return  @[@"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.", @"I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine, I am so happy, my dear friend, so absored in the exquisite sense of mere tranquil existence, that I neglect my talents, I should be...",@"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.", @"I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine, I am so happy, my dear friend, so absored in the exquisite sense of mere tranquil existence, that I neglect my talents, I should be...",@"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart."];
}

+ (NSArray *) arrComments {
    return @[@"Sound good!", @"OK, greate! I want to go there now, but I don't have enough money!",@"Sound good!", @"OK, greate! I want to go there now, but I don't have enough money!",@"Sound good!"];
}

+ (CGFloat) getHeightOfText:(NSInteger)widthS andText:(NSString *) strText andFont:(UIFont *)font {
    CGSize constrainedSize = CGSizeMake(widthS, CGFLOAT_MAX);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strText attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (requiredHeight.size.width > widthS) {
        requiredHeight = CGRectMake(0, 0, widthS, requiredHeight.size.height);
    }
    
    float height_text = requiredHeight.size.height;
    
    if (height_text > 50) {
        height_text *= 0.88;
    }
    
    return height_text;
}

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    alert.tag = tag;
    
    if([arrayTitleOtherButtons count] > 0) {
        for (int i = 0; i < [arrayTitleOtherButtons count]; i++) {
            [alert addButtonWithTitle:arrayTitleOtherButtons[i]];
        }
    }
    
    [alert show];
}

+ (void) showLoadingViewGlobal:(NSString *) titleaLoading {
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (titleaLoading != nil) {
        [SVProgressHUD showWithStatus:titleaLoading maskType:SVProgressHUDMaskTypeGradient];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
}

+ (void) showNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void) hideNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (void) hideLoadingViewGlobal {
    [SVProgressHUD dismiss];
}

+ (CGFloat) heightScreen {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat) widthScreen {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (void) changeY:(UIView *) viewChange andY:(float) y {
    CGRect frameT = viewChange.frame;
    frameT.origin.y = y;
    viewChange.frame = frameT;
}
+ (void) changeX:(UIView *) viewChange andX:(float) x {
    CGRect frameT = viewChange.frame;
    frameT.origin.x = x;
    viewChange.frame = frameT;
}
+ (void) changeWidth:(UIView *) viewChange andWidth:(float) width {
    CGRect frameT = viewChange.frame;
    frameT.size.width = width;
    viewChange.frame = frameT;
}
+ (void) changeHeight:(UIView *) viewChange andHeight:(float) height {
    CGRect frameT = viewChange.frame;
    frameT.size.height = height;
    viewChange.frame = frameT;
}

+ (void) changeXY:(UIView *) viewChange andX:(float) x andY:(float) y {
    CGRect frameT = viewChange.frame;
    frameT.origin.x = x;
    frameT.origin.y = y;
    viewChange.frame = frameT;
}
+ (void) changeWidthHeight:(UIView *) viewChange andWidth:(float) width andHeight:(float) height {
    CGRect frameT = viewChange.frame;
    frameT.size.width = width;
    frameT.size.height = height;
    viewChange.frame = frameT;
}

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setTimeoutInterval:30];
    return manager;
}

+ (void) requestSuccessWithReponse:(id)result didFinish:(void(^)(BOOL success, NSMutableDictionary *object))block
{
    if (!result) {
        if (block) {
            block(NO,nil);
        }
        return;
    }
    NSMutableDictionary *data ;
    if ([result isKindOfClass:[NSData class]]) {
        data = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
    }else{
        NSData *convertData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
        data = [NSJSONSerialization JSONObjectWithData:convertData options:NSJSONReadingMutableContainers error:nil];
    }
    
    //show error messgae
    if (![data[@"meta"][@"code"] isEqual:[NSNull null]] && [data[@"meta"][@"code"] intValue] != 200) {
        
        NSLog(@"error ==> %@",data);
        
        if (block) {
            block(NO,data);
        }
        
        if ([data[@"meta"][@"code"] intValue] == 401 || [data[@"meta"][@"code"] intValue] != 403) {
            [APP_DELEGATE setRootViewLogoutWithCompletion:^{
                
            }];
        }
        
    }else{
        NSLog(@"responseOBJ ==> %@",data);
        
        if (block) {
            block(YES,data);
        }
    }
}


+ (BOOL) validateRespone:(id) respone {
    NSDictionary *dicMeta = respone[@"meta"];
    if (dicMeta) {
        if ([dicMeta[@"code"] intValue] == 200) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL) validateAuthenFailed:(id) respone {
    NSDictionary *dicMeta = respone[@"meta"];
    if (dicMeta) {
        if ([dicMeta[@"code"] intValue] == 401 || [dicMeta[@"code"] intValue] == 403) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL) validateLocationCoordinate2DIsValid:(CLLocationCoordinate2D) coordinate {
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude != 0 && coordinate.longitude != 0 )) {
        return YES;
    }
    return NO;
}

+ (UIImage*)resizeImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", igError );
    
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    return thumbnailImage;
}

+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString
{
    CLLocationCoordinate2D location;
    NSArray *coordArray = [coordString componentsSeparatedByString: @","];
    location.latitude = ((NSNumber *)coordArray[0]).doubleValue;
    location.longitude = ((NSNumber *)coordArray[1]).doubleValue;
    
    return location;
}

+(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;
    
    //NSLog(@"%f",dist);
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

+(float)metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    
    //NSLog(@"%f",dist);
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

+ (NSMutableDictionary *)mutableArray:(id)response {
    NSMutableDictionary *data ;
    
    if ([response isKindOfClass:[NSData class]]) {
        data = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    }else{
        NSData *convertData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        data = [NSJSONSerialization JSONObjectWithData:convertData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return data;
}

+ (NSString *) convertTimeStampToDate:(double) unixTimeStamp {
    NSTimeInterval timeInterval=unixTimeStamp/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView.image;
}



@end
