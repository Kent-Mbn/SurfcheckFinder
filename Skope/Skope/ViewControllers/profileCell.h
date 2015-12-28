//
//  profileCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewInforProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblNamePf;
@property (weak, nonatomic) IBOutlet UIButton *btSendMss;

@end
