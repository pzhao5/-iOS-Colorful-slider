//
//  UIView+PZViewLayout.m
//  ColorfulSlider
//
//  Created by Philip Zhao on 8/9/13.
//  Copyright (c) 2013 PZ. All rights reserved.
//

#import "UIView+PZViewLayout.h"

#import <QuartzCore/QuartzCore.h>

const CGPoint kPZAnchorPointCenter = {0.5, 0.5};
const CGPoint kPZAnchorPointBottomCenter = {0.5, 1.0};
const CGPoint kPZAnchorPointTopLeft = {0.0, 0.5};

@implementation UIView (PZViewLayout)

- (void)setPosition:(CGPoint)position
{
  self.layer.position = position;
}

- (CGPoint)position
{
  return self.layer.position;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
  self.layer.anchorPoint = anchorPoint;
}

- (CGPoint)anchorPoint
{
  return self.layer.anchorPoint;
}
@end
