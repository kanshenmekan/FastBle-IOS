//
//  HYHCentralManager.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HYHBleScanRuleConfig.h"
#import "HYHBleDevice.h"
#import "HYHBleOptions.h"
#import "HYHBleConnectCallback.h"
#import "HYHBleDiscoverCallback.h"
#import "HYHBleReadCallback.h"
#import "HYHBleNotifyCallback.h"
#import "HYHBleWriteCallback.h"
#import "HYHBleRssiCallback.h"
#import "HYHBleSequenceOperator.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^HYHCentralManagerDidUpdateStateBlock)(CBCentralManager *central);
typedef BOOL(^HYHCentralManagerwillRestoreStateBlock)(CBCentralManager *central,NSArray<HYHBleDevice *> *restoreDevices);
typedef void(^HYHOnScanStartedBlock)(HYHBleError * _Nullable error);
typedef void(^HYHOnLeScanBlock)(HYHBleDevice *oldDevice,HYHBleDevice *newDevice,BOOL scannedBefore);
typedef void(^HYHOnScanFinishBlock)(NSArray<HYHBleDevice *> *deviceArray);
typedef BOOL(^HYHOnScanFilterBlock)(HYHBleDevice *bleDevice);

@interface HYHCentralManager : NSObject<CBCentralManagerDelegate>
@property (strong,nonatomic) HYHBleOptions *bleOption;
+ (instancetype)sharedBleManager;
-(void)initManager;
@property (strong,nonatomic,readonly) CBCentralManager *centralManager;
@property (nonatomic, copy) HYHCentralManagerDidUpdateStateBlock centralManagerDidUpdateStateBlock;
@property (nonatomic, copy) HYHCentralManagerwillRestoreStateBlock centralManagerwillRestoreStateBlock;
-(void)setBleScanCofig:(HYHBleScanRuleConfig *)bleScanCofig;
-(void)startLeScan;
-(void)stopLeScan;
-(BOOL)isScnning;
- (void)setOnScanStartedBlock:(nullable HYHOnScanStartedBlock)onScanStartedBlock;
-(void)setOnLeScanBlock:(nullable HYHOnLeScanBlock)onLeScanBlock;
-(void)setOnScanFinishBlock:(nullable HYHOnScanFinishBlock)onScanFinishBlock;
-(void)setOnScanFilterBlock:(nullable HYHOnScanFilterBlock)onScanFilterBlock;
-(void)destroy;
@property (nullable,copy,nonatomic) HYHOnStartConnectBlock onStartConnectBlock;
@property (nullable,copy,nonatomic) HYHOnConnectFailBlock onConnetFailBlock;
@property (nullable,copy,nonatomic) HYHOnConnectSuccessBlock onConnectSuccessBlock;
@property (nullable,copy,nonatomic) HYHOnDisconnectBlock onDisconnectBlock;
@property (nullable,copy,nonatomic) HYHOnConnectCancelBlock onConnectCancelBlock;
@property (nullable,copy,nonatomic) HYHBleDidDiscoverServicesBlock didDiscoverServicesBlock;
@property (nullable,copy,nonatomic) HYHBleDidDiscoverCharacteristicsForServiceBlock didDiscoverCharacteristicsForServiceBlock;
@property (nullable,copy,nonatomic) HYHBleDidDiscoverDescriptorsForCharacteristicBlock didDiscoverDescriptorsForCharacteristicBlock;

-(void)connect:(HYHBleDevice *)device;
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime;
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime options:(nullable NSDictionary *)options;
-(void)connect:(HYHBleDevice *)device overTime:(NSInteger)overTime options:(nullable NSDictionary *)options connectCallback:(nullable HYHBleConnectCallback *)connectCallback discoverCallback:(nullable HYHBleDiscoverCallback *)discoverCallback;

- (void)discoverServices:(HYHBleDevice *)device services:(nullable NSArray<CBUUID *> *)discoverServices;
- (void)discoverCharacteristics:(HYHBleDevice *)device characteristicUUIDs:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
- (void)discoverDescriptorsForCharacteristic:(HYHBleDevice *)device characteristic:(CBCharacteristic *)characteristic;


@property (nullable,copy,nonatomic) HYHBleReadSuccessBlock bleReadSuccessBlock;
@property (nullable,copy,nonatomic) HYHBleReadFailureBlock bleReadFailureBlock;
-(void)readValueForCharacteristic:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;
-(void)readValueForCharacteristic:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID bleReadCallback:(nullable HYHBleReadCallback *)bleReadCallback;

@property (nullable,copy,nonatomic) HYHBleNotifySuccessBlock bleNotifySuccessBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyFailureBlock bleNotifyFailureBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyCharacteristicChangedBlock bleNotifyCharacteristicChangedBlock;
@property (nullable,copy,nonatomic) HYHBleNotifyCancelBlock bleNotifyCancelBlock;
-(void)notify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;
-(void)notify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID notifyCallback:(nullable HYHBleNotifyCallback *)notifyCallback;
-(void)stopNotify:(HYHBleDevice *)device serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID;

@property (nullable,copy,nonatomic) HYHBleWriteSuccessBlock bleWriteSuccessBlock;
@property (nullable,copy,nonatomic) HYHBleWriteFailureBlock bleWriteFailureBlock;

-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data;
-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data writeType:(CBCharacteristicWriteType)writeType;
-(void)write:(HYHBleDevice *)bleDevice serviceUUID:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID data:(NSData *)data split:(BOOL)split splitNum:(NSInteger)splitNum continueWhenLastFail:(BOOL)continueWhenLastFail intervalBetweenTwoPackage:(NSInteger)intervalBetweenTwoPackage callback:(nullable HYHBleWriteCallback *)callback writeType:(CBCharacteristicWriteType)writeType;

@property (nullable,copy,nonatomic) HYHBleReadRssiSuccess bleReadRssiSuccess;
@property (nullable,copy,nonatomic) HYHBleReadRssiFailure bleReadRssiFailure;
-(void)readRssi:(HYHBleDevice *)bleDevice;
-(void)readRssi:(HYHBleDevice *)bleDevice bleRssiCallback:(nullable HYHBleRssiCallback *)bleRssiCallback;

-(void)addOperatorToQueue:(HYHBleDevice *)bleDevice identifier:(nullable NSString *)identifier sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator;
-(void)addOperatorToQueue:(HYHBleDevice *)bleDevice sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator;
-(void)removeOperatorQueue:(HYHBleDevice *)bleDevice identifier:(nullable NSString *)identifier;
-(void)removeOperatorQueue:(HYHBleDevice *)bleDevice;
@end

NS_ASSUME_NONNULL_END
