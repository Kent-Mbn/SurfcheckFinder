//
//  ChatCellFromAnother.h
//  ChatCustomCell
//
//  Created by Huynh Phong Chau on 2/26/15.
//  Copyright (c) 2015 Huynh Phong Chau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCellFromAnother : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIView *viewChatText;
@property (weak, nonatomic) IBOutlet UILabel *lblChatText;
@property (weak, nonatomic) IBOutlet UIView *viewChatTimeName;
@property (weak, nonatomic) IBOutlet UILabel *lblChatName;
@property (weak, nonatomic) IBOutlet UILabel *lblChatTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgTriangleChat;

@end
