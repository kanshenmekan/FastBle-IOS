//
//  HYHBleOptions.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import "HYHBleOptions.h"

@implementation HYHBleOptions
- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConnectCount = 5;
        _connectOverTime = -1;
        _operatorOverTime = -1;
        _splitWriteNum = 20;
        _centralManagerOptions = nil;
        _scanForPeripheralsWithOptions = nil;
        _connectPeripheralWithOptions = nil;
        _scanForPeripheralsWithServices = nil;
        _discoverWithServices = nil;
        _discoverWithCharacteristics = nil;
    }
    return self;
}
- (void)setMaxConnectCount:(NSInteger)maxConnectCount{
    if (maxConnectCount < 1) {
        maxConnectCount = 1;
    }
    if (maxConnectCount > 7) {
        maxConnectCount = 7;
    }
    _maxConnectCount = maxConnectCount;
}
- (nonnull instancetype)initWithCentralManagerOptions:(nullable NSDictionary *)centralManagerOptions scanForPeripheralsWithOptions:(nullable NSDictionary *)scanForPeripheralsWithOptions
                connectPeripheralWithOptions:(nullable NSDictionary *)connectPeripheralWithOptions
{
    self = [self init];
    if (self) {
        [self setCentralManagerOptions:centralManagerOptions];
        [self setScanForPeripheralsWithOptions:scanForPeripheralsWithOptions];
        [self setConnectPeripheralWithOptions:connectPeripheralWithOptions];
    }
    return self;
}

- (instancetype)initWithCentralManagerOptions:(nullable NSDictionary *)centralManagerOptions scanForPeripheralsWithOptions:(NSDictionary *)scanForPeripheralsWithOptions
                connectPeripheralWithOptions:(NSDictionary *)connectPeripheralWithOptions
              scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                        discoverWithServices:(NSArray *)discoverWithServices
                 discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics
{
    self = [self initWithCentralManagerOptions:centralManagerOptions scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions];
    if (self) {
        [self setScanForPeripheralsWithServices:scanForPeripheralsWithServices];
        [self setDiscoverWithServices:discoverWithServices];
        [self setDiscoverWithCharacteristics:discoverWithCharacteristics];
    }
    return self;
}

@end
