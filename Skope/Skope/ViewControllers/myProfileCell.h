//
//  myProfileCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewInforProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblNamePf;
@property (weak, nonatomic) IBOutlet UITextField *tfNamePf;
@property (weak, nonatomic) IBOutlet UIButton *btChangePicture;
@property (weak, nonatomic) IBOutlet UIButton *btEditName;

@end
