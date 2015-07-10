//
//  KDSelectionViewController.m
//  Kata
//
//  Created by blankwonder on 7/8/15.
//  Copyright (c) 2015 Daxiang. All rights reserved.
//

#import "KDSelectionViewController.h"

@interface KDSelectionViewController () {
    NSArray *_options;
}

@end

@implementation KDSelectionViewController

- (instancetype)initWithOptions:(NSArray *)options {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _options = [options copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _options.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        if (self.cellSetupBlock) {
            self.cellSetupBlock(cell);
        }
    }
    
    cell.textLabel.text = _options[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completionHandler) {
        self.completionHandler(_options[indexPath.row], indexPath.row);
        self.completionHandler = nil;
    }
}

@end
