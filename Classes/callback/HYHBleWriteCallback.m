//
//  HYHBleWriteCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHBleWriteCallback.h"
#import "HYHBleOperator.h"
@implementation HYHBleWriteCallback
- (instancetype)init{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.bleOperateTimeoutBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError *error, NSData * _Nullable data) {
            if (weakSelf.bleWriteFailureBlock) {
                weakSelf.bleWriteFailureBlock(bleDevice, characteristic,error,HYHBleOperateWriteSingleData, HYHBleOperateWriteSingleData, data, data, YES);
            }
        };
    }
    return self;
}
@end
