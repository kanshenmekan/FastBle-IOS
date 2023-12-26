//
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class HYHBleBluetooth;
@class HYHBleOperatorQueue;
@interface HYHBleSequenceOperator : NSObject
@property (assign,nonatomic) BOOL continuous;
@property (assign,nonatomic) NSInteger timeout;
@property (assign,nonatomic) NSInteger delay;
@property (weak,nonatomic) HYHBleOperatorQueue *operatorQueue;
-(void)execute:(HYHBleBluetooth *)bleBluetooth;
@end

NS_ASSUME_NONNULL_END
