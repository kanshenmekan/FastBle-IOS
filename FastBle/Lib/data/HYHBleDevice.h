//
//  HYHBleDevice.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface HYHBleDevice : NSObject
-(instancetype) initWithDict:(NSDictionary *)dict;
-(instancetype) initWithPeripheral:(CBPeripheral *)peripheral;
@property (strong, nonatomic,readonly) CBPeripheral *peripheral;
@property (strong, nonatomic,readonly,nullable) NSDictionary *advertisementData;
@property (strong,nonatomic,readonly,nullable) NSNumber *RSSI;
@property (copy,nonatomic,readonly,nullable) NSString *name;
@property (copy,nonatomic,nullable) NSString *alias;

@property (assign,nonatomic,readonly) BOOL isConnected;
@property (assign,nonatomic,readonly) BOOL isConnecting;
@property (copy,nonatomic,readonly) NSString *deviceKey;

-(void)putValue:(id)value forKey:(NSString *) key;

-(BOOL)isSameDevice:(HYHBleDevice *)bleDevice;
-(nullable id)getWithKey:(NSString *)key;

-(BOOL)isSamePeripheral:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
