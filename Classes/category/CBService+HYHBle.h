//
//  HYHBle.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface CBService(HYHBle)
- (nullable CBCharacteristic *)getCharacteristicWithUUID:(CBUUID *)uuid;
@end

NS_ASSUME_NONNULL_END
