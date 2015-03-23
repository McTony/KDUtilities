//
//  KDActionSheet.h
//  KDBlockAlert
//
//  Created by Blankwonder on 11/20/12.
//

#import <UIKit/UIKit.h>

@interface KDActionSheet : NSObject

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
                 cancelAction:(void ( ^)())cancelAction
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            destructiveAction:(void ( ^)())destructiveAction;

- (void)addButtonWithTitle:(NSString *)title action:(void ( ^)())action;

- (void)showInView:(UIView *)view;
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

@end
