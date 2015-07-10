//
//  KDSelectionViewController.h
//  Kata
//
//  Created by blankwonder on 7/8/15.
//  Copyright (c) 2015 Daxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDSelectionViewController : UITableViewController

- (instancetype)initWithOptions:(NSArray *)options;

@property (nonatomic, copy) void(^cellSetupBlock)(UITableViewCell *cell);
@property (nonatomic, copy) void(^completionHandler)(NSString *result, NSInteger index);

@end
