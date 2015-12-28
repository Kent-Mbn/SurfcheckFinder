//
//  ButtonShowImageSlide.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/21/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonShowImageSlide : UIButton{
    NSIndexPath *indexPathCell;
    NSInteger *indexImageSelected;
}

@property(nonatomic, assign) NSInteger *indexImageSelected;
@property(nonatomic, strong) NSIndexPath *indexPathCell;

@end
