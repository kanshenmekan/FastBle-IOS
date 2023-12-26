//
//  HYHBleOperator.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHBleOperator.h"
#import "HYHTimepiece.h"
#import "CBPeripheral+HYHBle.h"
#import "HYHBleReadCallback.h"
#import "HYHBleNotifyCallback.h"
#import "HYHCentralManager.h"
#import "HYHBleSplitWriter.h"
NSInteger const HYHBleOperateWriteTypeDefault = -1;
NSInteger const HYHBleOperateWriteSingleData = 1;
@interface HYHBleOperator()
@property (strong,nonatomic) NSData *data;
@property (strong,nonatomic) CBCharacteristic *characteristic;
@property (strong,nonatomic) HYHTimepiece *operateTimer;
@property (strong,nonatomic) HYHBleSplitWriter *splitWriter;
@end

@implementation HYHBleOperator
-(instancetype)initWithBleBluetooth:(HYHBleBluetooth *)bleBluetooth characteristic:(nullable CBCharacteristic *)characteristic{
    if (self = [super init]) {
        self.bleBluetooth = bleBluetooth;
        self.characteristic = characteristic;
        self.timeout = HYHCentralManager.sharedBleManager.bleOption.operatorOverTime;
    }
    return self;
}
-(instancetype)initWithBleBluetooth:(HYHBleBluetooth *)bleBluetooth{
    return [self initWithBleBluetooth:bleBluetooth characteristic:nil];
}
-(HYHBleOperator *)withServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    if (self.bleBluetooth == nil) {
        return self;
    }
    self.characteristic = [self.bleBluetooth.bleDevice.peripheral getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    return self;
}
-(BOOL)valid{
    return self.bleBluetooth != nil;
}


-(void)startTimer{
    [self stopOperateTimer];
    if (self.timeout > 0) {
        __weak typeof(self) weakSelf = self;
        self.operateTimer = [HYHTimepiece scheduleWithTime:self.timeout timeoutBlock:^{
            if ([weakSelf valid]) {
                weakSelf.operateCallback.bleOperateTimeoutBlock(weakSelf.bleBluetooth.bleDevice, weakSelf.characteristic, [HYHBleError timeoutException], weakSelf.data);
            }
        }];
    }
}
-(void)stopOperateTimer{
    if (self.operateTimer && [self.operateTimer valid]) {
        [self.operateTimer cancelTimer];
        self.operateTimer.timeoutBlock = nil;
    }
}
#pragma mark - 蓝牙操作
-(void)readCharacteristic:(HYHBleReadCallback *)readCallback{
    if ([self valid] && self.characteristic) {
        if (self.characteristic.properties & CBCharacteristicPropertyRead) {
            self.operateCallback = readCallback;
            [self startTimer];
            [self.bleBluetooth addReadOperator:self];
            [self.bleBluetooth.bleDevice.peripheral readValueForCharacteristic:self.characteristic];
        }else{
            if (readCallback.bleReadFailureBlock) {
                readCallback.bleReadFailureBlock(self.bleBluetooth.bleDevice, self.characteristic, [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorCharacteristicsNotSupportCode localizedDescription:@"Characteristics Not Support Read"]);
            }
        }
    }
}
-(void)enableCharacteristicNotification:(HYHBleNotifyCallback *)notifyCallback{
    if ([self valid] && self.characteristic) {
        if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
            self.operateCallback = notifyCallback;
            [self startTimer];
            [self.bleBluetooth addNotifyOperator:self];
            [self.bleBluetooth.bleDevice.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        }else{
            if (notifyCallback.bleNotifyFailureBlock) {
                notifyCallback.bleNotifyFailureBlock(self.bleBluetooth.bleDevice, self.characteristic, [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorCharacteristicsNotSupportCode localizedDescription:@"Characteristics Not Support Notify"]);
            }
        }
    }
}
-(void)disableCharacteristicNotification{
    if ([self valid] && self.characteristic) {
        [self.bleBluetooth.bleDevice.peripheral setNotifyValue:NO forCharacteristic:self.characteristic];
    }
}
-(void)writeCharacteristic:(NSData *)data writeType:(CBCharacteristicWriteType)writeType bleWriteCallback:(HYHBleWriteCallback *)bleWriteCallback{
    self.data = data;
    if (data == nil) {
        return;
    }
    if ([self valid] && self.characteristic) {
        if (writeType == HYHBleOperateWriteTypeDefault) {
            if (self.characteristic.properties & CBCharacteristicPropertyWrite) {
                writeType = CBCharacteristicWriteWithResponse;
            }else if (self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
                writeType = CBCharacteristicWriteWithoutResponse;
            }
        }
        BOOL canWrite = NO;
        if (writeType == CBCharacteristicWriteWithoutResponse) {
            canWrite = self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse;
        }else if (writeType == CBCharacteristicWriteWithResponse){
            canWrite = self.characteristic.properties & CBCharacteristicPropertyWrite;
        }
        if (canWrite) {
            self.operateCallback = bleWriteCallback;
            [self.bleBluetooth addWriteOperator:self];
            if (writeType == CBCharacteristicWriteWithResponse) {
                [self startTimer];
                [self.bleBluetooth.bleDevice.peripheral writeValue:data forCharacteristic:self.characteristic type:writeType];
            }else if(writeType == CBCharacteristicWriteWithoutResponse){
                [self.bleBluetooth.bleDevice.peripheral writeValue:data forCharacteristic:self.characteristic type:writeType];
                //CBCharacteristicWriteWithoutResponse 不会触发didWriteValueForCharacteristic，手动执行
                [self.bleBluetooth peripheral:self.bleBluetooth.bleDevice.peripheral didWriteValueForCharacteristic:self.characteristic error:nil];
            }
        }else{
            if (bleWriteCallback.bleWriteFailureBlock) {
                bleWriteCallback.bleWriteFailureBlock(self.bleBluetooth.bleDevice, self.characteristic,  [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorCharacteristicsNotSupportCode localizedDescription:@"Characteristics Not Support this write type"], HYHBleOperateWriteSingleData, HYHBleOperateWriteSingleData, data, data, YES);
            }
        }
    }
}
-(void)bindingSplitWriter:(HYHBleSplitWriter *)splitWriter{
    self.splitWriter = splitWriter;
    splitWriter.weakBleOperator = self;
    [self.bleBluetooth addWriteOperator:self];
}
-(void)readRssi:(HYHBleRssiCallback *)callback{
    if([self valid]){
        self.operateCallback = callback;
        self.bleBluetooth.bleRssiOperator = self;
        [self.bleBluetooth.bleDevice.peripheral readRSSI];
    }
}
-(void)destroy{
    self.data = nil;
    self.splitWriter = nil;
    self.bleBluetooth = nil;
    self.operateCallback = nil;
    [self stopOperateTimer];
    self.operateTimer = nil;
}
-(void)dealloc{
    NSLog(@"%@ dealloc",self);
}
@end
