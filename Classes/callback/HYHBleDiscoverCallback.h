//
//  HYHBleDiscoverCallback.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import <Foundation/Foundation.h>
#import "HYHBleDevice.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHBleDidDiscoverServicesBlock)(HYHBleDevice *device,NSError *error);
typedef void(^HYHBleDidDiscoverCharacteristicsForServiceBlock)(HYHBleDevice *device,CBService *service,NSError *error);
typedef void(^HYHBleDidDiscoverDescriptorsForCharacteristicBlock)(HYHBleDevice *device,CBCharacteristic *characteristic,NSError *error);
@interface HYHBleDiscoverCallback : NSObject
@property (nullable,copy,nonatomic) HYHBleDidDiscoverServicesBlock didDiscoverServicesBlock;
@property (nullable,copy,nonatomic) HYHBleDidDiscoverCharacteristicsForServiceBlock didDiscoverCharacteristicsForServiceBlock;
@property (nullable,copy,nonatomic) HYHBleDidDiscoverDescriptorsForCharacteristicBlock didDiscoverDescriptorsForCharacteristicBlock;
@property (nonatomic,copy,nullable) NSArray<CBUUID *> *discoverWithServices;
@property (nonatomic,copy,nullable) NSArray<CBUUID *> *discoverWithCharacteristics;

- (instancetype)initWithDiscoverServices:(nullable NSArray<CBUUID *> *)discoverServices discoverCharacteristics:(nullable NSArray<CBUUID *> *)discoverCharacteristics;
@end

NS_ASSUME_NONNULL_END
