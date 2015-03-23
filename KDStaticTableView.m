//
//  GECalendarStaticTableView.m
//  GECalendar
//
//  Created by Blankwonder on 1/8/13.
//
//

#import "KDStaticTableView.h"
#import "UIView+KDUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation KDStaticTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectMaskView = [[UIView alloc] init];
        _selectMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _selectMaskView.userInteractionEnabled = NO;

        _selectEnabled = YES;

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIColor *)selectedMaskColor { return _selectMaskView.backgroundColor; }
- (void)setSelectedMaskColor:(UIColor *)selectedMaskColor {
    _selectMaskView.backgroundColor = selectedMaskColor;
}

- (void)reloadData {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger row = [self.dataSource tableView:self numberOfRowsInSection:0];
    CGFloat YOffset = 0;
    for (int i = 0 ; i < row ; i++) {
        UIView *cell = [self.dataSource tableView:self cellForRowAtIndex:i];
        [cell KD_setFrameOriginX:0];
        [cell KD_setFrameOriginY:YOffset];
        YOffset += cell.frame.size.height;
        if (i != row - 1) {
            YOffset += 2;
        }
        [self addSubview:cell];
    }
    _numberOfRow = row;
    [self KD_setFrameSizeHeight:YOffset];
    [self.delegate tableViewDidChangeHeight:self];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    for (UIView *subview in self.subviews) {
        if (subview.frame.origin.y == 0) {
            continue;
        }
        
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextMoveToPoint(context, 0, subview.frame.origin.y - 2);
        CGContextAddLineToPoint(context, self.bounds.size.width, subview.frame.origin.y - 2);
        CGContextStrokePath(context);

        CGContextSetStrokeColorWithColor(context, self.separatorShadowColor.CGColor);
        CGContextMoveToPoint(context, 0, subview.frame.origin.y - 1);
        CGContextAddLineToPoint(context, self.bounds.size.width, subview.frame.origin.y - 1);
        CGContextStrokePath(context);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isSelectEnabled) {
        [self addSubview:_selectMaskView];
        _selectMaskView.frame = CGRectZero;
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        UIView *hitView = [self hitTest:location withEvent:event];
        if (hitView != self) {
            _selectMaskView.frame = CGRectMake(hitView.frame.origin.x, hitView.frame.origin.y - 2, hitView.frame.size.width, hitView.frame.size.height + 2);
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isSelectEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        UIView *hitView = [self hitTest:location withEvent:event];
        if (hitView != self) {
            _selectMaskView.frame = CGRectMake(hitView.frame.origin.x, hitView.frame.origin.y - 2, hitView.frame.size.width, hitView.frame.size.height + 2);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isSelectEnabled) {
        [_selectMaskView removeFromSuperview];
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        UIView *hitView = [self hitTest:location withEvent:event];
        if (hitView != self) {
            NSUInteger index = [self.subviews indexOfObject:hitView];
            if (index != NSNotFound) {
                [self.delegate tableView:self didSelectRowAtIndex:index];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isSelectEnabled) {
        [_selectMaskView removeFromSuperview];
    }
}

@end
