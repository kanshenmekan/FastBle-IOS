//
//  HYHCentralManager.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import "HYHCentralManager.h"
#import "HYHBleScanner.h"
#import "HYHMultipleBluetoothController.h"
#import "HYHBleOperator.h"
#import "CBPeripheral+HYHBle.h"
#import "HYHBleSplitWriter.h"
typedef void(^HYHCentralManagerRestoreOperateBlock)(void);
@interface HYHCentralManager()
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (assign,nonatomic) BOOL needScanWhenReady;
@property (strong,nonatomic) HYHMultipleBluetoothController *multipleBluetoothController;
@property (copy,nonatomic,nullable) NSDictionary<NSString *,id> * restoreDic;
@end

@implementation HYHCentralManager
static id _instace;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)sharedBleManager
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

-(void)initManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self.bleOption == nil) {
            self.bleOption = [[HYHBleOptions alloc]init];
        }
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"bluetooth-central"]) {
            //后台模式
            self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:self.bleOption.centralManagerOptions];
        }
        else {
            //非后台模式
            self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        }
        self.multipleBluetoothController = [[HYHMultipleBluetoothController alloc]initWithMaxConnectCount:self.bleOption.maxConnectCount];
        self.needScanWhenReady = NO;
    });
}
#pragma mark - operate
-(void)setBleScanCofig:(HYHBleScanRuleConfig *)bleScanCofig{
    HYHBleScanner.scanner.bleScanCofig = bleScanCofig;
}
-(void)startLeScan{
    if (self.centralManager.state == CBManagerStateUnknown) {
        self.needScanWhenReady = YES;
    }else{
        [HYHBleScanner.scanner startLeScan];
        self.needScanWhenReady = NO;
    }
}
-(void)stopLeScan{
    [HYHBleScanner.scanner stopLeScan];
}
-(BOOL)isScnning{
    return self.centralManager.isScanning;
}
-(void)connect:(HYHBleDevice *)device{
    [self connect:device overTime:self.bleOption.connectOverTime];
}
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime{
    [self connect:device overTime:overTime options:self.bleOption.connectPeripheralWithOptions];
}
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime options:(nullable NSDictionary *)options {
    [self connect:device overTime:overTime options:options connectCallback:nil discoverCallback:nil];
}
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime options:(nullable NSDictionary *)options connectCallback:(nullable HYHBleConnectCallback *)connectCallback discoverCallback:(nullable HYHBleDiscoverCallback *)discoverCallback {
    if (connectCallback == nil) {
        connectCallback = [[HYHBleConnectCallback alloc]init];
        connectCallback.onStartConnectBlock = self.onStartConnectBlock;
        connectCallback.onConnectSuccessBlock = self.onConnectSuccessBlock;
        connectCallback.onConnectFailBlock = self.onConnetFailBlock;
        connectCallback.onDisconnectBlock = self.onDisconnectBlock;
        connectCallback.onConnectCancelBlock = self.onConnectCancelBlock;
    }
    if (discoverCallback == nil) {
        discoverCallback = [[HYHBleDiscoverCallback alloc]initWithDiscoverServices:self.bleOption.discoverWithServices discoverCharacteristics:self.bleOption.discoverWithCharacteristics];
        discoverCallback.didDiscoverServicesBlock = self.didDiscoverServicesBlock;
        discoverCallback.didDiscoverCharacteristicsForServiceBlock = self.didDiscoverCharacteristicsForServiceBlock;
        discoverCallback.didDiscoverDescriptorsForCharacteristicBlock = self.didDiscoverDescriptorsForCharacteristicBlock;
    }
    if (self.centralManager.state != CBManagerStatePoweredOn) {
        connectCallback.onConnectFailBlock(device,[[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorBluetoothNotEnabledCode localizedDescription:@"Bluetooth Not enabled"]);
    }
    if (device.isConnected) {
        if (![self.multipleBluetoothController.bleLruDictionary containKey:device.deviceKey]) {
            HYHBleBluetooth *bleBluetooth = [[HYHBleBluetooth alloc]init:device];
            bleBluetooth.connectCallback = connectCallback;
            bleBluetooth.discoverCallback = discoverCallback;
            [self.multipleBluetoothController addConnectedBleBluetooth:bleBluetooth];
        }
        return;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController buildConnectingBle:device];
    bleBluetooth.connectCallback = connectCallback;
    bleBluetooth.discoverCallback = discoverCallback;
    [bleBluetooth connect:options overTime:overTime];
    
}
-(void)discoverServices:(HYHBleDevice *)device services:(NSArray<CBUUID *> *)discoverServices{
    if (!device.isConnected) {
        return;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    [bleBluetooth discoverServices:discoverServices];
}
-(void)discoverCharacteristics:(HYHBleDevice *)device characteristicUUIDs:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service{
    if (!device.isConnected) {
        return;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    [bleBluetooth discoverCharacteristics:characteristicUUIDs forService:service];
}
-(void)discoverDescriptorsForCharacteristic:(HYHBleDevice *)device characteristic:(CBCharacteristic *)characteristic{
    if (!device.isConnected) {
        return;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    [bleBluetooth discoverDescriptorsForCharacteristic:characteristic];
}
-(void)readValueForCharacteristic:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    [self readValueForCharacteristic:device serviceUUID:serviceUUID characteristicUUID:characteristicUUID bleReadCallback:nil];
}
-(void)readValueForCharacteristic:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID bleReadCallback:(nullable HYHBleReadCallback *)bleReadCallback{
    if (bleReadCallback == nil) {
        bleReadCallback = [[HYHBleReadCallback alloc]init];
        bleReadCallback.bleReadSuccessBlock = self.bleReadSuccessBlock;
        bleReadCallback.bleReadFailureBlock = self.bleReadFailureBlock;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    CBCharacteristic *characteristic = [bleBluetooth.bleDevice.peripheral getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (bleBluetooth == nil) {
        if (bleReadCallback.bleReadFailureBlock) {
            bleReadCallback.bleReadFailureBlock(device, characteristic, [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorDeviceNotConnectedCode localizedDescription:@"This peripheral is not connected"]);
        }
    }else{
        [[[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth characteristic:characteristic]readCharacteristic:bleReadCallback];
    }
    
}
-(void)notify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    [self notify:device serviceUUID:serviceUUID characteristicUUID:characteristicUUID notifyCallback:nil];
}
-(void)notify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID notifyCallback:(HYHBleNotifyCallback *)notifyCallback{
    if (notifyCallback == nil) {
        notifyCallback = [[HYHBleNotifyCallback alloc]init];
        notifyCallback.bleNotifySuccessBlock = self.bleNotifySuccessBlock;
        notifyCallback.bleNotifyFailureBlock = self.bleNotifyFailureBlock;
        notifyCallback.bleNotifyCancelBlock = self.bleNotifyCancelBlock;
        notifyCallback.bleNotifyCharacteristicChangedBlock = self.bleNotifyCharacteristicChangedBlock;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    CBCharacteristic *characteristic = [bleBluetooth.bleDevice.peripheral getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (bleBluetooth == nil) {
        if (notifyCallback.bleNotifyFailureBlock) {
            notifyCallback.bleNotifyFailureBlock(device, characteristic, [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorDeviceNotConnectedCode localizedDescription:@"This peripheral is not connected"]);
        }
    }else{
        [[[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth characteristic:characteristic]enableCharacteristicNotification:notifyCallback];
    }
}
-(void)stopNotify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:device];
    if (bleBluetooth == nil) {
        return;
    }
    CBCharacteristic *characteristic = [bleBluetooth.bleDevice.peripheral getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (characteristic == nil) {
        return;
    }
    [[[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth characteristic:characteristic]disableCharacteristicNotification];
}
-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data{
    [self write:bleDevice serviceUUID:serviceUUID characteristicUUID:characteristicUUID data:data writeType:HYHBleOperateWriteTypeDefault];
}
-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data writeType:(CBCharacteristicWriteType)writeType{
    [self write:bleDevice serviceUUID:serviceUUID characteristicUUID:characteristicUUID data:data split:YES splitNum:self.bleOption.splitWriteNum continueWhenLastFail:NO intervalBetweenTwoPackage:0 callback:nil writeType:writeType];
}
-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data split:(BOOL)split splitNum:(NSInteger)splitNum continueWhenLastFail:(BOOL)continueWhenLastFail intervalBetweenTwoPackage:(NSInteger)intervalBetweenTwoPackage callback:(nullable HYHBleWriteCallback *)callback writeType:(CBCharacteristicWriteType)writeType{
    if (data == nil) {
        return;
    }
    if (data.length > 20 && !split) {
        NSLog(@"Be careful: data's length beyond 20! Ensure MTU higher than 23, or use spilt write!");
    }
    if (callback == nil) {
        callback = [[HYHBleWriteCallback alloc]init];
        callback.bleWriteSuccessBlock = self.bleWriteSuccessBlock;
        callback.bleWriteFailureBlock = self.bleWriteFailureBlock;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:bleDevice];
    if (bleBluetooth == nil) {
        if (callback.bleWriteFailureBlock) {
            callback.bleWriteFailureBlock(bleDevice, nil, [[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorDeviceNotConnectedCode localizedDescription:@"This peripheral is not connected"], HYHBleOperateWriteSingleData, HYHBleOperateWriteSingleData, nil, data, YES);
        }
        return;
    }
    CBCharacteristic *characteristic = [bleBluetooth.bleDevice.peripheral getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (characteristic == nil) {
        return;
    }
    if (splitNum <= 0) {
        splitNum = self.bleOption.splitWriteNum;
    }
    if (split && data.length > splitNum) {
        HYHBleOperator *bleOperator = [[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth characteristic:characteristic];
        HYHBleSplitWriter * splitWriter = [[HYHBleSplitWriter alloc]init];
        [bleOperator bindingSplitWriter:splitWriter];
        [splitWriter splitwrite:data splitNum:splitNum continueWhenLastFail:continueWhenLastFail intervalBetweenTwoPackage:intervalBetweenTwoPackage callback:callback writeType:writeType];
    } else {
        [[[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth characteristic:characteristic] writeCharacteristic:data writeType:writeType bleWriteCallback:callback];
    }
}
-(void)readRssi:(HYHBleDevice *)bleDevice{
    [self readRssi:bleDevice bleRssiCallback:nil];
}
-(void)readRssi:(HYHBleDevice *)bleDevice bleRssiCallback:(nullable HYHBleRssiCallback *)bleRssiCallback{
    if (bleRssiCallback == nil) {
        bleRssiCallback = [[HYHBleRssiCallback alloc]init];
        bleRssiCallback.bleReadRssiFailure = self.bleReadRssiFailure;
        bleRssiCallback.bleReadRssiSuccess = self.bleReadRssiSuccess;
    }
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:bleDevice];
    if (bleBluetooth == nil) {
        if (bleRssiCallback.bleReadRssiFailure) {
            bleRssiCallback.bleReadRssiFailure(bleDevice,[[HYHBleError alloc]initWithDomain:HYHOtherExceptionDomain code:HYHBleErrorDeviceNotConnectedCode localizedDescription:@"This peripheral is not connected"]);
        }
        return;
    }
    if (bleBluetooth.bleRssiOperator != nil) {
        [bleBluetooth.bleRssiOperator readRssi:bleRssiCallback];
    }else{
        [[[HYHBleOperator alloc]initWithBleBluetooth:bleBluetooth]readRssi:bleRssiCallback];
    }
}
-(void)addOperatorToQueue:(HYHBleDevice *)bleDevice sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator{
    [self addOperatorToQueue:bleDevice identifier:nil sequenceBleOperator:sequenceBleOperator];
}
-(void)addOperatorToQueue:(HYHBleDevice *)bleDevice identifier:(nullable NSString *)identifier sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:bleDevice];
    if (bleBluetooth != nil) {
        [bleBluetooth addOperatorToQueueWithIdentifier:identifier sequenceBleOperator:sequenceBleOperator];
    }
}
-(void)removeOperatorQueue:(HYHBleDevice *)bleDevice identifier:(nullable NSString *)identifier{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController getConnectedBleBluetooth:bleDevice];
    if (bleBluetooth != nil) {
        [bleBluetooth removeOperateQueueWithIdentifier:identifier];
    }
}
-(void)removeOperatorQueue:(HYHBleDevice *)bleDevice{
    [self removeOperatorQueue:bleDevice identifier:nil];
}
-(void)destroy{
    [self.multipleBluetoothController destroy];
    [HYHBleScanner.scanner stopLeScan];
}
#pragma mark - delegate
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (self.centralManagerDidUpdateStateBlock) {
        self.centralManagerDidUpdateStateBlock(central);
    }
    if (self.needScanWhenReady) {
        [self startLeScan];
    }
    if (central.state == CBManagerStatePoweredOff) {
        [self.multipleBluetoothController onBleOff];
        [HYHBleScanner.scanner onBleOff];
    }
    if (central.state == CBManagerStatePoweredOn) {
        if (self.restoreDic) {
            [self restoreCentralManagerState:self.restoreDic];
            self.restoreDic = nil;
        }
    }
}
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    self.restoreDic = dict;
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    [HYHBleScanner.scanner centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.connectingDictionary objectForKey:peripheral.identifier.UUIDString];
    if (bleBluetooth != nil) {
        [bleBluetooth didConnectPeripheral];
        [self.multipleBluetoothController removeConnectingBle:bleBluetooth];
        [self.multipleBluetoothController addConnectedBleBluetooth:bleBluetooth];
    }
    
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.connectingDictionary objectForKey:peripheral.identifier.UUIDString];
    if (bleBluetooth != nil) {
        [bleBluetooth didFailToConnectPeripheral:error];
        [self.multipleBluetoothController removeConnectingBle:bleBluetooth];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:peripheral.identifier.UUIDString];
    if (bleBluetooth == nil) {
        bleBluetooth = [self.multipleBluetoothController.connectingDictionary objectForKey:peripheral.identifier.UUIDString];
    }
    if (bleBluetooth != nil) {
        [bleBluetooth didDisconnectPeripheral:error];
        [self.multipleBluetoothController removeConnectedBleBluetooth:bleBluetooth];
        [self.multipleBluetoothController removeConnectingBle:bleBluetooth];
    }
}

#pragma mark - 设置回调
- (void)setOnScanStartedBlock:(nullable HYHOnScanStartedBlock)onScanStartedBlock{
    HYHBleScanner.scanner.onScanStartedBlock = onScanStartedBlock;
}
-(void)setOnLeScanBlock:(nullable HYHOnLeScanBlock)onLeScanBlock{
    HYHBleScanner.scanner.onLeScanBlock = onLeScanBlock;
}
-(void)setOnScanFinishBlock:(nullable HYHOnScanFinishBlock)onScanFinishBlock{
    HYHBleScanner.scanner.onScanFinishBlock = onScanFinishBlock;
}
-(void)setOnScanFilterBlock:(nullable HYHOnScanFilterBlock)onScanFilterBlock{
    HYHBleScanner.scanner.onScanFilterBlock = onScanFilterBlock;
}

-(void)restoreCentralManagerState:(NSDictionary<NSString *,id> *)dict{
    NSArray<CBPeripheral *> *restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    NSMutableArray<HYHBleDevice *> *bleDevices = [NSMutableArray array];
    for (CBPeripheral *peripheral in restoredPeripherals) {
        [bleDevices addObject:[[HYHBleDevice alloc]initWithPeripheral:peripheral]];
    }
    BOOL needRestore = YES;
    if (self.centralManagerwillRestoreStateBlock) {
        needRestore = self.centralManagerwillRestoreStateBlock(self.centralManager,bleDevices);
    }
    if (needRestore) {
        for (HYHBleDevice *device in bleDevices) {
            // 尝试恢复连接
            if (device.peripheral.state == CBPeripheralStateConnected || device.peripheral.state == CBPeripheralStateConnecting) {
                [self connect:device];
            }else{
                [self.centralManager cancelPeripheralConnection:device.peripheral];
            }
        }
    }else{
        for (CBPeripheral *peripheral in restoredPeripherals) {
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}

#pragma mark - 功能性方法
-(NSArray<HYHBleDevice *> *)getAllConnectedDevice{
    NSMutableArray<HYHBleDevice *> *array = [NSMutableArray array];
    for (HYHBleBluetooth *bleBluetooth in [self.multipleBluetoothController.bleLruDictionary allValues]) {
        [array addObject:bleBluetooth.bleDevice];
    }
    return array;
}
-(NSArray<HYHBleDevice *> *)getAllConnectingDevice{
    NSMutableArray<HYHBleDevice *> *array = [NSMutableArray array];
    for (HYHBleBluetooth *bleBluetooth in [self.multipleBluetoothController.connectingDictionary allValues]) {
        [array addObject:bleBluetooth.bleDevice];
    }
    return array;
}
-(void)disconnect:(HYHBleDevice *)bleDevice{
    [self.multipleBluetoothController disconnect:bleDevice];
}
-(void)disconnectAllDevice{
    [self.multipleBluetoothController disconnectAllDevice];
}
-(void)cancelConnecting:(HYHBleDevice *)bleDevice{
    [self.multipleBluetoothController cancelConnecting:bleDevice];
}
-(void)cancelAllConnectingDevice{
    [self.multipleBluetoothController cancelAllConnectingDevice];
}
-(nullable HYHBleDevice *)getConnectedDeviceWithIdentifier:(NSString *)identifier{
    for (NSString *key in self.multipleBluetoothController.bleLruDictionary) {
        HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:key];
        if ([bleBluetooth.bleDevice.peripheral.identifier.UUIDString isEqualToString:identifier]) {
            return bleBluetooth.bleDevice;
        }
    }
    return nil;
}
-(void)setBleConnectCallback:(HYHBleDevice *)bleDevice callback:(HYHBleConnectCallback *)bleConnectCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        bleBluetooth.connectCallback = bleConnectCallback;
    }
}
-(void)setBleDiscoverCallback:(HYHBleDevice *)bleDevice callback:(HYHBleDiscoverCallback *)bleDiscoverCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        bleBluetooth.discoverCallback = bleDiscoverCallback;
    }
}
-(void)removeBleReadCallback:(HYHBleDevice *)bleDevice characteristic:(CBCharacteristic *)characteristic callback:(HYHBleReadCallback *)bleReadCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        [bleBluetooth removeReadOperator:characteristic.UUID.UUIDString];
    }
}
-(void)removeBleWriteCallback:(HYHBleDevice *)bleDevice characteristic:(CBCharacteristic *)characteristic callback:(HYHBleWriteCallback *)bleWriteCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        [bleBluetooth removeWriteOperator:characteristic.UUID.UUIDString];
    }
}
-(void)removeBleNotifyCallback:(HYHBleDevice *)bleDevice characteristic:(CBCharacteristic *)characteristic callback:(HYHBleNotifyCallback *)bleNotifyCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        [bleBluetooth removeNotifyOperator:characteristic.UUID.UUIDString];
    }
}
-(void)removeBleRssiCallback:(HYHBleDevice *)bleDevice callback:(HYHBleRssiCallback *)bleRssiCallback{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        bleBluetooth.bleRssiOperator = nil;
    }
}
-(void)clearCharacterCallback:(HYHBleDevice *)bleDevice{
    HYHBleBluetooth *bleBluetooth = [self.multipleBluetoothController.bleLruDictionary objectForKey:bleDevice.deviceKey];
    if (bleBluetooth != nil) {
        [bleBluetooth clearCharacterOperator];
    }
}
@end
