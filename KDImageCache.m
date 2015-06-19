//
//  BBNetworkingImageManager.m
//  KD
//
//  Created by Blankwonder on 12/31/12.
//  Copyright (c) 2012 IEEE. All rights reserved.
//

#import "KDImageCache.h"
#import "KDUtilities.h"
#import "KDLogger.h"
#import <objc/runtime.h>

@interface __KDImageCacheOperation : NSObject
@property (readonly) NSMutableArray *completionBlocks;
@property (readonly) NSString *imageURL;
@property (readwrite, strong) NSURLSessionDataTask *dataTask;
@end

@implementation __KDImageCacheOperation
- (id)initWithURL:(NSString *)URL {
    self = [super init];
    if (self) {
        _imageURL = URL;
        _completionBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)invokeCompletionBlocksWithResult:(UIImage *)result {
    for (KDImageCacheCompleteBlock block in _completionBlocks) {
        block(result, _imageURL);
    }
}


@end

@implementation KDImageCache

+ (KDImageCache *)sharedInstance {
    static dispatch_once_t pred;
    __strong static KDImageCache *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[KDImageCache alloc] init];
    });

    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _requestOperationMap = [NSMutableDictionary dictionary];
        _cachedImageMap = [NSMutableDictionary dictionary];

        _maxMemoryCachedImage = 100;
        
        NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KDImageCache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];

        _cachedImagePath = cachePath;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanExpiredCache)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (UIImage *)imageFromCacheWithURL:(NSString *)imageURL {
    UIImage *cachedImage = _cachedImageMap[imageURL];
    if (cachedImage){
        return cachedImage;
    }
    UIImage *localImage = [self localCacheImageForURL:imageURL];
    if (localImage) {
        [self addImageInMemoryCached:localImage URL:imageURL];
        return localImage;
    }

    return nil;
}

- (void)loadImageWithURL:(NSString *)imageURL
                completion:(KDImageCacheCompleteBlock)completion {
    if (!KDUtilIsStringValid(imageURL) || ![NSURL URLWithString:imageURL]) return;
    if (!completion) return;

    UIImage *cachedImage = [self imageFromCacheWithURL:imageURL];
    if (cachedImage) {
        completion(cachedImage, imageURL);
        return;
    }

    __KDImageCacheOperation *operation = _requestOperationMap[imageURL];
    if (!operation) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURL]];
        operation = [[__KDImageCacheOperation alloc] initWithURL:imageURL];

        NSURLSessionDataTask *task =
        [[NSURLSession sharedSession]
         dataTaskWithRequest:request
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (error) {
                 KDClassLog(@"Request failed: %@", error);
                 
                 dispatch_async( dispatch_get_main_queue(),^{
                     [operation invokeCompletionBlocksWithResult:nil];
                 });
             } else {
                 UIImage *image = [UIImage imageWithData:data];
                 if (image) {
                     [data writeToFile:[self localCachePathForURL:imageURL] atomically:YES];

                     dispatch_async( dispatch_get_main_queue(),^{
                         [self addImageInMemoryCached:image URL:imageURL];
                         [operation invokeCompletionBlocksWithResult:image];
                     });
                 } else {
                     KDClassLog(@"Received invalid image: %@", imageURL);
                     
                     dispatch_async( dispatch_get_main_queue(),^{
                         [operation invokeCompletionBlocksWithResult:nil];
                     });
                 }
             }
             [_requestOperationMap removeObjectForKey:imageURL];
         }];
        [task resume];

        operation.dataTask = task;

        _requestOperationMap[imageURL] = operation;
    }
    
    [operation.completionBlocks addObject:completion];
}

- (NSString *)localCacheFileNameForURL:(NSString *)URL {
    return (__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)URL, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)localCachePathForURL:(NSString *)URL {
    return [_cachedImagePath stringByAppendingPathComponent:[self localCacheFileNameForURL:URL]];
}

- (UIImage *)localCacheImageForURL:(NSString *)URL {
    if (!_cachedImagePath) return nil;
    NSString *localPath = [self localCachePathForURL:URL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error;

        [[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate: [NSDate date]}
                                         ofItemAtPath:localPath error:&error];

        if (error) {
            KDClassLog(@"Error occurred when update file modification date: %@", error);
        }

        return [UIImage imageWithContentsOfFile:localPath];
    } else {
        return nil;
    }
}

- (void)setCachedImageData:(NSData *)data
                    forURL:(NSString *)URL {
    NSString *path = [[KDImageCache sharedInstance] localCachePathForURL:URL];
    [data writeToFile:path atomically:YES];
    UIImage *image = [UIImage imageWithData:data];
    [self addImageInMemoryCached:image URL:URL];
}

- (void)didReceiveMemoryWarning {
    [_cachedImageMap removeAllObjects];
}

- (void)cleanExpiredCache {
    for (NSString *path in [[NSFileManager defaultManager] subpathsAtPath:_cachedImagePath]) {
        NSString *fullPath = [_cachedImagePath stringByAppendingPathComponent:path];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];

        if (- [[attributes fileModificationDate] timeIntervalSinceNow] > 60 * 60 * 24 * 30) {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }
    }
}

- (void)cleanAllDiskCache {
    [[NSFileManager defaultManager] removeItemAtPath:_cachedImagePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachedImagePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)addImageInMemoryCached:(UIImage *)image URL:(NSString *)URL {
    if (_cachedImageMap.count >= _maxMemoryCachedImage) {
        [_cachedImageMap removeAllObjects];
    }
    
    _cachedImageMap[URL] = image;
}

- (void)setCachedImagePath:(NSString *)cachedImagePath {
    _cachedImagePath = cachedImagePath;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachedImagePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachedImagePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            KDClassLog(@"Error occurred when create directory: %@", error);
        }
    }
}

KDUtilRemoveNotificationCenterObserverDealloc

@end

@implementation UIImageView (KDImageCache)

static char __KDImageCacheAssociatedOperation;

- (void)KD_setImageWithURL:(NSString *)imageURL {
    objc_setAssociatedObject(self,
                             &__KDImageCacheAssociatedOperation,
                             imageURL,
                             OBJC_ASSOCIATION_RETAIN);
            
    UIImageView *weakself = self;
    
    [[KDImageCache sharedInstance] loadImageWithURL:imageURL completion:^(UIImage *image, NSString *imageURL) {
        if (weakself && objc_getAssociatedObject(weakself, &__KDImageCacheAssociatedOperation) == imageURL) {
            objc_setAssociatedObject(weakself,
                                     &__KDImageCacheAssociatedOperation,
                                     nil,
                                     OBJC_ASSOCIATION_RETAIN);
            
            if (image) {
                if (weakself.layer.shouldRasterize) {
                    CGFloat scale = weakself.layer.rasterizationScale;
                    [weakself setImage:image];
                    weakself.layer.rasterizationScale = scale;
                } else {
                    [weakself setImage:image];
                }
            }
        }
    }];
    
}

@end