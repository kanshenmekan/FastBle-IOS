//
//  HYHBleRssiCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/20.
//

#import "HYHBleOperateCallback.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleReadRssiSuccess)(HYHBleDevice *bleDevice,NSInteger rssi);
typedef void(^HYHBleReadRssiFailure)(HYHBleDevice *bleDevice,NSError *error);
@interface HYHBleRssiCallback : HYHBleOperateCallback
@property (nullable,copy,nonatomic) HYHBleReadRssiSuccess bleReadRssiSuccess;
@property (nullable,copy,nonatomic) HYHBleReadRssiFailure bleReadRssiFailure;
@end

NS_ASSUME_NONNULL_END
