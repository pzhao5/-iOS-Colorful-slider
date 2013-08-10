//
//  PZViewController.m
//  ColorfulSlider
//
//  Created by Philip Zhao on 8/9/13.
//  Copyright (c) 2013 PZ. All rights reserved.
//

#import "PZViewController.h"
#import "PZSlider.h"

@interface PZViewController ()
@property (nonatomic, strong) PZSlider *slider;
@end

@implementation PZViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.slider = [[PZSlider alloc] initWithFrame:CGRectZero];
  self.slider.minimumValue = 0;
  self.slider.maximumValue = 100;
  self.slider.value = 50;
  self.slider.barCornerRadius = 5.0;
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor orangeColor].CGColor, (__bridge id)[UIColor yellowColor].CGColor];
  gradientLayer.startPoint = CGPointMake(0, 0.5);
  gradientLayer.endPoint = CGPointMake(1, 0.5);
  self.slider.backgroundLayer = gradientLayer;
  self.slider.popover = YES;
  
  [self.view addSubview:self.slider];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  static CGFloat leftRightPadding = 30;
  self.slider.frame = CGRectMake(leftRightPadding, 100, CGRectGetWidth(self.view.bounds) - 2 * leftRightPadding, [PZSlider sliderHeightForSlider:self.slider]);
}

@end
