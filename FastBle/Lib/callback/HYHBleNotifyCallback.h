//
//  HYHBleNotifyCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHBleOperateCallback.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleNotifySuccessBlock)(HYHBleDevice *bleDevice,CBCharacteristic *characteristic);
typedef void(^HYHBleNotifyFailureBlock)(HYHBleDevice *bleDevice,CBCharacteristic *_Nullable characteristic,NSError *error);
typedef void(^HYHBleNotifyCharacteristicChangedBlock)(HYHBleDevice *bleDevice,CBCharacteristic *characteristic,NSData *data);
typedef void(^HYHBleNotifyCancelBlock)(HYHBleDevice *bleDevice,CBCharacteristic *characteristic);
@interface HYHBleNotifyCallback : HYHBleOperateCallback
@property (nullable,copy,nonatomic) HYHBleNotifySuccessBlock bleNotifySuccessBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyFailureBlock bleNotifyFailureBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyCharacteristicChangedBlock bleNotifyCharacteristicChangedBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyCancelBlock bleNotifyCancelBlock;
@end

NS_ASSUME_NONNULL_END
