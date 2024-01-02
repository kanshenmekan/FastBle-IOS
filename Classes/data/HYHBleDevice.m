//
//  HYHBleDevice.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import "HYHBleDevice.h"
#import "HYHCentralManager.h"
@interface HYHBleDevice()
@property (strong,nonatomic,readonly) NSDictionary<NSString *,id> *userInfo;
@end

@implementation HYHBleDevice
- (instancetype) initWithDict:(NSDictionary *)dict{
    if([self init]){
        _peripheral = dict[@"peripheral"];
        _advertisementData = dict[@"advertisementData"];
        _RSSI = dict[@"RSSI"];
        _name = _advertisementData[@"kCBAdvDataLocalName"];
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}
- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral{
    if ([self init]) {
        _peripheral = peripheral;
    }
    return self;
}
- (BOOL)isConnected{
    return self.peripheral.state == CBPeripheralStateConnected;
}

- (BOOL)isConnecting{
    if (self.peripheral.state == CBPeripheralStateConnecting) {
        return YES;
    }else{
        for (HYHBleDevice *device in [HYHCentralManager.sharedBleManager getAllConnectingDevice] ) {
            if ([self isSameDevice:device]) {
                return YES;
            }
        }
        return NO;
    }
}

- (NSString *)deviceKey{
    return self.peripheral.identifier.UUIDString;
}
- (BOOL)isSameDevice:(HYHBleDevice *)bleDevice{
    if (bleDevice == nil) {
        return NO;
    }
    return [self isSamePeripheral:bleDevice.peripheral];
}

- (BOOL)isSamePeripheral:(CBPeripheral *)peripheral{
    if (peripheral == nil) {
        return NO;
    }
    return [self.deviceKey isEqualToString:peripheral.identifier.UUIDString];
}
- (void)putValue:(id)value forKey:(NSString *) key{
    [self.userInfo setValue:value forKey:key];
}

- (nullable id)getWithKey:(NSString *)key{
    return [self.userInfo valueForKey:key];
}
@end
