//
//  HYHBle.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "CBService+HYHBle.h"

@implementation CBService (HYHBle)
-(nullable CBCharacteristic *)getCharacteristicWithUUID:(CBUUID *)uuid{
    for (CBCharacteristic *characteristic in self.characteristics) {
        if ([characteristic.UUID isEqual:uuid]) {
            return characteristic;
        }
    }
    return nil;
}
@end
