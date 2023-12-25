//
//  HYHSequenceWriteOperator.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/25.
//

#import "HYHBleSequenceOperator.h"
#import "HYHBleWriteCallback.h"
#import "HYHCentralManager.h"
NS_ASSUME_NONNULL_BEGIN
@interface HYHSequenceWriteOperator : HYHBleSequenceOperator
@property (strong,nonatomic) HYHBleWriteCallback *writeCallback;
@property (strong,nonatomic,readonly) CBUUID *serviceUUID;
@property (strong,nonatomic,readonly) CBUUID *characteristicUUID;
@property (copy,nonatomic) NSData *data;
@property (assign,nonatomic) BOOL split;
@property (assign,nonatomic) NSUInteger splitNum;
@property (assign,nonatomic) BOOL continueWhenLastFail;
@property (assign,nonatomic) NSInteger intervalBetweenTwoPackage;
@property (assign,nonatomic) NSInteger writeType;

- (instancetype)initWithServiceUUID:(CBUUID *)servceUUid characteristicUUID:(CBUUID *)characteristicUUID;
@end

NS_ASSUME_NONNULL_END
