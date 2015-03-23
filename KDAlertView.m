//
//  KDAlertView.m
//  KDBlockAlert
//
//  Created by Blankwonder on 11/20/12.
//

#import "KDAlertView.h"
@interface KDAlertView(){
    NSMutableArray *_buttonTitleArray;
    NSMutableArray *_buttonActionBlockArray;
    
    NSString *_cancelButtonTitle;

    NSString *_title, *_message;

    UIAlertView *_systemAlertView;
}
@end

static NSMutableArray *ActiveInstances = nil;

@implementation KDAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                 cancelAction:(void ( ^)(KDAlertView *alertView))cancelAction {

    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        ActiveInstances = [NSMutableArray array];
    });

    self = [self init];
    if (self) {
        _buttonTitleArray = [NSMutableArray array];
        _buttonActionBlockArray = [NSMutableArray array];

        if (cancelButtonTitle) {
            _cancelButtonTitle = [cancelButtonTitle copy];
            [_buttonActionBlockArray addObject:cancelAction ? [cancelAction copy]: [NSNull null]];
        }

        _title = title;
        _message = message;

        _systemAlertView = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title action:(void ( ^)(KDAlertView *alertView))action {
    NSAssert(title, @"Title cannot be nil.");
    [_buttonTitleArray addObject:title];
    [_buttonActionBlockArray addObject:action ? [action copy] : [NSNull null]];
}

- (void)show {
    [ActiveInstances addObject:self];
    if (_cancelButtonTitle) {
        _systemAlertView.cancelButtonIndex = [_systemAlertView addButtonWithTitle:_cancelButtonTitle];
    }
    for (NSString *title in _buttonTitleArray) {
        [_systemAlertView addButtonWithTitle:title];
    }

    [_systemAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id actionBlock = _buttonActionBlockArray[buttonIndex];
    if (actionBlock && actionBlock != [NSNull null]) {
        void (^block)(KDAlertView *) = actionBlock;
        block(self);
    }

    _buttonActionBlockArray = nil;
    alertView.delegate = nil;
    [ActiveInstances removeObject:self];
}

- (UIAlertView *)systemAlertView {
    return _systemAlertView;
}

@end
