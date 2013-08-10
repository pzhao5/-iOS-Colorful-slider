//  Copyright (c) 2013 PZ. All rights reserved.

#import "PZSlider.h"
#import "UIView+PZViewLayout.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kPZSliderPopoverSquareSize = 58.0;
static const CGFloat kPZSliderPopoverContentSizeInWidth = 34.0;
static const CGFloat kPZSliderPopoverContentSizeInHeight = 31.0;
static const CGFloat kPZSliderPopoverArrowPadding = 17.0;
static const CGFloat kPZSliderBarHeight = 9.0;
static const CGFloat kPZSliderBarLeftRightPadding = 4.0;

@interface PZSlider() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *popoverView;

@property (nonatomic, strong) UIImageView *thumbButtonView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGPoint lastMovingPoint;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation PZSlider
@synthesize value = _value;

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _shapeLayer = [CAShapeLayer layer];
    
    _thumbButtonView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _thumbButtonView.anchorPoint = kPZAnchorPointCenter;

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
    // That is How we get the thumb of the slider for iOS6 and below.
    slider.minimumValue = 0; slider.maximumValue = 10;
    _thumbButtonView.image = [slider thumbImageForState:UIControlStateNormal];
    [_thumbButtonView sizeToFit];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    [self addSubview:_thumbButtonView];
    
    _popoverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _popoverView.image = [UIImage imageNamed:@"slider-popover"];
    _popoverView.anchorPoint = kPZAnchorPointBottomCenter;
    _popoverView.alpha = 0.0;
    
    _backgroundLayer = [CALayer layer];
    _backgroundLayer.mask = _shapeLayer;
    _backgroundLayer.backgroundColor = [UIColor blueColor].CGColor;
    _backgroundLayer.anchorPoint = kPZAnchorPointCenter;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    
    [self addSubview:_popoverView];
    self.clipsToBounds = NO;
    
    _barHeight = kPZSliderBarHeight;
    _barCornerRadius = _barHeight / 2;
  }
  return self;
}

#pragma mark -
#pragma mark - Public method (Setter)
- (void)setPopoverContentView:(UIView *)popoverContentView
{
  if (_popoverContentView != popoverContentView) {
    [_popoverContentView removeFromSuperview];
    _popoverContentView = popoverContentView;
    _popoverContentView.anchorPoint = kPZAnchorPointTopLeft;
    if (_popoverContentView) {
      [_popoverView addSubview:_popoverContentView];
    }
  }
}

- (void)setBackgroundLayer:(CALayer *)backgroundLayer
{
  if (_backgroundLayer != backgroundLayer) {
    [_backgroundLayer removeFromSuperlayer];
    backgroundLayer.mask = _shapeLayer;
    _backgroundLayer = backgroundLayer;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    _backgroundLayer.anchorPoint = kPZAnchorPointCenter;
  }
}

- (void)setValue:(CGFloat)value
{
  if (_value != value) {
    float valuePrecentage = 0;
    if (_maximumValue != _minimumValue) {
      valuePrecentage = (value - _minimumValue) / (_maximumValue - _minimumValue);
    }
    float newPosition = valuePrecentage * [self _sliderTravelDistance] + [self _sliderBeginTravelDistance];
    _thumbButtonView.position = CGPointMake(newPosition, CGRectGetMidY(self.bounds));
    _value = value;
    if (self.popover) {
      self.popoverView.position = CGPointMake(newPosition, CGRectGetMinY(_thumbButtonView.frame));
    }
  }
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
  if (_minimumValue != minimumValue) {
    _minimumValue = minimumValue;
    [self setNeedsLayout];
  }
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
  if (_maximumValue != maximumValue) {
    _maximumValue = maximumValue;
    [self setNeedsLayout];
  }
}

- (void)setBarColor:(UIColor *)barColor
{
  _backgroundLayer.backgroundColor = barColor.CGColor;
}

- (UIColor *)barColor
{
  return [UIColor colorWithCGColor:_backgroundLayer.backgroundColor];
}

- (CGFloat)value
{
  if (_value < _minimumValue || _value > _maximumValue) {
    _value = (_maximumValue - _minimumValue) / 2 + _minimumValue;
  }
  return _value;
}

#pragma mark -
#pragma mark - Public method

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
  if (state == UIControlStateNormal) {
    _thumbButtonView.image = image;
  } else if (state == UIControlStateHighlighted) {
    _thumbButtonView.highlightedImage = image;
  }
}

- (UIImage *)thumbImageForState:(UIControlState)state
{
  if (state == UIControlStateNormal) {
    return _thumbButtonView.image;
  } else if (state == UIControlStateHighlighted) {
    return _thumbButtonView.highlightedImage;
  }
  return nil;
}

#pragma mark -
#pragma mark - override the superclass

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  float valuePrecentage = 0;
  if (_minimumValue != _maximumValue) {
    valuePrecentage = MAX((_value - _minimumValue) / (_maximumValue - _minimumValue), 0);
  }
  [_thumbButtonView sizeToFit];
  float newPosition = valuePrecentage * [self _sliderTravelDistance] + [self _sliderBeginTravelDistance];
  _thumbButtonView.position = CGPointMake(newPosition, CGRectGetMidY(self.bounds));
  
  self.popoverView.bounds = CGRectMake(0, 0, kPZSliderPopoverSquareSize, kPZSliderPopoverSquareSize);
  self.popoverView.position = CGPointMake(newPosition, CGRectGetMinY(_thumbButtonView.frame));
  self.popoverContentView.position = CGPointMake(12.0, 10.0);  // asset based
  self.popoverContentView.bounds = [[self class] popoverContentViewBounds];
  
  _shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - 2 * kPZSliderBarLeftRightPadding, _barHeight) cornerRadius:_barCornerRadius].CGPath;
  
  _backgroundLayer.bounds = CGRectMake(0, 0 , CGRectGetWidth(self.bounds) - 2 * kPZSliderBarLeftRightPadding, kPZSliderBarHeight);
  _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  UITouch *touch = [[event allTouches] anyObject];
  CGPoint location = [touch locationInView:touch.view];
  if (CGRectContainsPoint(_thumbButtonView.frame, location)) {
    _lastMovingPoint = location;
    _thumbButtonView.highlighted = YES;
    [self _sliderEventDidPress];
    [self becomeFirstResponder];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  if (_thumbButtonView.highlighted) {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    [self _handleMovingThumbWithLocation:location];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  if (_thumbButtonView.highlighted) {
    _thumbButtonView.highlighted = NO;
    [self _sliderEventDidRelieve];
    _lastMovingPoint = CGPointZero;
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  if (_thumbButtonView.highlighted && _panGesture.state != UIGestureRecognizerStateBegan) {
    _thumbButtonView.highlighted = NO;
    [self _sliderEventDidRelieve];
  }
}

- (void)_handlePan:(UIPanGestureRecognizer *)panGesture
{
  if (CGRectContainsPoint(_thumbButtonView.frame, [panGesture locationInView:self]) || _thumbButtonView.highlighted) {
    _thumbButtonView.highlighted = panGesture.state != UIGestureRecognizerStateEnded;
    if (panGesture.state == UIGestureRecognizerStateBegan) {
      _lastMovingPoint = [panGesture locationInView:self];
      [self _sliderEventDidPress];
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
      [self _sliderEventDidRelieve];
    } else {
      [self _handleMovingThumbWithLocation:[panGesture locationInView:self]];
    }
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return YES;
}

#pragma mark -
#pragma mark - Private method

- (CGFloat)_sliderTravelDistance
{
  return CGRectGetWidth(self.bounds) - CGRectGetWidth(_thumbButtonView.bounds);
}

- (CGFloat)_sliderBeginTravelDistance
{
  return CGRectGetMidX(_thumbButtonView.bounds);
}

- (CGFloat)_sliderEndTravelDistance
{
  return CGRectGetWidth(self.bounds) - CGRectGetMidX(_thumbButtonView.bounds);
}

- (void)_handleMovingThumbWithLocation:(CGPoint)location
{
  CGFloat newXPoint = _thumbButtonView.position.x + location.x - _lastMovingPoint.x - [self _sliderBeginTravelDistance];
  // restrict the new point inside the begin and end range
  newXPoint = MIN(newXPoint, [self _sliderTravelDistance]);
  newXPoint = MAX(newXPoint, 0);
  float relativePosition = newXPoint / [self _sliderTravelDistance];
  [self setValue:relativePosition * (_maximumValue - _minimumValue) + _minimumValue];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  _lastMovingPoint = location;
}

#pragma mark -
#pragma mark - Target/Action

- (void)_sliderEventDidRelieve
{
  if (self.popover) {
    [UIView animateWithDuration:0.3 animations:^{
      self.popoverView.alpha = 0.0;
    }];
  }
}

- (void)_sliderEventDidPress
{
  if (self.popover) {
    [UIView animateWithDuration:0.3 animations:^{
      self.popoverView.alpha = 1.0;
    }];
  }
}

#pragma mark -
#pragma mark - Class method

+ (CGFloat)sliderHeightForSlider:(PZSlider *)slider
{
  CGFloat thumbImageHeigh = [[slider thumbImageForState:UIControlStateNormal] size].height;
  thumbImageHeigh = MAX(thumbImageHeigh, [[slider thumbImageForState:UIControlStateHighlighted] size].height);
  return thumbImageHeigh;
}

+ (CGRect)popoverContentViewBounds
{
  return CGRectMake(0, 0, kPZSliderPopoverContentSizeInWidth, kPZSliderPopoverContentSizeInHeight);
}
@end
