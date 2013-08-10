//  Copyright (c) 2013 PZ. All rights reserved.

#import <UIKit/UIKit.h>

@interface PZSlider : UIControl

/**
 @summary enable the popover view. To receive popover value change event. Add target/Action for UIControlEventValueChanged
 */
@property (nonatomic, assign) BOOL popover;

/**
 @summary contentView to render.
 */
@property (nonatomic, strong) UIView *popoverContentView;

/**
 @summary standard UISlider property
 */
@property (nonatomic, assign, readwrite) CGFloat minimumValue;
@property (nonatomic, assign, readwrite) CGFloat maximumValue;
@property (nonatomic, assign, readwrite) CGFloat value;

/**
 @summary Bar height of the slider
 */
@property (nonatomic, assign, readwrite) CGFloat barHeight;

/**
 @summary bar corner radius
 */
@property (nonatomic, assign, readwrite) CGFloat barCornerRadius;

/**
 @summary provide a background layer to render on the Bar.
 @desc    provide CAGradientLayer would render the gradient of the bar color
 */
@property (nonatomic, strong, readwrite) CALayer *backgroundLayer;

/**
 @summary set bar color.
 @desc    setBackgroundLayer would override this method
 */
@property (nonatomic, strong, readwrite) UIColor *barColor;


- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

- (UIImage *)thumbImageForState:(UIControlState)state;

+ (CGFloat)sliderHeightForSlider:(PZSlider *)slider;
+ (CGRect)popoverContentViewBounds;
@end

