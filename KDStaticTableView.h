//
//  GECalendarStaticTableView.h
//  GECalendar
//
//  Created by Blankwonder on 1/8/13.
//
//

#import <UIKit/UIKit.h>

@protocol KDStaticTableViewDataSource, KDStaticTableViewDelegate;

@interface KDStaticTableView : UIView {
    UIView *_selectMaskView;
}

@property (readonly, nonatomic) NSInteger numberOfRow;

- (void)reloadData;

@property (unsafe_unretained) id<KDStaticTableViewDataSource> dataSource;
@property (unsafe_unretained) id<KDStaticTableViewDelegate> delegate;

@property UIColor *separatorColor;
@property UIColor *separatorShadowColor;
@property UIColor *selectedMaskColor;

@property (getter = isSelectEnabled) BOOL selectEnabled;

@end


@protocol KDStaticTableViewDataSource<NSObject>
@required
- (NSInteger)tableView:(KDStaticTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UIView *)tableView:(KDStaticTableView *)tableView cellForRowAtIndex:(NSInteger)index;
@end

@protocol KDStaticTableViewDelegate<NSObject>
@required
- (void)tableViewDidChangeHeight:(KDStaticTableView *)tableView;
@optional
- (void)tableView:(KDStaticTableView *)tableView didSelectRowAtIndex:(NSInteger)index;
@end