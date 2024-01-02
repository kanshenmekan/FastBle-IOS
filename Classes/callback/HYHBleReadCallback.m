//
//  HYHBleReadCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHBleReadCallback.h"

@implementation HYHBleReadCallback
- (instancetype)init{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.bleOperateTimeoutBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError *error, NSData * _Nullable data) {
            if (weakSelf.bleReadFailureBlock) {
                weakSelf.bleReadFailureBlock(bleDevice, characteristic, error);
            }
        };
    }
    return self;
}

@end
