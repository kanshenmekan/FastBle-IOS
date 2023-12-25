//
//  HYHBleReadCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHBleOperateCallback.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleReadSuccessBlock)(HYHBleDevice *bleDevice,CBCharacteristic *characteristic,NSData *data);
typedef void(^HYHBleReadFailureBlock)(HYHBleDevice *bleDevice,CBCharacteristic *_Nullable characteristic,NSError *error);
@interface HYHBleReadCallback : HYHBleOperateCallback
@property (nullable,copy,nonatomic) HYHBleReadSuccessBlock bleReadSuccessBlock;
@property (nullable,copy,nonatomic) HYHBleReadFailureBlock bleReadFailureBlock;
@end

NS_ASSUME_NONNULL_END
