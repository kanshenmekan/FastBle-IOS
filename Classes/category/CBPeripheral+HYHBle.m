//
//  CBPeripheral+HYHBle.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "CBPeripheral+HYHBle.h"

@implementation CBPeripheral (HYHBle)
-(nullable CBService *)getServiceWithUUID:(CBUUID *)uuid{
    for (CBService *service in self.services) {
        if ([service.UUID isEqual:uuid]) {
            return service;
        }
    }
    return nil;
}
-(nullable CBCharacteristic *)getCharacteristicWithUUID:(CBUUID *)uuid fromService:(CBService *)service{
    return [service getCharacteristicWithUUID:uuid];
}
-(nullable CBCharacteristic *)getCharacteristicFromServiceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    CBService *service = [self getServiceWithUUID:serviceUUID];
    if (service != nil) {
        return [self getCharacteristicWithUUID:characteristicUUID fromService:service];
    }
    return nil;
}
@end
