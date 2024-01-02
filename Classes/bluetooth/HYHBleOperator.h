//
//  HYHBleOperator.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHBleBluetooth.h"
#import "HYHBleOperateCallback.h"
NS_ASSUME_NONNULL_BEGIN
@class HYHBleReadCallback;
@class HYHBleNotifyCallback;
@class HYHBleWriteCallback;
@class HYHBleSplitWriter;
@class HYHBleRssiCallback;
extern NSInteger const HYHBleOperateWriteTypeDefault;
extern NSInteger const HYHBleOperateWriteSingleData;
@interface HYHBleOperator : NSObject
@property (weak,nonatomic) HYHBleBluetooth *bleBluetooth;
@property (strong,nonatomic,readonly) NSData *data;
@property (strong,nonatomic,readonly) CBCharacteristic *characteristic;
@property (strong,nonatomic,nullable) HYHBleOperateCallback *operateCallback;
@property (assign,nonatomic) NSInteger timeout;

- (instancetype)initWithBleBluetooth:(HYHBleBluetooth *)bleBluetooth characteristic:(nullable CBCharacteristic *)characteristic;
- (instancetype)initWithBleBluetooth:(HYHBleBluetooth *)bleBluetooth;
- (HYHBleOperator *)withServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;

- (void)readCharacteristic:(HYHBleReadCallback *)readCallback;
- (void)enableCharacteristicNotification:(HYHBleNotifyCallback *)notifyCallback;
- (void)disableCharacteristicNotification;

- (void)writeCharacteristic:(NSData *)data writeType:(CBCharacteristicWriteType)writeType bleWriteCallback:(HYHBleWriteCallback *)bleWriteCallback;
- (void)bindingSplitWriter:(HYHBleSplitWriter *)splitWriter;

- (void)readRssi:(HYHBleRssiCallback *)callback;
- (void)stopOperateTimer;
- (BOOL)valid;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
