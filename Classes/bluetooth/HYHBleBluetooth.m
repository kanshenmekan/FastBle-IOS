//
//  HYHBleBluetooth.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import "HYHBleBluetooth.h"
#import "HYHTimepiece.h"
#import "HYHCentralManager.h"
#import "HYHBleOperator.h"
#import "HYHBleOperatorQueue.h"
@interface HYHBleBluetooth()
@property (strong,nonatomic,nullable) NSError *connectException;
@property (strong,nonatomic) HYHTimepiece *connectTimer;

@property (strong,nonatomic) NSMutableDictionary<NSString *,HYHBleOperator *> *bleNotifyOperatorDic;
@property (strong,nonatomic) NSMutableDictionary<NSString *,HYHBleOperator *> *bleWriteOperatorDic;
@property (strong,nonatomic) NSMutableDictionary<NSString *,HYHBleOperator *> *bleReadOperatorDic;
@property (strong,nonatomic) NSMutableDictionary<NSString *,HYHBleOperatorQueue *> *bleOperatorQueueDic;
@end

@implementation HYHBleBluetooth
-(instancetype)init:(HYHBleDevice *)bleDevice{
    if (self = [super init]) {
        _bleDevice = bleDevice;
        _bleDevice.peripheral.delegate = self;
        _bleNotifyOperatorDic = [NSMutableDictionary dictionary];
        _bleWriteOperatorDic = [NSMutableDictionary dictionary];
        _bleReadOperatorDic = [NSMutableDictionary dictionary];
        _bleOperatorQueueDic = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)connect:(NSDictionary *)connectOptions overTime:(NSInteger)overTime{
    if (self.bleDevice.isConnected) {
        return;
    }
    //重置定时器
    [self startTimer:overTime];
    self.connectException = nil;
    if (self.connectCallback.onStartConnectBlock) {
        self.connectCallback.onStartConnectBlock(self.bleDevice);
    }
    /**不管之前是否在连接，都重置一下连接参数**/
    [[self centralManager]connectPeripheral:self.bleDevice.peripheral options:connectOptions];
}
-(void)startTimer:(NSInteger)overTime{
    [self stopConnectTimer];
    if (overTime > 0) {
        __weak typeof(self) weakSelf = self;
        self.connectTimer = [HYHTimepiece scheduleWithTime:overTime timeoutBlock:^{
            weakSelf.connectException = [HYHBleError timeoutException];
            [HYHCentralManager.sharedBleManager.centralManager cancelPeripheralConnection:self.bleDevice.peripheral];
        }];
    }
}
-(void)stopConnectTimer{
    if (self.connectTimer && [self.connectTimer valid]) {
        [self.connectTimer cancelTimer];
    }
}
/**
 *  没有连接成功的时候，取消连接
 */
-(void)cancelConnect{
    if (self.bleDevice.isConnected) {
        return;
    }
    self.connectException = [[HYHBleError alloc]initWithDomain:HYHConnectExceptionDomain code:HYHBleErrorActiveCancelCode localizedDescription:@"cancelled before connected"];
    [HYHCentralManager.sharedBleManager.centralManager cancelPeripheralConnection:self.bleDevice.peripheral];
}
/**
 *  断开连接
 */
-(void)disconnect{
    self.connectException = nil;
    [HYHCentralManager.sharedBleManager.centralManager cancelPeripheralConnection:self.bleDevice.peripheral];
}
-(NSString *)deviceKey{
    return self.bleDevice.deviceKey;
}
-(CBCentralManager *)centralManager{
    return HYHCentralManager.sharedBleManager.centralManager;
}
-(void)destroy{
    [self disconnect];
    [self stopConnectTimer];
    [self removeConnectCallback];
    [self removeDiscoverCallback];
    [self clearCharacterOperator];
    
    self.bleRssiOperator = nil;
}
-(void)removeConnectCallback{
    self.connectCallback.onStartConnectBlock = nil;
    self.connectCallback.onConnectSuccessBlock = nil;
    self.connectCallback.onConnectFailBlock = nil;
    self.connectCallback.onDisconnectBlock = nil;
    self.connectCallback.onConnectCancelBlock = nil;
    self.connectCallback = nil;
}
-(void)removeDiscoverCallback{
    self.discoverCallback.didDiscoverServicesBlock = nil;
    self.discoverCallback.didDiscoverCharacteristicsForServiceBlock = nil;
    self.discoverCallback.didDiscoverDescriptorsForCharacteristicBlock = nil;
    self.discoverCallback = nil;
}
- (void)discoverServices:(NSArray<CBUUID *> *)discoverServices{
    if (!self.bleDevice.isConnected) {
        return;
    }
    [self.bleDevice.peripheral discoverServices:discoverServices];
}
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service{
    if (!self.bleDevice.isConnected) {
        return;
    }
    [self.bleDevice.peripheral discoverCharacteristics:characteristicUUIDs forService:service];
}
-(void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic{
    if (!self.bleDevice.isConnected) {
        return;
    }
    [self.bleDevice.peripheral discoverDescriptorsForCharacteristic:characteristic];
}
#pragma mark - 添加write,read,notify,indicate操作
-(void)addNotifyOperator:(HYHBleOperator *)bleOperator{
    if (bleOperator.characteristic == nil) {
        return;
    }
    @synchronized (self.bleNotifyOperatorDic) {
        NSString *uuid = bleOperator.characteristic.UUID.UUIDString;
        HYHBleOperator *oldOperator = self.bleNotifyOperatorDic[uuid];
        if (oldOperator != bleOperator) {
            if (oldOperator != nil) {
                [oldOperator destroy];
            }
            self.bleNotifyOperatorDic[uuid] = bleOperator;
        }
    }
}
-(void)removeNotifyOperator:(NSString *)uuid{
    @synchronized (self.bleNotifyOperatorDic) {
        HYHBleOperator *operator = self.bleNotifyOperatorDic[uuid];
        if (operator != nil) {
            [operator destroy];
        }
        [self.bleNotifyOperatorDic removeObjectForKey:uuid];
    }
}

-(void)addWriteOperator:(HYHBleOperator *)bleOperator{
    if (bleOperator.characteristic == nil) {
        return;
    }
    @synchronized (self.bleWriteOperatorDic) {
        NSString *uuid = bleOperator.characteristic.UUID.UUIDString;
        HYHBleOperator *oldOperator = self.bleWriteOperatorDic[uuid];
        if (oldOperator != bleOperator) {
            if (oldOperator != nil) {
                [oldOperator destroy];
            }
            self.bleWriteOperatorDic[uuid] = bleOperator;
        }
    }
}
-(void)removeWriteOperator:(NSString *)uuid{
    @synchronized (self.bleWriteOperatorDic) {
        HYHBleOperator *operator = self.bleWriteOperatorDic[uuid];
        if (operator != nil) {
            [operator destroy];
        }
        [self.bleWriteOperatorDic removeObjectForKey:uuid];
    }
}
-(void)addReadOperator:(HYHBleOperator *)bleOperator{
    if (bleOperator.characteristic == nil) {
        return;
    }
    @synchronized (self.bleReadOperatorDic) {
        NSString *uuid = bleOperator.characteristic.UUID.UUIDString;
        HYHBleOperator *oldOperator = self.bleReadOperatorDic[uuid];
        if (oldOperator != bleOperator) {
            if (oldOperator != nil) {
                [oldOperator destroy];
            }
            self.bleReadOperatorDic[uuid] = bleOperator;
        }
    }
}
-(void)removeReadOperator:(NSString *)uuid{
    @synchronized (self.bleReadOperatorDic) {
        HYHBleOperator *operator = self.bleReadOperatorDic[uuid];
        if (operator != nil) {
            [operator destroy];
        }
        [self.bleReadOperatorDic removeObjectForKey:uuid];
    }
}
-(void)clearCharacterOperator{
    for (NSString *key in self.bleReadOperatorDic) {
        [self.bleReadOperatorDic[key] destroy];
    }
    [self.bleReadOperatorDic removeAllObjects];
    
    for (NSString *key in self.bleWriteOperatorDic) {
        [self.bleWriteOperatorDic[key] destroy];
    }
    [self.bleWriteOperatorDic removeAllObjects];
    
    for (NSString *key in self.bleNotifyOperatorDic) {
        [self.bleNotifyOperatorDic[key] destroy];
    }
    [self.bleNotifyOperatorDic removeAllObjects];
    
    for (NSString *key in self.bleOperatorQueueDic) {
        [self.bleOperatorQueueDic[key] destroy];
    }
    [self.bleOperatorQueueDic removeAllObjects];
}
#pragma mark - 队列
-(void)createOperateQueueWithIdentifier:(nullable NSString *)identifier{
    @synchronized (self.bleOperatorQueueDic) {
        if (identifier == nil || [identifier isEqualToString:@""]) {
            identifier = self.deviceKey;
        }
        HYHBleOperatorQueue *queue = [self.bleOperatorQueueDic objectForKey:identifier];
        if (queue != nil) {
        }else{
            queue = [[HYHBleOperatorQueue alloc]initWithKey:identifier bleBluetooth:self];
            self.bleOperatorQueueDic[identifier] = queue;
        }
        [queue resume];
    }
}
-(void)removeAllOperateQueue{
    @synchronized (self.bleOperatorQueueDic) {
        for (NSString * identifier in self.bleOperatorQueueDic) {
            HYHBleOperatorQueue *queue = [self.bleOperatorQueueDic objectForKey:identifier];
            [queue destroy];
        }
        [self.bleOperatorQueueDic removeAllObjects];
    }
}
-(void)removeOperateQueue{
    [self removeOperateQueueWithIdentifier:nil];
}
-(void)removeOperateQueueWithIdentifier:(nullable NSString *)identifier{
    @synchronized (self.bleOperatorQueueDic) {
        if(identifier == nil)identifier = self.deviceKey;
        HYHBleOperatorQueue *queue = [self.bleOperatorQueueDic objectForKey:identifier];
        if (queue != nil) {
            [queue destroy];
            [self.bleOperatorQueueDic removeObjectForKey:identifier];
        }
    }
}
-(void)addOperatorToQueue:(HYHBleSequenceOperator *)sequenceBleOperator{
    [self addOperatorToQueueWithIdentifier:nil sequenceBleOperator:sequenceBleOperator];
}
-(void)addOperatorToQueueWithIdentifier:(nullable NSString *)identifier sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator{
    @synchronized (self) {
        if (identifier == nil) {
            identifier = self.deviceKey;
        }
        [self createOperateQueueWithIdentifier:identifier];
        [self.bleOperatorQueueDic[identifier] offer:sequenceBleOperator];
    }
}
#pragma mark - CBCentralManager
-(void)didConnectPeripheral{
    [self stopConnectTimer];
    self.connectException = nil;
    if (self.connectCallback && self.connectCallback.onConnectSuccessBlock) {
        self.connectCallback.onConnectSuccessBlock(self.bleDevice);
    }
    [self.bleDevice.peripheral discoverServices:self.discoverCallback.discoverWithServices];
}

-(void)didFailToConnectPeripheral:(NSError *)error{
    self.connectException = nil;
    [self stopConnectTimer];
    if (self.connectCallback && self.connectCallback.onConnectFailBlock) {
        self.connectCallback.onConnectFailBlock(self.bleDevice, error);
    }
    [self removeConnectCallback];
    [self removeDiscoverCallback];
    [self clearCharacterOperator];
    self.bleRssiOperator = nil;
}

-(void)didDisconnectPeripheral:(NSError *)error{
    [self stopConnectTimer];
    if (self.connectException == nil) {
        if (self.connectCallback && self.connectCallback.onDisconnectBlock) {
            if (error == nil) {
                self.connectCallback.onDisconnectBlock(self.bleDevice, nil);
            }else{
                self.connectCallback.onDisconnectBlock(self.bleDevice, error);
            }
        }
    }else{
        if (self.connectException.domain == HYHConnectExceptionDomain && self.connectException.code == HYHBleErrorActiveCancelCode) {
            if (self.connectCallback && self.connectCallback.onConnectCancelBlock) {
                self.connectCallback.onConnectCancelBlock(self.bleDevice);
            }
        }else{
            if (self.connectCallback && self.connectCallback.onConnectFailBlock) {
                self.connectCallback.onConnectFailBlock(self.bleDevice, self.connectException);
            }
        }
    }
    [self removeConnectCallback];
    [self removeDiscoverCallback];
    [self clearCharacterOperator];
    self.bleRssiOperator = nil;
}
#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:self.discoverCallback.discoverWithCharacteristics forService:service];
    }
    if (self.discoverCallback && self.discoverCallback.didDiscoverServicesBlock) {
        self.discoverCallback.didDiscoverServicesBlock(self.bleDevice,error);
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (self.discoverCallback && self.discoverCallback.didDiscoverCharacteristicsForServiceBlock) {
        self.discoverCallback.didDiscoverCharacteristicsForServiceBlock(self.bleDevice, service, error);
    }
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (self.discoverCallback && self.discoverCallback.didDiscoverDescriptorsForCharacteristicBlock) {
        self.discoverCallback.didDiscoverDescriptorsForCharacteristicBlock(self.bleDevice, characteristic, error);
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying) {
        for (NSString *key in self.bleNotifyOperatorDic) {
            if ([self.bleNotifyOperatorDic[key].characteristic.UUID isEqual:characteristic.UUID]) {
                HYHBleOperator *operator = self.bleNotifyOperatorDic[key];
                [operator stopOperateTimer];
                if (![operator.operateCallback isMemberOfClass:HYHBleNotifyCallback.class]) {
                    break;
                }
                HYHBleNotifyCallback *callback = (HYHBleNotifyCallback *)operator.operateCallback;
                if (callback.bleNotifyCharacteristicChangedBlock) {
                    callback.bleNotifyCharacteristicChangedBlock(self.bleDevice, characteristic, characteristic.value);
                }
            }
        }
    }else{
        for (NSString *key in self.bleReadOperatorDic) {
            if ([self.bleReadOperatorDic[key].characteristic.UUID isEqual:characteristic.UUID]) {
                HYHBleOperator *operator = self.bleReadOperatorDic[key];
                [operator stopOperateTimer];
                if (![operator.operateCallback isMemberOfClass:HYHBleReadCallback.class]) {
                    break;
                }
                HYHBleReadCallback *callback = (HYHBleReadCallback *)operator.operateCallback;
                
                if (error) {
                    if (callback.bleReadSuccessBlock) {
                        callback.bleReadFailureBlock(self.bleDevice, characteristic, error);
                    }
                }else{
                    if (callback.bleReadFailureBlock) {
                        callback.bleReadSuccessBlock(self.bleDevice, characteristic, characteristic.value);
                    }
                }
            }
        }
    }

    
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    for (NSString *key in self.bleNotifyOperatorDic) {
        if ([self.bleNotifyOperatorDic[key].characteristic.UUID isEqual:characteristic.UUID]) {
            HYHBleOperator *operator = self.bleNotifyOperatorDic[key];
            [operator stopOperateTimer];
            if (![operator.operateCallback isMemberOfClass:HYHBleNotifyCallback.class]) {
                break;
            }
            HYHBleNotifyCallback *callback = (HYHBleNotifyCallback *)operator.operateCallback;
            if (error) {
                if (!characteristic.isNotifying) {
                    if (callback.bleNotifyFailureBlock) {
                        callback.bleNotifyFailureBlock(self.bleDevice, characteristic,error);
                    }
                }
            }else{
                if (characteristic.isNotifying) {
                    if (callback.bleNotifySuccessBlock) {
                        callback.bleNotifySuccessBlock(self.bleDevice, characteristic);
                    }
                }else{
                    if (callback.bleNotifyCancelBlock) {
                        callback.bleNotifyCancelBlock(self.bleDevice, characteristic);
                    }
                }
            }
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    for (NSString *key in self.bleWriteOperatorDic) {
        if ([self.bleWriteOperatorDic[key].characteristic.UUID isEqual:characteristic.UUID]) {
            HYHBleOperator *operator = self.bleWriteOperatorDic[key];
            [operator stopOperateTimer];
            if (![operator.operateCallback isMemberOfClass:HYHBleWriteCallback.class]) {
                break;
            }
            HYHBleWriteCallback *callback = (HYHBleWriteCallback *)operator.operateCallback;
            if (error) {
                if (callback.bleWriteFailureBlock) {
                    callback.bleWriteFailureBlock(self.bleDevice, characteristic,error, HYHBleOperateWriteSingleData, HYHBleOperateWriteSingleData, operator.data, operator.data, YES);
                }
            
            }else{
                if (callback.bleWriteSuccessBlock) {
                    callback.bleWriteSuccessBlock(self.bleDevice, characteristic, HYHBleOperateWriteSingleData, HYHBleOperateWriteSingleData, operator.data, operator.data);
                }
            }
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (self.bleRssiOperator) {
        [self.bleRssiOperator stopOperateTimer];
        if (![self.bleRssiOperator.operateCallback isMemberOfClass:HYHBleRssiCallback.class]) {
            return;
        }
        HYHBleRssiCallback *callback = (HYHBleRssiCallback *)self.bleRssiOperator.operateCallback;
        if (error) {
            if (callback.bleReadRssiFailure) {
                callback.bleReadRssiFailure(self.bleDevice, error);
            }
        }else{
            if (callback.bleReadRssiSuccess) {
                callback.bleReadRssiSuccess(self.bleDevice, RSSI.integerValue);
            }
        }
    }
}
@end
