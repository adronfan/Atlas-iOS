//
//  LYRUIProgressView.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LYRUIProgressView.h"

float LYRUIDegreeToRadians(float degrees)
{
    return ((M_PI * degrees)/ 180);
}

NSString *LYRUIProgressViewStringForIconStyle(LYRUIProgressViewIconStyle iconStyle)
{
    switch (iconStyle) {
        case LYRUIProgressViewIconStyleDownload:
            return @"▼";

        case LYRUIProgressViewIconStyleUpload:
            return @"▲";

        case LYRUIProgressViewIconStylePause:
            return @"❚❚";

        case LYRUIProgressViewIconStyleStop:
            return @"⬛︎";

        case LYRUIProgressViewIconStylePlay:
            return @"▶︎";

        case LYRUIProgressViewIconStyleError:
            return @"✕";

        default:
            return @"";
    }
}

@interface LYRUIProgressView ()

@property (nonatomic) CAShapeLayer *backRingLayer;
@property (nonatomic) CAShapeLayer *progressRingLayer;
@property (nonatomic) CATextLayer *iconLayer;
@property (nonatomic) UIBezierPath *progressArcPath;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, readonly) CGFloat radius;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) double progress;
@property (nonatomic) UIColor *backgroundRingColorUpload;
@property (nonatomic) UIColor *foregroundRingColorUpload;
@property (nonatomic) UIColor *iconColorUpload;
@property (nonatomic) UIColor *backgroundRingColorDownload;
@property (nonatomic) UIColor *foregroundRingColorDownload;
@property (nonatomic) UIColor *iconColorDownload;

@end

@implementation LYRUIProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidth = 8.0f;
        _progress = 0.0f;
        _animationDuration = 0.25f;
        _backRingLayer = [CAShapeLayer layer];
        _progressRingLayer = [CAShapeLayer layer];
        _iconLayer = [CATextLayer layer];
        [self.layer addSublayer:_backRingLayer];
        [self.layer addSublayer:_progressRingLayer];
        [self.layer addSublayer:_iconLayer];
        _backgroundRingColorUpload = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:0.3f];
        _foregroundRingColorUpload = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:0.5f];
        _iconColorUpload = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:0.3f];
        _backgroundRingColorDownload = [UIColor colorWithWhite:0.8f alpha:0.8f];
        _foregroundRingColorDownload = [UIColor colorWithWhite:1.0f alpha:0.9f];
        _iconColorDownload = [UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                                                        radius:self.radius / 2 - self.borderWidth / 2
                                                    startAngle:LYRUIDegreeToRadians(0 - 90)
                                                      endAngle:LYRUIDegreeToRadians(360 - 90)
                                                     clockwise:YES];
    _progressRingLayer.frame = self.bounds;
    _progressRingLayer.lineWidth = self.borderWidth;
    _progressRingLayer.path = path.CGPath;
    _progressRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _progressRingLayer.fillColor = [UIColor clearColor].CGColor;
    _progressRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _progressRingLayer.strokeEnd = self.progress;

    _backRingLayer.frame = self.bounds;
    _backRingLayer.strokeColor = [UIColor colorWithWhite:0.8f alpha:0.5f].CGColor;
    _backRingLayer.lineWidth = self.borderWidth;
    _backRingLayer.path = path.CGPath;
    _backRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _backRingLayer.fillColor = [UIColor clearColor].CGColor;
    _backRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _backRingLayer.strokeEnd = 1.0f;

    _iconLayer.frame = CGRectOffset(self.bounds, 0, (self.bounds.size.height / 5.5));
    _iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _iconLayer.alignmentMode = kCAAlignmentCenter;
    _iconLayer.opacity = self.iconStyle == LYRUIProgressViewIconStyleNone ? 0.0f : 1.0f;
    _iconLayer.string = LYRUIProgressViewStringForIconStyle(self.iconStyle);

    if (self.iconStyle == LYRUIProgressViewIconStyleUpload) {
        _backRingLayer.strokeColor = _backgroundRingColorUpload.CGColor;
        _progressRingLayer.strokeColor = _foregroundRingColorUpload.CGColor;
        _iconLayer.foregroundColor = _iconColorUpload.CGColor;
    } else {
        _backRingLayer.strokeColor = _backgroundRingColorDownload.CGColor;
        _progressRingLayer.strokeColor = _foregroundRingColorDownload.CGColor;
        _iconLayer.foregroundColor = _iconColorDownload.CGColor;
    }
}

- (CGFloat)radius
{
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (void)setProgress:(double)newProgress animated:(BOOL)animated
{
    self.progressRingLayer.strokeEnd = newProgress;
    _progress = newProgress;
}

- (void)setIconStyle:(LYRUIProgressViewIconStyle)iconStyle
{
    // Set the color based on the icon type (it it's upload or anything else)
    if (iconStyle == LYRUIProgressViewIconStyleUpload) {
        _backRingLayer.strokeColor = _backgroundRingColorUpload.CGColor;
        _progressRingLayer.strokeColor = _foregroundRingColorUpload.CGColor;
        _iconLayer.foregroundColor = _iconColorUpload.CGColor;
    } else {
        _backRingLayer.strokeColor = _backgroundRingColorDownload.CGColor;
        _progressRingLayer.strokeColor = _foregroundRingColorDownload.CGColor;
        _iconLayer.foregroundColor = _iconColorDownload.CGColor;
    }

    if (self.iconStyle == LYRUIProgressViewIconStyleNone && iconStyle != LYRUIProgressViewIconStyleNone) {
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration = self.animationDuration;
        fadeInAnimation.fillMode = kCAFillModeForwards;
        fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        self.iconLayer.opacity = 1.0f;
        [self.iconLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    } else if (self.iconStyle != LYRUIProgressViewIconStyleNone && iconStyle == LYRUIProgressViewIconStyleNone) {
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.duration = self.animationDuration;
        fadeOutAnimation.fillMode = kCAFillModeForwards;
        fadeOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeOutAnimation.removedOnCompletion = NO;
        fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        self.iconLayer.opacity = 0.0f;
        [self.iconLayer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    }
    
    NSString *iconString = LYRUIProgressViewStringForIconStyle(iconStyle);
    if (iconStyle) {
        self.iconLayer.string = iconString;
    }
    _iconStyle = iconStyle;
}

@end