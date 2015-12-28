//
//  LoginFBVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 2/28/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportFiles.h"
#import "AuthenFacebook.h"

@interface LoginFBVC : UIViewController<AuthenFacebookDelegate>
- (IBAction)actionLoginFB:(id)sender;

@end
