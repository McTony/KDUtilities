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
    
    NSArray *_cells;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_cells) {
        _cells = [_options KD_arrayUsingMapEnumerateBlock:^id(id obj, NSUInteger idx) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            cell.textLabel.text = obj;
            
            if (self.cellSetupBlock) {
                self.cellSetupBlock(cell, obj, idx);
            }
            
            return cell;
        }];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cells[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completionHandler) {
        self.completionHandler(_options[indexPath.row], indexPath.row);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _footerText;
}

- (void)setFooterText:(NSString *)footerText {
    _footerText = [footerText copy];
    
    [self.tableView reloadData];
}

@end
