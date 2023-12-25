//
//  HYHBleBluetooth.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import <Foundation/Foundation.h>
#import "HYHBleDevice.h"
#import "HYHBleConnectCallback.h"
#import "HYHBleDiscoverCallback.h"
NS_ASSUME_NONNULL_BEGIN
@class HYHBleOperator;
@class HYHBleSequenceOperator;
@interface HYHBleBluetooth : NSObject<CBPeripheralDelegate>

@property (strong,nonatomic,readonly) HYHBleDevice *bleDevice;
@property (copy,nonatomic) NSString *deviceKey;
@property (nullable,strong,nonatomic) HYHBleConnectCallback *connectCallback;
@property (nullable,strong,nonatomic) HYHBleDiscoverCallback *discoverCallback;
@property (strong,nonatomic,nullable) HYHBleOperator *bleRssiOperator;
-(instancetype)init:(HYHBleDevice *)bleDevice;
-(void)connect:(NSDictionary *)connectOptions overTime:(NSInteger)overTime;
-(void)disconnect;
-(void)cancelConnect;
-(void)removeConnectCallback;
-(void)destroy;

-(void)didConnectPeripheral;
-(void)didFailToConnectPeripheral:(NSError *)error;
-(void)didDisconnectPeripheral:(NSError *)error;

- (void)discoverServices:(nullable NSArray<CBUUID *> *)discoverServices;
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic;

-(void)addNotifyOperator:(HYHBleOperator *)bleOperator;
-(void)removeNotifyOperator:(NSString *)uuid;
-(void)addWriteOperator:(HYHBleOperator *)bleOperator;
-(void)removeWriteOperator:(NSString *)uuid;
-(void)addReadOperator:(HYHBleOperator *)bleOperator;
-(void)removeReadOperator:(NSString *)uuid;
-(void)clearCharacterOperator;

-(void)removeOperateQueueWithIdentifier:(nullable NSString *)identifier;
-(void)removeOperateQueue;
-(void)addOperatorToQueueWithIdentifier:(nullable NSString *)identifier sequenceBleOperator:(HYHBleSequenceOperator *)sequenceBleOperator;
-(void)addOperatorToQueue:(HYHBleSequenceOperator *)sequenceBleOperator;
@end


NS_ASSUME_NONNULL_END
