//
//  ViewController.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import "ViewController.h"
#import "HYHCentralManager.h"
#import "HYHBleLruDictionary.h"
#import "HYHBlockingQueue.h"
#import "HYHSequenceWriteOperator.h"
@interface ViewController ()
@property (strong,nonatomic) HYHBleDevice *oldDevice;
@property (strong,nonatomic) HYHBleDevice *deviceNew;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) IBOutlet UIButton *writeBtn;
@property (weak, nonatomic) IBOutlet UIButton *notifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *rssiBtn;
@property (weak, nonatomic) IBOutlet UIButton *mtuBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             //蓝牙power没打开时alert提示框
                             [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                             //重设centralManager恢复的IdentifierKey
                             @"HYHBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                             nil];
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    HYHCentralManager.sharedBleManager.bleOption = [[HYHBleOptions alloc]initWithCentralManagerOptions:options scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil];
    [HYHCentralManager.sharedBleManager initManager];
    [HYHCentralManager.sharedBleManager setOnScanStartedBlock:^(HYHBleError *error) {
        NSLog(@"setOnScanStartedBlock %@",error);
    }];
    [HYHCentralManager.sharedBleManager setOnLeScanBlock:^(HYHBleDevice * _Nonnull oldDevice, HYHBleDevice * _Nonnull newDevice, BOOL scannedBefore) {
        NSLog(@"setOnLeScanBlock %@,%@,%@",oldDevice,newDevice,scannedBefore?@"YES":@"NO");
        if (scannedBefore) {
            self.oldDevice = oldDevice;
            self.deviceNew = newDevice;
        }
    }];
    [HYHCentralManager.sharedBleManager setOnScanFinishBlock:^(NSArray<HYHBleDevice *> * _Nonnull deviceArray) {
        NSLog(@"setOnScanFinishBlock %@",deviceArray);
    }];
    [HYHCentralManager.sharedBleManager setOnScanFilterBlock:^BOOL(HYHBleDevice * _Nonnull bleDevice) {
        return [bleDevice.name hasPrefix:@"ThrustMe"];
    }];
    [HYHCentralManager.sharedBleManager setOnStartConnectBlock:^(HYHBleDevice * _Nonnull device) {
        NSLog(@"OnStartConnectBlock %@",device);
    }];
    [HYHCentralManager.sharedBleManager setOnConnectSuccessBlock:^(HYHBleDevice * _Nonnull device) {
        NSLog(@"OnConnectSuccessBlock %@",device);
    }];
    [HYHCentralManager.sharedBleManager setOnConnectCancelBlock:^(HYHBleDevice * _Nonnull device) {
        NSLog(@"OnConnectCancelBlock %@",device);
    }];
    [HYHCentralManager.sharedBleManager setOnConnetFailBlock:^(HYHBleDevice * _Nonnull device, NSError * _Nonnull error) {
        NSLog(@"OnConnetFailBlock %@ error = %@",device,error);
    }];
    [HYHCentralManager.sharedBleManager setOnDisconnectBlock:^(HYHBleDevice * _Nonnull device, NSError * _Nullable error) {
        NSLog(@"OnDisconnectBlock %@ error = %@",device,error);
    }];
    [HYHCentralManager.sharedBleManager setBleReadSuccessBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSData * _Nonnull data) {
        NSLog(@"BleReadSuccessBlock %@ data = %@",bleDevice,data);
    }];
    [HYHCentralManager.sharedBleManager setBleReadFailureBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSError * _Nonnull error) {
        NSLog(@"BleReadFailureBlock %@ error = %@",bleDevice,error);
    }];
    [HYHCentralManager.sharedBleManager setBleNotifySuccessBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic) {
        NSLog(@"BleNotifySuccessBlock %@ characteristic = %@",bleDevice,characteristic);
    }];
    [HYHCentralManager.sharedBleManager setBleNotifyFailureBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSError * _Nonnull error) {
        NSLog(@"BleNotifyFailureBlock %@ error = %@",bleDevice,error);
    }];
    [HYHCentralManager.sharedBleManager setBleNotifyCharacteristicChangedBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSData * _Nonnull data) {
        NSLog(@"BleNotifyCharacteristicChangedBlock %@ data = %@",bleDevice,data);
    }];
    [HYHCentralManager.sharedBleManager setBleNotifyCancelBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic) {
        NSLog(@"BleNotifyCancelBlock %@ characteristic = %@",bleDevice,characteristic);
    }];
    [HYHCentralManager.sharedBleManager setBleWriteSuccessBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nonnull characteristic, NSInteger current, NSInteger total, NSData * _Nonnull justWrite, NSData * _Nonnull data) {
        NSLog(@"BleWriteSuccessBlock current = %lu total = %lu justwrite = %@ data = %@",current,total,justWrite,data);
    }];
    [HYHCentralManager.sharedBleManager setBleWriteFailureBlock:^(HYHBleDevice * _Nonnull bleDevice, CBCharacteristic * _Nullable characteristic, NSError * _Nonnull error, NSInteger current, NSInteger total, NSData * _Nullable justWrite, NSData * _Nullable data, BOOL isTotalFail) {
        NSLog(@"BleWriteFailureBlock current = %lu total = %lu justwrite = %@ data = %@ exception = %@",current,total,justWrite,data,error);
    }];
    [HYHCentralManager.sharedBleManager setBleReadRssiSuccess:^(HYHBleDevice * _Nonnull bleDevice, NSInteger rssi) {
        NSLog(@"BleReadRssiSuccess %ld",rssi);
    }];
    [HYHCentralManager.sharedBleManager setBleReadRssiFailure:^(HYHBleDevice * _Nonnull bleDevice, NSError * _Nonnull error) {
        NSLog(@"BleReadRssiFailure %@",error);
    }];
    [HYHCentralManager.sharedBleManager setCentralManagerwillRestoreStateBlock:^BOOL(CBCentralManager * _Nonnull central, NSArray<HYHBleDevice *> * _Nonnull restoreDevices) {
        NSLog(@"%@",restoreDevices);
        self.oldDevice = restoreDevices[0];
        return YES;
    }];
    [self.scanBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.connectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.readBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.writeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.notifyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rssiBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mtuBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)btnClick:(UIView *)view{
    if (view == self.scanBtn) {
        [HYHCentralManager.sharedBleManager startLeScan];
    }else if (view == self.connectBtn){
        if (self.oldDevice != nil) {
            [HYHCentralManager.sharedBleManager stopLeScan];
            [HYHCentralManager.sharedBleManager connect:self.oldDevice overTime:10];
        }
    }else if (view == self.readBtn){
        [HYHCentralManager.sharedBleManager readValueForCharacteristic:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"]];
    }else if (view == self.stopBtn){
        [HYHCentralManager.sharedBleManager stopNotify:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"]];
    }else if (view == self.notifyBtn){
        [HYHCentralManager.sharedBleManager notify:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"]];
    }else if (view == self.writeBtn){
        Byte head[500] = {0};
        head[0] = (Byte) 0xbb;
        head[1] = 0x01;
        head[2] = 0x02;
        head[3] = 0x03;
        head[4] = 0x04;
        head[5] = 0x05;
        head[20] = 0x20;
        NSData *data = [NSData dataWithBytes:head length:25];
        for (int i = 0; i<50; i++) {
            HYHSequenceWriteOperator *se = [[HYHSequenceWriteOperator alloc]initWithServiceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"0000ffe1-0000-1000-8000-00805F9B34FB"]];
            se.data = data;
            se.continuous = YES;
            [HYHCentralManager.sharedBleManager addOperatorToQueue:self.oldDevice sequenceBleOperator:se];
        }
//        [HYHCentralManager.sharedBleManager write:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"] data:data writeType:CBCharacteristicWriteWithResponse];
//        [HYHCentralManager.sharedBleManager write:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"] data:data writeType:CBCharacteristicWriteWithResponse];
//        [HYHCentralManager.sharedBleManager write:self.oldDevice serviceUUID:[CBUUID UUIDWithString:@"FFE0"] characteristicUUID:[CBUUID UUIDWithString:@"FFE1"] data:data split:NO splitNum:500 continueWhenLastFail:NO intervalBetweenTwoPackage:0 callback:nil writeType:CBCharacteristicWriteWithResponse];
//        head[0] = (Byte)0xcc;
        
    }else if(view == self.rssiBtn){
        [HYHCentralManager.sharedBleManager readRssi:self.oldDevice];
    }else if (view == self.mtuBtn){
        NSLog(@"123 %ld %ld",[self.oldDevice.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse],
              [self.oldDevice.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse]);
        [HYHCentralManager.sharedBleManager removeOperatorQueue:self.oldDevice];
    }
}
@end
