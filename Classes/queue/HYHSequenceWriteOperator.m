//
//  HYHSequenceWriteOperator.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/25.
//

#import "HYHSequenceWriteOperator.h"
#import "HYHBleOperator.h"
#import "HYHBleOperatorQueue.h"
@interface HYHSequenceWriteOperator()
@property (strong,nonatomic) HYHBleWriteCallback *wrappedBleWriteCallback;
@end

@implementation HYHSequenceWriteOperator
- (instancetype)initWithServiceUUID:(CBUUID *)servceUUid characteristicUUID:(CBUUID *)characteristicUUID
{
    self = [super init];
    if (self) {
        _serviceUUID = servceUUid;
        _characteristicUUID = characteristicUUID;
        _split = YES;
        _splitNum = HYHCentralManager.sharedBleManager.bleOption.splitWriteNum;
        _continueWhenLastFail = NO;
        _intervalBetweenTwoPackage = 0;
        _writeType = HYHBleOperateWriteTypeDefault;
        self.delay = 0;
        self.continuous = NO;
        self.timeout = 3000;
        self.wrappedBleWriteCallback = [[HYHBleWriteCallback alloc]init];
        __weak typeof(self) weakSelf = self;
        self.wrappedBleWriteCallback.bleWriteSuccessBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSInteger current, NSInteger total, NSData * _Nonnull justWrite, NSData * _Nonnull data) {
            if (weakSelf.writeCallback.bleWriteSuccessBlock) {
                weakSelf.writeCallback.bleWriteSuccessBlock(bleDevice, characteristic, current, total, justWrite, data);
            }
            if(current == total){
                if (weakSelf.operatorQueue) {
                    [weakSelf.operatorQueue bleOperatorTaskEnd:weakSelf result:YES];
                }
            }
        };
        self.wrappedBleWriteCallback.bleWriteFailureBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError * _Nonnull error, NSInteger current, NSInteger total, NSData * _Nullable justWrite, NSData * _Nullable data, BOOL isTotalFail) {
            if (weakSelf.writeCallback.bleWriteFailureBlock) {
                weakSelf.writeCallback.bleWriteFailureBlock(bleDevice, characteristic, error, current, total, justWrite, data, isTotalFail);
            }
            if (isTotalFail) {
                if (weakSelf.operatorQueue) {
                    [weakSelf.operatorQueue bleOperatorTaskEnd:weakSelf result:NO];
                }
            }
        };
    }
    return self;
}
-(void)execute:(HYHBleBluetooth *)bleBluetooth{
    if (bleBluetooth == nil) {
        return;
    }
    if (self.serviceUUID == nil || self.characteristicUUID == nil) {
        if (self.operatorQueue) {
            [self.operatorQueue bleOperatorTaskEnd:self result:NO];
        }
        return;
    }
    if (self.continuous) {
        if (self.writeCallback == nil) {
            self.writeCallback = [[HYHBleWriteCallback alloc]init];
            self.writeCallback.bleWriteSuccessBlock = HYHCentralManager.sharedBleManager.bleWriteSuccessBlock;
            self.writeCallback.bleWriteFailureBlock = HYHCentralManager.sharedBleManager.bleWriteFailureBlock;
        }
        [HYHCentralManager.sharedBleManager write:bleBluetooth.bleDevice serviceUUID:self.serviceUUID characteristicUUID:self.characteristicUUID data:self.data split:self.split splitNum:self.splitNum continueWhenLastFail:self.continueWhenLastFail intervalBetweenTwoPackage:self.intervalBetweenTwoPackage callback:self.wrappedBleWriteCallback writeType:self.writeType];
    }else{
        [HYHCentralManager.sharedBleManager write:bleBluetooth.bleDevice serviceUUID:self.serviceUUID characteristicUUID:self.characteristicUUID data:self.data split:self.split splitNum:self.splitNum continueWhenLastFail:self.continueWhenLastFail intervalBetweenTwoPackage:self.intervalBetweenTwoPackage callback:self.writeCallback writeType:self.writeType];
    }
}
@end
