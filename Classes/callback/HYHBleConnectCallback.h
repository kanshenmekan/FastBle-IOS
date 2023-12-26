//
//  HYHBleConnectCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import <Foundation/Foundation.h>
#import "HYHBleDevice.h"
#import "HYHBleError.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHOnStartConnectBlock)(HYHBleDevice *device);
typedef void(^HYHOnConnectFailBlock)(HYHBleDevice *device,NSError *error);
typedef void(^HYHOnConnectSuccessBlock)(HYHBleDevice *device);
typedef void(^HYHOnDisconnectBlock)(HYHBleDevice *device,NSError * _Nullable error);
typedef void(^HYHOnConnectCancelBlock)(HYHBleDevice *device);
@interface HYHBleConnectCallback : NSObject
@property (copy,nonatomic,nullable) HYHOnStartConnectBlock onStartConnectBlock;
@property (copy,nonatomic,nullable) HYHOnConnectFailBlock onConnectFailBlock;
@property (copy,nonatomic,nullable) HYHOnConnectSuccessBlock onConnectSuccessBlock;
@property (copy,nonatomic,nullable) HYHOnDisconnectBlock onDisconnectBlock;
@property (copy,nonatomic,nullable) HYHOnConnectCancelBlock onConnectCancelBlock;
@end

NS_ASSUME_NONNULL_END
