#import <UIKit/UIKit.h>

typedef enum {
    KDXProgressHUDModeIndeterminate,
	KDXProgressHUDModeDeterminate,
	KDXProgressHUDModeCustomView
} KDXProgressHUDMode;

typedef enum {
    KDXProgressHUDAnimationFade,
    KDXProgressHUDAnimationZoom
} KDXProgressHUDAnimation;

@interface KDProgressHUD : UIView {
	KDXProgressHUDMode mode;
	
	BOOL useAnimation;

    CGFloat _width;
    CGFloat _height;
	
	UIView *_indicatorView;
	UILabel *_label;
	UILabel *_detailsLabel;
	
	UIView *_customView;
	
	CGAffineTransform rotationTransform;
}

+ (KDProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;
+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;
- (id)initWithView:(UIView *)view;

- (void)updateIndicators;
@property (nonatomic) UIView *customView;

@property (nonatomic) KDXProgressHUDMode mode;
@property (nonatomic) KDXProgressHUDAnimation animationType;

@property (copy) void(^hiddenBlock)(KDProgressHUD *hiddenHUD);

@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, copy) NSString *detailsLabelText;

@property (nonatomic) float opacity;
@property (nonatomic) float xOffset;
@property (nonatomic) float yOffset;
@property (nonatomic) float margin;
@property (nonatomic) BOOL dimBackground;
@property (nonatomic) BOOL removeFromSuperViewOnHide;

@property (nonatomic) float progress;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

- (void)applySuccessStyle;
- (void)applyFailureStyle;

@end

@interface MBRoundProgressView : UIView {
@private
    float _progress;
}

@property (nonatomic, assign) float progress;

@end

