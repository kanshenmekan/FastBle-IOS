//
//  HYHBleRssiCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/20.
//

#import "HYHBleRssiCallback.h"

@implementation HYHBleRssiCallback
- (instancetype)init{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.bleOperateTimeoutBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError *error, NSData * _Nullable data) {
            if (weakSelf.bleReadRssiFailure) {
                weakSelf.bleReadRssiFailure(bleDevice,error);
            }
        };
    }
    return self;
}
@end
