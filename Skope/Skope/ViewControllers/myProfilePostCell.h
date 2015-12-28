//
//  myProfilePostCell.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARScrollViewEnhancer.h"

@interface myProfilePostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewComment;
@property (weak, nonatomic) IBOutlet UILabel *lblContentPost;
@property (weak, nonatomic) IBOutlet UIButton *btAddComment;
@property (weak, nonatomic) IBOutlet UIButton *btShowAllCm;
@property (weak, nonatomic) IBOutlet UIView *viewLikeCommentsArea;
@property (weak, nonatomic) IBOutlet UILabel *lblCountComment;
@property (weak, nonatomic) IBOutlet UIButton *btLike;
@property (weak, nonatomic) IBOutlet UIButton *btDislike;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberLikes;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberDislikes;
@property (weak, nonatomic) IBOutlet UIView *viewColorLikeTotal;
@property (weak, nonatomic) IBOutlet UIView *viewColorLike;
@property (weak, nonatomic) IBOutlet UILabel *lblPostedAway;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeAgo;
@property (weak, nonatomic) IBOutlet ARScrollViewEnhancer *viewBoundScrollImgMPF;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewMPF;


@end
