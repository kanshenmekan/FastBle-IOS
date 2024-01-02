//
//  BleLruDictionary.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import "HYHBleLruDictionary.h"
@interface HYHBleLruDictionary()
@property (strong,nonatomic) NSMutableArray *keys;
@end

@implementation HYHBleLruDictionary
- (instancetype)initWithMaximumCapacity:(NSInteger)maximumCapacity{
    if (self = [super init]) {
        _keys = [NSMutableArray array];
        _maximumCapacity = maximumCapacity;
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (![self objectForKey:aKey]) {
        // 如果 key 不存在，则将 key 存入数组头部
        [_keys insertObject:aKey atIndex:0];
    }
    else {
        // 如果 key 存在，则将其移动到数组头部
        [_keys removeObject:aKey];
        [_keys insertObject:aKey atIndex:0];
    }
    
    // 超过最大容量时，移除最久未使用的元素
    if ([_keys count] > _maximumCapacity) {
        id<NSCopying> lastKey = [_keys lastObject];
        [self removedEldestEntry:lastKey];
        [self removeObjectForKey:lastKey];
    }
    [super setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [_keys removeObject:aKey];
    [super removeObjectForKey:aKey];
}
- (void)removeAllObjects{
    [_keys removeAllObjects];
    [super removeAllObjects];
}
- (void)removedEldestEntry:(id)aKey{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bleLruDictionary:removeEldestEntry:)]) {
        [self.delegate bleLruDictionary:self removeEldestEntry:[self objectForKey:aKey]];
    }
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ maximumCapacity = %ld",[super description],self.maximumCapacity];
}
@end
