//
//  CBPeripheral+HYHBle.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "CBService+HYHBle.h"
NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral(HYHBle)
- (nullable CBService *)getServiceWithUUID:(CBUUID *)uuid;
- (nullable CBCharacteristic *)getCharacteristicWithUUID:(CBUUID *)uuid fromService:(CBService *)service;
- (nullable CBCharacteristic *)getCharacteristicFromServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;
@end

NS_ASSUME_NONNULL_END
