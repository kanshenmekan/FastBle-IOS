//
//  HYHThreadSafeDictionary.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import "HYHThreadSafeDictionary.h"
@interface HYHThreadSafeDictionary()
@property (strong,nonatomic) NSMutableDictionary *dictionary;
@property (strong,nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation HYHThreadSafeDictionary

+(instancetype)dictionary{
    HYHThreadSafeDictionary *dictionary = [[HYHThreadSafeDictionary alloc]init];
    return dictionary;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_dictionary setObject:object forKey:key];
    dispatch_semaphore_signal(_semaphore);
}

- (id)objectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    id object = [_dictionary objectForKey:key];
    dispatch_semaphore_signal(_semaphore);
    return object;
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_dictionary removeObjectForKey:key];
    dispatch_semaphore_signal(_semaphore);
}
- (NSUInteger)count {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSUInteger count = _dictionary.count;
    dispatch_semaphore_signal(_semaphore);
    return count;
}
- (NSEnumerator *)keyEnumerator{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSEnumerator *enu = [_dictionary keyEnumerator];
    dispatch_semaphore_signal(_semaphore);
    return enu;
}
- (void)removeAllObjects{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_dictionary removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}
- (id)copy{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    id copyInstance = [_dictionary copy];
    dispatch_semaphore_signal(_semaphore);
    return copyInstance;
}
- (BOOL)containKey:(id<NSCopying>)key{
    id obj = [self objectForKey:key];
    return obj != nil;
}
-(NSString *)description{
    return self.dictionary.description;
}
-(NSArray *)allValues{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSArray *values = _dictionary.allValues;
    dispatch_semaphore_signal(_semaphore);
    return values;
}
-(NSArray *)allKeys{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSArray *keys = _dictionary.allKeys;
    dispatch_semaphore_signal(_semaphore);
    return keys;
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    @synchronized (self) {
        return [self.dictionary countByEnumeratingWithState:state objects:buffer count:len];
    }
}
@end
