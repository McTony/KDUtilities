//
//  ICCVENetworkingImageManager.h
//  ICCVE
//
//  Created by Blankwonder on 12/31/12.
//  Copyright (c) 2012 IEEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol KDImageCacheDelegate <NSObject>
@required
- (void)setImage:(UIImage *)image;
@end

@interface UIImageView (KDImageCache) <KDImageCacheDelegate>
@end

@interface KDImageCache : NSObject {
    NSMutableDictionary *_requestOperationMap;
    NSMutableDictionary *_cachedImageMap;
}

+ (KDImageCache *)sharedInstance;

- (NSString *)localCacheFileNameForURL:(NSString *)URL;
- (NSString *)localCachePathForURL:(NSString *)URL;

- (void)setCachedImageData:(NSData *)data
                    forURL:(NSString *)URL;

- (void)setImageViewContent:(id<KDImageCacheDelegate>)imageView
                    withURL:(NSString *)imageURL;

- (UIImage *)imageFromCacheWithURL:(NSString *)imageURL;

@property (nonatomic, copy) NSString *cachedImagePath;

@property (nonatomic) BOOL cleanAllDiskCacheWhenTerminating;

@end

