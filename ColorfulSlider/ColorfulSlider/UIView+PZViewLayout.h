//
//  UIView+PZViewLayout.h
//  ColorfulSlider
//
//  Created by Philip Zhao on 8/9/13.
//  Copyright (c) 2013 PZ. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGPoint kPZAnchorPointCenter;
extern const CGPoint kPZAnchorPointBottomCenter;
extern const CGPoint kPZAnchorPointTopLeft;

@interface UIView (PZViewLayout)
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGPoint anchorPoint;
@end
