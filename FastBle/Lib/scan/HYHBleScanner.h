//
//  HYHBleScanner.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HYHBleScanRuleConfig.h"
#import "HYHBleDevice.h"
#import "HYHCentralManager.h"
NS_ASSUME_NONNULL_BEGIN


@interface HYHBleScanner : NSObject

@property (strong,nonatomic) HYHBleScanRuleConfig *bleScanCofig;
@property (copy,nonatomic,nullable) HYHOnScanStartedBlock onScanStartedBlock;
@property (copy,nonatomic,nullable) HYHOnLeScanBlock onLeScanBlock;
@property (copy,nonatomic,nullable) HYHOnScanFinishBlock onScanFinishBlock;
@property (copy,nonatomic,nullable) HYHOnScanFilterBlock onScanFilterBlock;
-(void)onBleOff;
+ (instancetype)scanner;
-(void)startLeScan;
- (void)stopLeScan;
-(void)removeScanCallback;
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END
