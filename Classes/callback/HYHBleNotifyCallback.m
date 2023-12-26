//
//  HYHBleNotifyCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHBleNotifyCallback.h"

@implementation HYHBleNotifyCallback
-(instancetype)init{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.bleOperateTimeoutBlock = ^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError *error, NSData * _Nullable data) {
            if (weakSelf.bleNotifyFailureBlock) {
                weakSelf.bleNotifyFailureBlock(bleDevice, characteristic, error);
            }
        };
    }
    return self;
}
@end
