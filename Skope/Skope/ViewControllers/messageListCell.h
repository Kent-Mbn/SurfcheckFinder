//
//  messageListCell.h
//  Skope
//
//  Created by CHAU HUYNH on 2/13/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messageListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstMss;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeMss;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;

@end
