//
//  AutoPurgeCache.m
//  org.qii.airbooru
//
//  Created by qii on 1/16/15.
//  Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "AutoPurgeCache.h"
#import "ImageHelper.h"
#import "FileHelper.h"

@interface AutoPurgeCache () <NSCacheDelegate>
@property(assign, nonatomic) long long cost;
@end

@implementation AutoPurgeCache
- (id)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        self.delegate = weakSelf;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    [super setObject:obj forKey:key cost:g];
    self.cost += g;
    NSLog(@"AutoPurgeCache current cost is %@/%@", [FileHelper getFormatLength:self.cost], [FileHelper getFormatLength:(long long) self.totalCostLimit]);
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if ([obj isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *) obj;
        long long cost = [ImageHelper calcImageMemCacheCost:image];
        NSLog(@"AutoPurgeCache evict's object size is %@", [FileHelper getFormatLength:cost]);
        self.cost -= cost;
    }

//    NSLog(@"ImageLoader evict UIImage, cost is %llu/%tu", self.cost, self.totalCostLimit);
    NSLog(@"AutoPurgeCache evict UIImage, cost is %@/%@", [FileHelper getFormatLength:self.cost], [FileHelper getFormatLength:(long long) self.totalCostLimit]);
}
@end
