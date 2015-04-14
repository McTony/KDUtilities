//
// KDXProgressHUD.m
// Version 0.4
// Created by Matej Bukovinski on 2.4.09.
//

#import "KDProgressHUD.h"
#import "UILabel+ResizeHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation KDProgressHUD

- (void)setMode:(KDXProgressHUDMode)newMode {
    if (mode != newMode) {
        mode = newMode;
        [self updateIndicators];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (KDXProgressHUDMode)mode {
	return mode;
}

- (void)setLabelText:(NSString *)newText {
    if (![_label.text isEqualToString:newText]) {
        _label.text = [newText copy];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (NSString *)labelText {
	return _label.text;
}

- (void)setDetailsLabelText:(NSString *)newText {
    if (![_detailsLabel.text isEqualToString:newText]) {
        _detailsLabel.text = [newText copy];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (NSString *)detailsLabelText {
	return _detailsLabel.text;
}

- (void)setProgress:(float)newProgress {
    // Update display ony if showing the determinate progress view
    if (mode == KDXProgressHUDModeDeterminate) {
        [(MBRoundProgressView *)_indicatorView setProgress:newProgress];
        [self setNeedsDisplay];
    }
}

- (float)progress {
    if (mode == KDXProgressHUDModeDeterminate) {
        return [(MBRoundProgressView *)_indicatorView progress];
    } else {
        return 0;
    }
}

- (void)setCustomView:(UIView *)customView {
    if (customView == _customView) return;
    _customView = customView;
    self.mode = KDXProgressHUDModeCustomView;
}

- (void)updateIndicators {
    if (_indicatorView) {
        [_indicatorView removeFromSuperview];
    }
	
    if (mode == KDXProgressHUDModeDeterminate) {
        _indicatorView = [[MBRoundProgressView alloc] init];
    } else if (mode == KDXProgressHUDModeCustomView && _customView) {
        _indicatorView = _customView;
    } else {
		_indicatorView = [[UIActivityIndicatorView alloc]
						   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [(UIActivityIndicatorView *)_indicatorView startAnimating];
	}
	
	
    [self addSubview:_indicatorView];
}

- (UIView *)customView { return _customView; }

#pragma mark -
#pragma mark Constants

#define PADDING 4.0f

+ (KDProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
	KDProgressHUD *hud = [[KDProgressHUD alloc] initWithView:view];
	[view addSubview:hud];
	[hud showAnimated:animated];
	return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
	UIView *viewToRemove = nil;
	for (UIView *v in [view subviews]) {
		if ([v isKindOfClass:[KDProgressHUD class]]) {
			viewToRemove = v;
            break;
		}
	}
	if (viewToRemove != nil) {
		KDProgressHUD *HUD = (KDProgressHUD *)viewToRemove;
		HUD.removeFromSuperViewOnHide = YES;
		[HUD hideAnimated:animated];
		return YES;
	} else {
		return NO;
	}
}

- (id)initWithView:(UIView *)view {
	// Let's check if the view is nil (this is a common error when using the windw initializer above)
	if (!view) {
		[NSException raise:@"KDXProgressHUDViewIsNillException" 
					format:@"The view used in the KDXProgressHUD initializer is nil."];
	}
	id me = [self initWithFrame:view.bounds];
	// We need to take care of rotation ourselfs if we're adding the HUD to a window
	if ([view isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:NO];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	
	return me;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        // Set default values for properties
        self.animationType = KDXProgressHUDAnimationZoom;
        self.mode = KDXProgressHUDModeIndeterminate;
        self.opacity = 0.8f;
        [self updateIndicators];
        
        _xOffset = 0.0f;
        _yOffset = 0.0f;
		_dimBackground = NO;
		_margin = 20.0f;
		_removeFromSuperViewOnHide = YES;
		
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
		
        // Make invisible for now
        self.alpha = 0.0f;
		
        // Add label
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.adjustsFontSizeToFitWidth = NO;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:16];

        // Add details label
        _detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _detailsLabel.adjustsFontSizeToFitWidth = NO;
        _detailsLabel.textAlignment = NSTextAlignmentCenter;
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.textColor = [UIColor whiteColor];
        _detailsLabel.font = [UIFont boldSystemFontOfSize:12];
        
		rotationTransform = CGAffineTransformIdentity;
    }
    return self;
}

- (void)dealloc {
    [self.layer removeAllAnimations];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
	
    // Compute HUD dimensions based on indicator size (add margin to HUD border)
    CGRect indFrame = _indicatorView.bounds;
    _width = indFrame.size.width + 2 * _margin;
    _height = indFrame.size.height + 2 * _margin;
	
    // Position the indicator
    indFrame.origin.x = floorf((frame.size.width - indFrame.size.width) / 2) + _xOffset;
    indFrame.origin.y = floorf((frame.size.height - indFrame.size.height) / 2) + _yOffset;
    
	
    // Add label if label text was set
    if (_label.text.length) {
        // Get size of label text
        CGSize textSize = [_label.text KD_sizeWithAttributeFont:_label.font];
		
        // Compute label dimensions based on font metrics if size is larger than max then clip the label width
        float lHeight = textSize.height;
        float lWidth;
        if (textSize.width <= (frame.size.width - 2 * _margin)) {
            lWidth = textSize.width;
        }
        else {
            lWidth = frame.size.width - 4 * _margin;
        }
		
        // Update HUD size
        if (_width < (lWidth + 2 * _margin)) {
            _width = lWidth + 2 * _margin;
        }
        _height += lHeight + PADDING;
		
        // Move indicator to make room for the label
        indFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
		
        // Set the label position and dimensions
        CGRect lFrame = CGRectMake(floorf((frame.size.width - lWidth) / 2) + _xOffset,
                                   floorf(indFrame.origin.y + indFrame.size.height + PADDING),
                                   lWidth, lHeight);
        _label.frame = lFrame;
		
        [self addSubview:_label];
		
        // Add details label delatils text was set
        if (_detailsLabel.text.length) {
            // Get size of label text
            CGSize textSize = [self.detailsLabelText KD_sizeWithAttributeFont:_detailsLabel.font];
			
            // Compute label dimensions based on font metrics if size is larger than max then clip the label width
            lHeight = textSize.height;
            if (textSize.width <= (frame.size.width - 2 * _margin)) {
                lWidth = textSize.width;
            }
            else {
                lWidth = frame.size.width - 4 * _margin;
            }
			
            // Update HUD size
            if (_width < lWidth + 2 * _margin)
                _width = lWidth + 2 * _margin;
            _height += lHeight + PADDING;
			
            // Move indicator to make room for the new label
            indFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
			
            // Move first label to make room for the new label
            lFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
            _label.frame = lFrame;
			
            // Set label position and dimensions
            CGRect lFrameD = CGRectMake(floorf((frame.size.width - lWidth) / 2) + _xOffset,
                                        lFrame.origin.y + lFrame.size.height + PADDING, lWidth, lHeight);
            _detailsLabel.frame = lFrameD;
			
            [self addSubview:_detailsLabel];
        }
    }

    _indicatorView.frame = indFrame;
}

- (void)showAnimated:(BOOL)animated {
    self.alpha = 0.0f;
    if (animated && _animationType == KDXProgressHUDAnimationZoom) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0f;
            if (_animationType == KDXProgressHUDAnimationZoom) {
                self.transform = rotationTransform;
            }
        }];
    }
    else {
        self.alpha = 1.0f;
    };
}

- (void)hideAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            if (_animationType == KDXProgressHUDAnimationZoom) {
                self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
            }
            self.alpha = 0.02f;
        } completion:^(BOOL finished) {
            self.alpha = 0.0f;
            [self hidden];
        }];
    } else {
        self.alpha = 0.0f;
        [self hidden];
    };
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
	[self performSelector:@selector(hideDelayed:) withObject:@(animated) afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
	[self hideAnimated:[animated boolValue]];
}

- (void)hidden {
    if (self.hiddenBlock) {
        self.hiddenBlock(self);
    }
	
	if (_removeFromSuperViewOnHide) {
		[self removeFromSuperview];
	}
}

- (void)applySuccessStyle {
    self.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_success"]];
}

- (void)applyFailureStyle {
    self.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_fail"]];;
}

- (void)drawRect:(CGRect)rect {
	
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (_dimBackground) {
        //Gradient colours
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.0f, 1.0f};
        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
		CGColorSpaceRelease(colorSpace);
        
        //Gradient center
        CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        //Gradient radius
        float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter,
                                     0, gradCenter, gradRadius,
                                     kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
    }    
    
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake(roundf((allRect.size.width - _width) / 2) + _xOffset,
                                roundf((allRect.size.height - _height) / 2) + _yOffset, _width, _height);
	// Corner radius
	float radius = 10.0f;

    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark -
#pragma mark Manual oritentation change

- (void)deviceOrientationDidChange:(NSNotification *)notification { 
	if (!self.superview) {
		return;
	}
	if ([self.superview isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:YES];
	}
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = 0;

	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { angle = -M_PI_2; }
		else { angle = M_PI_2; }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { angle = M_PI; } 
		else { angle = 0; }
	}
	
	rotationTransform = CGAffineTransformMakeRotation(angle);

	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self setTransform:rotationTransform];
	if (animated) {
		[UIView commitAnimations];
	}
}

@end

@implementation MBRoundProgressView

#pragma mark -
#pragma mark Accessors

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 37.0f, 37.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.1f); // translucent white
    CGContextSetLineWidth(context, 2.0f);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    // Draw progress
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width - 4) / 2;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end

