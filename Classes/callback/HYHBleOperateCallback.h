//
//  HYHBleOperateCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
@class HYHBleDevice;
@class CBCharacteristic;
@class HYHBleError;
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleOperateTimeoutBlock)(HYHBleDevice *bleDevice,CBCharacteristic *_Nullable characteristic,NSError *error, NSData *_Nullable data);
@interface HYHBleOperateCallback : NSObject
@property (copy,nonatomic) HYHBleOperateTimeoutBlock bleOperateTimeoutBlock;
@end

NS_ASSUME_NONNULL_END
