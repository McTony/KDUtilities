//
//  UIImage+ProportionalFill.h
//

#import <UIKit/UIKit.h>

@interface UIImage (KDUtilities)

+ (UIImage *)KD_imageWithColor:(UIColor *)color;
+ (UIImage *)KD_imageWithColor:(UIColor *)color andSize:(CGSize)size;

- (UIImage *)KD_imageByCroppedToSquare:(CGFloat)fitSize;

- (UIImage *)KD_imageWithMaskColor:(UIColor *)color;

@end
