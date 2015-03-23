//
//  KDAlertView.h
//  KDBlockAlert
//
//  Created by Blankwonder on 11/20/12.
//

#import <Foundation/Foundation.h>

@interface KDAlertView : NSObject

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                  cancelAction:(void ( ^)(KDAlertView *alertView))cancelAction;

- (void)addButtonWithTitle:(NSString *)title action:(void ( ^)(KDAlertView *alertView))action;
- (void)show;

- (UIAlertView *)systemAlertView;

@end
