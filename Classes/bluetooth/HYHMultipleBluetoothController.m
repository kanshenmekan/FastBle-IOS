//
//  HYHMultipleBluetoothController.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import "HYHMultipleBluetoothController.h"
#import "HYHCentralManager.h"
@implementation HYHMultipleBluetoothController
-(instancetype)initWithMaxConnectCount:(NSInteger)maxConnectCount{
    if (self = [super init]) {
        _bleLruDictionary = [[HYHBleLruDictionary alloc]initWithMaximumCapacity:maxConnectCount];
        _connectingDictionary = [HYHThreadSafeDictionary dictionary];
    }
    return self;
}
-(HYHBleBluetooth *)buildConnectingBle:(HYHBleDevice *)device{
    HYHBleBluetooth *bleBluetooth = [self.connectingDictionary objectForKey:device.deviceKey];
    if (bleBluetooth != nil) {
        return bleBluetooth;
    }else{
        bleBluetooth = [[HYHBleBluetooth alloc]init:device];
        [self.connectingDictionary setObject:bleBluetooth forKey:device.deviceKey];
        return bleBluetooth;
    }
}
-(void)removeConnectingBle:(HYHBleBluetooth *)bleBluetooth{
    if (bleBluetooth == nil) {
        return;
    }
    [self.connectingDictionary removeObjectForKey:bleBluetooth.deviceKey];
}
-(void)addConnectedBleBluetooth:(HYHBleBluetooth *)bleBluetooth{
    if (bleBluetooth == nil) {
        return;
    }
    if (![self.bleLruDictionary containKey:bleBluetooth.deviceKey]) {
        [self.bleLruDictionary setObject:bleBluetooth forKey:bleBluetooth.deviceKey];
    }
}
-(void)removeConnectedBleBluetooth:(HYHBleBluetooth *)bleBluetooth{
    if (bleBluetooth == nil) {
        return;
    }
    [self.bleLruDictionary removeObjectForKey:bleBluetooth.deviceKey];
}
-(void)cancelConnecting:(HYHBleDevice *)device{
    if (!device.isConnecting) {
        return;
    }
    HYHBleBluetooth *bleBluetooth = [self.connectingDictionary objectForKey:device.deviceKey];
    if (bleBluetooth != nil) {
        [bleBluetooth cancelConnect];
    }else{
        [HYHCentralManager.sharedBleManager.centralManager cancelPeripheralConnection:device.peripheral];
    }
}
-(void)cancelAllConnectingDevice{
    for (NSString *key in self.connectingDictionary) {
        [self cancelConnecting:[self.connectingDictionary objectForKey:key].bleDevice];
    }
}
-(nullable HYHBleBluetooth *)getConnectedBleBluetooth:(HYHBleDevice *)bleDevice{
    HYHBleBluetooth *bleBluetooth = [self.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if ([bleDevice isConnected] && bleBluetooth == nil) {
        [self addConnectedBleBluetooth:[[HYHBleBluetooth alloc]init:bleDevice]];
    }
    return bleBluetooth;
}
-(void)disconnect:(HYHBleDevice *)bleDevice{
    if ([self.bleLruDictionary containKey:bleDevice.deviceKey]) {
        HYHBleBluetooth *bleBluetooth = [self getConnectedBleBluetooth:bleDevice];
        if (bleBluetooth != nil) {
            [bleBluetooth disconnect];
        }
    }else{
        
    }
}

-(void)disconnectAllDevice{
    for (NSString *key in self.bleLruDictionary) {
        [self disconnect:[self.bleLruDictionary objectForKey:key].bleDevice];
    }
}
-(void)destroy{
    for (NSString *key in self.bleLruDictionary) {
        [[self.bleLruDictionary objectForKey:key] destroy];
    }
    [self.bleLruDictionary removeAllObjects];
    
    for (NSString *key in self.connectingDictionary) {
        [[self.connectingDictionary objectForKey:key] destroy];
    }
    [self.connectingDictionary removeAllObjects];
}
-(void)onBleOff{
    for (NSString *key in self.bleLruDictionary) {
        HYHBleBluetooth *bleBluetooth = [self.bleLruDictionary objectForKey:key];
        if (bleBluetooth.connectCallback.onDisconnectBlock) {
            bleBluetooth.connectCallback.onDisconnectBlock(bleBluetooth.bleDevice, nil);
            [bleBluetooth destroy];
        }
    }
    [self.bleLruDictionary removeAllObjects];
    
    for (NSString *key in self.connectingDictionary) {
        HYHBleBluetooth *bleBluetooth = [self.connectingDictionary objectForKey:key];
        if (bleBluetooth.connectCallback.onConnectFailBlock) {
            bleBluetooth.connectCallback.onConnectFailBlock(bleBluetooth.bleDevice,[[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorBluetoothNotEnabledCode localizedDescription:@"Bluetooth not enabled"]);
            [bleBluetooth destroy];
        }
    }
    [self.connectingDictionary removeAllObjects];
}
#pragma mark - HYHBleLruDictionaryDelegate
- (void)bleLruDictionary:(HYHBleLruDictionary *)dictionary removeEldestEntry:(id)entry{
    HYHBleBluetooth *bleBluetooth = entry;
    [bleBluetooth disconnect];
}
@end
