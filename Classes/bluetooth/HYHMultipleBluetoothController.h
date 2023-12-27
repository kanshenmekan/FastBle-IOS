//
//  HYHMultipleBluetoothController.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import <Foundation/Foundation.h>
#import "HYHBleLruDictionary.h"
#import "HYHBleBluetooth.h"
NS_ASSUME_NONNULL_BEGIN

@interface HYHMultipleBluetoothController : NSObject<HYHBleLruDictionaryDelegate>
@property (strong,nonatomic) HYHBleLruDictionary<NSString *,HYHBleBluetooth *> *bleLruDictionary;
@property (strong,nonatomic) HYHThreadSafeDictionary<NSString *,HYHBleBluetooth *> *connectingDictionary;

-(instancetype)initWithMaxConnectCount:(NSInteger)maxConnectCount;
-(HYHBleBluetooth *)buildConnectingBle:(HYHBleDevice *)device;
-(void)removeConnectingBle:(HYHBleBluetooth *)bleBluetooth;
-(void)addConnectedBleBluetooth:(HYHBleBluetooth *)bleBluetooth;
-(void)removeConnectedBleBluetooth:(HYHBleBluetooth *)bleBluetooth;
-(nullable HYHBleBluetooth *)getConnectedBleBluetooth:(HYHBleDevice *)bleDevice;
-(void)cancelConnecting:(HYHBleDevice *)device;
-(void)cancelAllConnectingDevice;
-(void)disconnect:(HYHBleDevice *)bleDevice;
-(void)disconnectAllDevice;
-(void)cancelOrDisconnect:(HYHBleDevice *)bleDevice;
-(void)destroy;
-(void)onBleOff;
@end

NS_ASSUME_NONNULL_END
