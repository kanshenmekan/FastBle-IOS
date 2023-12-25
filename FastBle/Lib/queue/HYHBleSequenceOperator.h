//
//  HYHBleOperateTask.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class HYHBleSequenceOperator;
@class HYHBleBluetooth;
@protocol HYHBleSequenceOperatorDelegate <NSObject>
@required
-(void)bleOperatorTaskEnd:(HYHBleSequenceOperator *)task result:(BOOL)result;
@end
@interface HYHBleSequenceOperator : NSObject
@property (weak,nonatomic) id<HYHBleSequenceOperatorDelegate> delegate;
@property (assign,nonatomic) BOOL continuous;
@property (assign,nonatomic) NSInteger timeout;
@property (assign,nonatomic) NSInteger delay;
-(void)execute:(HYHBleBluetooth *)bleBluetooth;
@end

NS_ASSUME_NONNULL_END
