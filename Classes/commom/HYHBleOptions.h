//
//  HYHBleOptions.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface HYHBleOptions : NSObject

@property (assign,nonatomic) NSInteger maxConnectCount;
@property (assign,nonatomic) NSInteger connectOverTime;
@property (assign,nonatomic) NSInteger operatorOverTime;
@property (assign,nonatomic) NSUInteger splitWriteNum;
/**
 centralManager创建的参数
 @see CBCentralManagerOptionShowPowerAlertKey  蓝牙power没打开时alert提示框
 @see CBCentralManagerOptionRestoreIdentifierKey 重设centralManager恢复的IdentifierKey
 */
@property (nonatomic, copy,nullable) NSDictionary *centralManagerOptions;
/*!
 * 扫描参数,centralManager:scanForPeripheralsWithServices:self.scanForPeripheralsWithServices options:self.scanForPeripheralsWithOptions
 * An optional dictionary specifying options for the scan.
 *  @see                centralManager:scanForPeripheralsWithServices
 *  @seealso            CBCentralManagerScanOptionAllowDuplicatesKey 对应一个Bool值，指示扫描应该在不进行重复过滤的情况下运行。缺省情况下，发现多个相同的外围设备合并成一个发现事件回调，当为true时，它会对多个相同外围设备追个发起发现事件回调，但这样做可能对电池寿命和应用性能有不利影响。（由于外围设备会每秒钟不断的对外广播多个数据包，这样就会出现重复的发现事件）。关闭默认行为对于某些用例可能很有用，例如根据外围设备的接近度（使用外围设备接收信号强度指示器 (RSSI) 值）启动与外围设备的连接
 *
 *  @seealso            CBCentralManagerScanOptionSolicitedServiceUUIDsKey 对应一个Bool值，指示如果成功建立连接时应用程序挂起，系统应该显示给定外设的连接警报。这对于没有指定中央设备支持后台模式并且不能显示自己的警报的应用程序很有用。如果有多个应用程序为给定的外设请求通知，最近在前台的应用程序将收到警报。
 */
@property (nonatomic, copy,nullable) NSDictionary *scanForPeripheralsWithOptions;


/*!
 *  连接设备的参数
 *  @see connectPeripheral:options:
 *  options             An optional dictionary specifying connection behavior options.
 *  @see                centralManager:didConnectPeripheral:
 *  @see                centralManager:didFailToConnectPeripheral:error:
 *  @seealso            CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnNotificationKey
 */
@property (nonatomic, copy,nullable) NSDictionary *connectPeripheralWithOptions;

/*!
 *扫描参数,centralManager:scanForPeripheralsWithServices:self.scanForPeripheralsWithServices options:self.scanForPeripheralsWithOptions
 *@serviceUUIDs A list of <code>CBUUID</code> objects representing the service(s) to scan for.
 *@see                centralManager:scanForPeripheralsWithServices
 */
@property (nonatomic, copy,nullable) NSArray<CBUUID *> *scanForPeripheralsWithServices;

// [peripheral discoverServices:self.discoverWithServices];
@property (nonatomic, copy,nullable) NSArray<CBUUID *> *discoverWithServices;

// [peripheral discoverCharacteristics:self.discoverWithCharacteristics forService:service];
@property (nonatomic, copy,nullable) NSArray<CBUUID *> *discoverWithCharacteristics;

#pragma mark - 构造方法
- (nonnull instancetype)initWithCentralManagerOptions:(nullable NSDictionary *)centralManagerOptions scanForPeripheralsWithOptions:(nullable NSDictionary *)scanForPeripheralsWithOptions
               connectPeripheralWithOptions:(nullable NSDictionary *)connectPeripheralWithOptions;

- (instancetype)initWithCentralManagerOptions:(nullable NSDictionary *)centralManagerOptions scanForPeripheralsWithOptions:(NSDictionary *)scanForPeripheralsWithOptions
                connectPeripheralWithOptions:(NSDictionary *)connectPeripheralWithOptions
              scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                        discoverWithServices:(NSArray *)discoverWithServices
        discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics;
@end

NS_ASSUME_NONNULL_END
