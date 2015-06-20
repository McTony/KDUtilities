//
//  KDCircleImageView.m
//  
//
//  Created by Blankwonder on 6/19/15.
//
//

#import "KDCircleImageView.h"

@implementation KDCircleImageView

- (void)layoutSubviews {
    self.layer.cornerRadius = self.bounds.size.width / 2.0f;
    self.layer.masksToBounds = YES;
}

@end
