//
//  ICCVENetworkingImageManager.h
//  ICCVE
//
//  Created by Blankwonder on 12/31/12.
//  Copyright (c) 2012 IEEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^KDImageCacheCompleteBlock)(UIImage *image, NSString *imageURL);


@interface UIImageView (KDImageCache)
- (void)KD_setImageWithURL:(NSString *)imageURL;
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

- (void)loadImageWithURL:(NSString *)imageURL
              completion:(KDImageCacheCompleteBlock)completion;

- (UIImage *)imageFromCacheWithURL:(NSString *)imageURL;

- (void)cleanAllDiskCache;

@property (nonatomic, copy) NSString *cachedImagePath;
@property (nonatomic) NSInteger maxMemoryCachedImage;

@end

