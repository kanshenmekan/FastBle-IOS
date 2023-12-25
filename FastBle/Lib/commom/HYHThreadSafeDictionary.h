//
//  HYHThreadSafeDictionary.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYHThreadSafeDictionary<__covariant KeyType, __covariant ObjectType> : NSObject<NSFastEnumeration>
+(instancetype) dictionary;
- (void)setObject:(ObjectType)object forKey:(KeyType<NSCopying>)key;
- (ObjectType)objectForKey:(KeyType<NSCopying>)key;
- (void)removeObjectForKey:(KeyType<NSCopying>)key;
- (BOOL)containKey:(KeyType<NSCopying>)key;
- (NSUInteger)count;
- (NSEnumerator *)keyEnumerator;
- (void)removeAllObjects;
- (id)copy;
@end

NS_ASSUME_NONNULL_END
