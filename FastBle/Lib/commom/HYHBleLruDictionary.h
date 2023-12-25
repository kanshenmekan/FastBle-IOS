//
//  BleLruDictionary.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import <Foundation/Foundation.h>
#import "HYHThreadSafeDictionary.h"
NS_ASSUME_NONNULL_BEGIN
@class HYHBleLruDictionary;
@protocol HYHBleLruDictionaryDelegate <NSObject>

-(void)bleLruDictionary:(HYHBleLruDictionary *)dictionary removeEldestEntry:(id)entry;

@end

@interface HYHBleLruDictionary<__covariant KeyType, __covariant ObjectType> : HYHThreadSafeDictionary<KeyType,ObjectType>
@property (nonatomic, assign) NSUInteger maximumCapacity;
-(instancetype)initWithMaximumCapacity:(NSInteger)maximumCapacity;
@property (weak,nonatomic) id<HYHBleLruDictionaryDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
