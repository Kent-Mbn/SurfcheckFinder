//
//  postsCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 2/20/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARScrollViewEnhancer.h"

@interface postsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPostedKm;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDislikeNumber;
@property (weak, nonatomic) IBOutlet UIButton *btAddComment;
@property (weak, nonatomic) IBOutlet UIView *viewLikeTotal;
@property (weak, nonatomic) IBOutlet UIView *viewLike;
@property (weak, nonatomic) IBOutlet UIView *viewCommentsArea;
@property (weak, nonatomic) IBOutlet UIButton *btShowAllComments;
@property (weak, nonatomic) IBOutlet UIView *viewLikeCommentsArea;
@property (weak, nonatomic) IBOutlet UIButton *btPLLike;
@property (weak, nonatomic) IBOutlet UIButton *btPLDislike;
@property (weak, nonatomic) IBOutlet UIView *viewPLColorLikeTotal;
@property (weak, nonatomic) IBOutlet UIView *viewPLColorLike;
@property (weak, nonatomic) IBOutlet UILabel *lblPLCountComment;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ARScrollViewEnhancer *viewBoundScrollImg;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeAgo;
@property (weak, nonatomic) IBOutlet UIView *viewBGCell;

@end
