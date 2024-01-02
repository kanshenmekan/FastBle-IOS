//
//  HYHBleDiscoverCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import "HYHBleDiscoverCallback.h"

@implementation HYHBleDiscoverCallback
- (instancetype)initWithDiscoverServices:(nullable NSArray<CBUUID *> *)discoverServices discoverCharacteristics:(nullable NSArray<CBUUID *> *)discoverCharacteristics{
    if (self = [super init]) {
        self.discoverWithServices = discoverServices;
        self.discoverWithCharacteristics = discoverCharacteristics;
    }
    return self;
}
@end
