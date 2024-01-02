//
//  HYHBleSplitWriter.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHBleSplitWriter.h"
#import "HYHDataUtils.h"
@interface HYHBleSplitWriter()
@property (strong,nonatomic) NSData *data;
@property (assign,nonatomic) NSInteger splitNum;
@property (assign,nonatomic) NSInteger intervalBetweenTwoPackage;
@property (assign,nonatomic) BOOL continueWhenLastFail;
@property (strong,nonatomic) HYHBleWriteCallback *bleWriteCallback;
@property (strong,nonatomic) HYHQueue<NSData *> *dataArray;
@property (assign,nonatomic) NSInteger totalNum;
@property (strong,nonatomic) HYHBleWriteCallback *innerCallback;
@property (assign,nonatomic) CBCharacteristicWriteType writeType;
@end

@implementation HYHBleSplitWriter
- (instancetype)init
{
    self = [super init];
    if (self) {
        _innerCallback = [[HYHBleWriteCallback alloc]init];
        __weak typeof(self) weakSelf = self;
        _innerCallback.bleWriteSuccessBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSInteger current, NSInteger total, NSData * _Nonnull justWrite, NSData * _Nonnull data) {
            __strong typeof(self) strongSelf = weakSelf;
            NSInteger position = self.totalNum - strongSelf.dataArray.count;
            if (strongSelf.bleWriteCallback.bleWriteSuccessBlock) {
                strongSelf.bleWriteCallback.bleWriteSuccessBlock(bleDevice, characteristic, position, weakSelf.totalNum, justWrite, weakSelf.data);
            }
            if (weakSelf.dataArray.count != 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.intervalBetweenTwoPackage * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    NSData *currentData = [weakSelf.dataArray poll];
                    if ([weakSelf.weakBleOperator valid]) {
                        [weakSelf.weakBleOperator writeCharacteristic:currentData writeType:weakSelf.writeType bleWriteCallback:weakSelf.innerCallback];
                    }
                });
            }
        };
        _innerCallback.bleWriteFailureBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError * _Nonnull error, NSInteger current, NSInteger total, NSData * _Nullable justWrite, NSData * _Nullable data, BOOL isTotalFail) {
            __strong typeof(self) strongSelf = weakSelf;
            NSInteger position = self.totalNum - strongSelf.dataArray.count;
            if (strongSelf.continueWhenLastFail) {
                if (weakSelf.dataArray.count != 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.intervalBetweenTwoPackage * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                        NSData *currentData = [strongSelf.dataArray poll];
                        if ([weakSelf.weakBleOperator valid]) {
                            [weakSelf.weakBleOperator writeCharacteristic:currentData writeType:weakSelf.writeType bleWriteCallback:weakSelf.innerCallback];
                        }
                    });
                }
            }else{
                if (strongSelf.bleWriteCallback.bleWriteFailureBlock) {
                    strongSelf.bleWriteCallback.bleWriteFailureBlock(bleDevice, characteristic, error, position, strongSelf.totalNum, justWrite, strongSelf.data, YES);
                }
            }
        };
    }
    return self;
}
- (void)splitwrite:(NSData *)data splitNum:(NSInteger)splitNum continueWhenLastFail:(BOOL)continueWhenLastFail intervalBetweenTwoPackage:(NSInteger)intervalBetweenTwoPackage callback:(HYHBleWriteCallback *)callback writeType:(CBCharacteristicWriteType)writeType{
    if (writeType == HYHBleOperateWriteTypeDefault) {
        if (self.weakBleOperator.characteristic.properties & CBCharacteristicPropertyWrite) {
            writeType = CBCharacteristicWriteWithResponse;
        }else if (self.weakBleOperator.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
            writeType = CBCharacteristicWriteWithoutResponse;
        }
    }
    self.data = data;
    self.splitNum = splitNum;
    self.continueWhenLastFail = continueWhenLastFail;
    if (writeType == CBCharacteristicWriteWithoutResponse && intervalBetweenTwoPackage < 10) {
        intervalBetweenTwoPackage = 10;
    }
    self.intervalBetweenTwoPackage = intervalBetweenTwoPackage;
    self.bleWriteCallback = callback;
    self.writeType = writeType;
    [self splitWrite];
}


- (void)splitWrite{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.dataArray = [HYHDataUtils splitPacketForByte:weakSelf.data length:weakSelf.splitNum];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.totalNum = weakSelf.dataArray.count;
            NSData *currentData = [weakSelf.dataArray poll];
            if ([weakSelf.weakBleOperator valid]) {
                [weakSelf.weakBleOperator writeCharacteristic:currentData writeType:weakSelf.writeType bleWriteCallback:weakSelf.innerCallback];
            }
        });
    });
}
@end
