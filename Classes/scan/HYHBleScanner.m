//
//  HYHBleScanner.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//
#import "HYHBleScanner.h"
#import "HYHBleOptions.h"
#import "HYHTimepiece.h"
#import "HYHBleError.h"
@interface HYHBleScanner()
@property (readonly) CBCentralManager *centralManager;
@property (readonly) HYHBleOptions *bleOptions;
@property (strong,nonatomic) HYHTimepiece *timepiece;
@property (strong,nonatomic) NSMutableDictionary<NSString *,HYHBleDevice *> *bleDeviceDictionary;

@end

@implementation HYHBleScanner
static id _instace;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
        HYHBleScanner *scanner = _instace;
        scanner.bleScanCofig = [[HYHBleScanRuleConfig alloc]init];
        scanner.bleDeviceDictionary = [NSMutableDictionary dictionary];
    });
    return _instace;
}

+ (instancetype)scanner
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instace;
}
- (CBCentralManager *)centralManager{
    return HYHCentralManager.sharedBleManager.centralManager;
}
- (HYHBleOptions *)bleOptions{
    return HYHCentralManager.sharedBleManager.bleOption;
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    HYHBleDevice *device = [[HYHBleDevice alloc]initWithDict:@{ @"peripheral":peripheral,
                                                                @"advertisementData":advertisementData,
                                                                @"RSSI":RSSI}];
    if (self.bleScanCofig) {
        BOOL hasPassed = NO;
        if (self.bleScanCofig.names.count == 0 && self.bleScanCofig.identifiers.count == 0) {
            hasPassed = YES;
        }
        if (self.bleScanCofig.names.count > 0) {
            if (device.name != nil) {
                for (NSString *name in self.bleScanCofig.names) {
                    if (self.bleScanCofig.fuzzyName) {
                        if ([device.name localizedCaseInsensitiveContainsString:name]) {
                            hasPassed = YES;
                            break;
                        }
                    }else{
                        if ([device.name isEqualToString:name]) {
                            hasPassed = YES;
                            break;
                        }
                    }
                }
            }
        }
        if (self.bleScanCofig.identifiers.count > 0) {
            for (NSString *identify in self.bleScanCofig.identifiers) {
                if ([identify isEqualToString:device.deviceKey]) {
                    hasPassed = YES;
                    break;
                }
            }
        }
        if (!hasPassed) {
            return;
        }
    }
    if (self.onScanFilterBlock) {
        if(!self.onScanFilterBlock(device)){
            return;
        }
    }
  
    [self correctDeviceAndNextStep:device];
}
- (void)correctDeviceAndNextStep:(HYHBleDevice *)device{
    if (self.bleDeviceDictionary[device.deviceKey]) {
        HYHBleDevice *oldDevice = self.bleDeviceDictionary[device.deviceKey];
        self.bleDeviceDictionary[device.deviceKey] = device;
        if (self.onLeScanBlock) {
            self.onLeScanBlock(oldDevice, device, YES);
        }
    }else{
        self.bleDeviceDictionary[device.deviceKey] = device;
        if (self.onLeScanBlock) {
            self.onLeScanBlock(device, device, NO);
        }
    }
}


- (void)startLeScan{
    if ([self isScanning]) {
        NSLog(@"scan action already exists, complete the previous scan action first");
        if (self.onScanStartedBlock) {
            self.onScanStartedBlock([[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorOtherCode userInfo:nil]);
        }
        return;
    }
    [self scanPeripherals];
}
#pragma mark - centralManager 方法
- (void)scanPeripherals {
    if ([self isScanning]) {
        return;
    }
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        if (self.onScanStartedBlock) {
            self.onScanStartedBlock(nil);
        }
        [self.bleDeviceDictionary removeAllObjects];
        [self.centralManager scanForPeripheralsWithServices:self.bleOptions.scanForPeripheralsWithServices options:self.bleOptions.scanForPeripheralsWithOptions];
        if (self.bleScanCofig && self.bleScanCofig.scanTimeout > 0) {
            if (self.timepiece) {
                [self.timepiece cancelTimer];
            }
            __weak typeof(self) weakSelf = self;
            self.timepiece = [HYHTimepiece scheduleWithTime:self.bleScanCofig.scanTimeout timeoutBlock:^{
                [weakSelf stopLeScan];
            }];
        }
        return;
    }else if(self.centralManager.state == CBManagerStateUnsupported){
        if (self.onScanStartedBlock) {
            self.onScanStartedBlock([[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorNotSupportBleCode localizedDescription:@"Bluetooth not supported"]);
        }
    }else {
        if (self.onScanStartedBlock) {
            self.onScanStartedBlock([[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorBluetoothNotEnabledCode localizedDescription:@"Bluetooth not enabled"]);
        }
    }
}

//停止扫描
- (void)stopLeScan {
    if (self.timepiece) {
        [self.timepiece cancelTimer];
    }
    if ([self isScanning]) {
        [self.centralManager stopScan];
        //停止扫描callback
        if (self.onScanFinishBlock) {
            self.onScanFinishBlock(self.bleDeviceDictionary.allValues);
        }
    }
    
}
- (BOOL)isScanning{
    return self.centralManager.isScanning;
}
- (void)onBleOff{
    if ([self.timepiece valid]) {
        if (self.onScanFinishBlock) {
            self.onScanFinishBlock(self.bleDeviceDictionary.allValues);
        }
    }
}
- (void)removeScanCallback{
    self.onScanStartedBlock = nil;
    self.onLeScanBlock = nil;
    self.onScanFilterBlock = nil;
    self.onScanFinishBlock = nil;
}

@end
