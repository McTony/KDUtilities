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

@interface __KDWeakReferenceObject : NSObject
@property (weak) id object;
@end

@implementation __KDWeakReferenceObject
- (id)initWithObject:(id)object {
    self = [self init];
    if (self) {
        self.object = object;
    }
    return self;
}
@end

static char __KDImageCacheAssociatedOperation;

@interface __KDImageCacheOperation : NSObject
@property (readonly) NSMutableArray *imageViews;
@property (readwrite, strong) NSURLSessionDataTask *dataTask;
@end

@implementation __KDImageCacheOperation
- (id)init {
    self = [super init];
    if (self) {
        _imageViews = [NSMutableArray array];
    }
    return self;
}

- (void)addImageView:(id)view {
    [_imageViews addObject:[[__KDWeakReferenceObject alloc] initWithObject:view]];

    objc_setAssociatedObject(view,
                             &__KDImageCacheAssociatedOperation,
                             self,
                             OBJC_ASSOCIATION_RETAIN);
}
- (void)setImageForImageViews:(UIImage *)image {
    for (__KDWeakReferenceObject *object in self.imageViews) {
        id <KDImageCacheDelegate> view = object.object;
        if (objc_getAssociatedObject(view, &__KDImageCacheAssociatedOperation) == self) {
            objc_setAssociatedObject(view,
                                     &__KDImageCacheAssociatedOperation,
                                     nil,
                                     OBJC_ASSOCIATION_RETAIN);
            [view setImage:image];
        }
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

        NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KDImageCache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];

        _cachedImagePath = cachePath;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanCache)
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
        _cachedImageMap[imageURL] = localImage;
        return localImage;
    }

    return nil;
}

- (void)setImageViewContent:(id<KDImageCacheDelegate>)imageView
                    withURL:(NSString *)imageURL {
    if (!KDUtilIsStringValid(imageURL) || ![NSURL URLWithString:imageURL]) return;
    if (!imageView) return;

    UIImage *cachedImage = [self imageFromCacheWithURL:imageURL];
    if (cachedImage) {
        objc_setAssociatedObject(imageView,
                                 &__KDImageCacheAssociatedOperation,
                                 nil,
                                 OBJC_ASSOCIATION_RETAIN);
        [imageView setImage:cachedImage];
        return;
    }

    __KDImageCacheOperation *operation = _requestOperationMap[imageURL];
    if (!operation) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURL]];
        operation = [[__KDImageCacheOperation alloc] init];

        NSURLSessionDataTask *task =
        [[NSURLSession sharedSession]
         dataTaskWithRequest:request
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (error) {
                 KDClassLog(@"Request failed: %@", error);
             } else {
                 UIImage *image = [UIImage imageWithData:data];
                 if (image) {
                     [data writeToFile:[self localCachePathForURL:imageURL] atomically:YES];

                     dispatch_async( dispatch_get_main_queue(),^{
                         _cachedImageMap[imageURL] = image;
                         [operation setImageForImageViews:image];
                     });
                 }
             }
             [_requestOperationMap removeObjectForKey:imageURL];
         }];
        [task resume];

        operation.dataTask = task;

        _requestOperationMap[imageURL] = operation;
    }
    [operation addImageView:imageView];
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
            KDClassLog(@"Error occurred when update file modification date: %@", error.localizedDescription);
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
    _cachedImageMap[URL] = image;
}

- (void)didReceiveMemoryWarning {
    [_cachedImageMap removeAllObjects];
}

- (void)cleanCache {
    for (NSString *path in [[NSFileManager defaultManager] subpathsAtPath:_cachedImagePath]) {
        NSString *fullPath = [_cachedImagePath stringByAppendingPathComponent:path];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];

        if (self.cleanAllDiskCacheWhenTerminating ||
            - [[attributes fileModificationDate] timeIntervalSinceNow] > 60 * 60 * 24 * 30) {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }
    }
}

KDUtilRemoveNotificationCenterObserverDealloc

@end
