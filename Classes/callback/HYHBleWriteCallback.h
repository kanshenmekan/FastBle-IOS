//
//  HYHBleWriteCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHBleOperateCallback.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleWriteSuccessBlock)(HYHBleDevice *bleDevice,CBCharacteristic *characteristic,NSInteger current,NSInteger total,NSData *justWrite,NSData *data);
typedef void(^HYHBleWriteFailureBlock)(HYHBleDevice *bleDevice,CBCharacteristic *_Nullable characteristic,NSError *error,NSInteger current,NSInteger total,NSData *_Nullable justWrite,NSData *_Nullable data,BOOL isTotalFail);
@interface HYHBleWriteCallback : HYHBleOperateCallback
@property (nullable,copy,nonatomic) HYHBleWriteSuccessBlock bleWriteSuccessBlock;
@property (nullable,copy,nonatomic) HYHBleWriteFailureBlock bleWriteFailureBlock;
@end

NS_ASSUME_NONNULL_END
