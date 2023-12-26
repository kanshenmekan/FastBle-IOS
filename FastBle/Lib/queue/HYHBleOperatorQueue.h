//
//  HYHBleOperatorQueue.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import <Foundation/Foundation.h>
#import "HYHBleSequenceOperator.h"
#import "HYHBleBluetooth.h"
NS_ASSUME_NONNULL_BEGIN

@interface HYHBleOperatorQueue : NSObject
- (instancetype)initWithKey:(nonnull NSString *)key bleBluetooth:(HYHBleBluetooth *)bleBluetooth;
-(void)resume;
-(void)destroy;
-(void)clear;
-(void)remove:(HYHBleSequenceOperator *)operator;
-(void)pause;
-(void)offer:(HYHBleSequenceOperator *)sequenceOperator;
- (void)bleOperatorTaskEnd:(nonnull HYHBleSequenceOperator *)task result:(BOOL)result;
@end

NS_ASSUME_NONNULL_END
