//
//  HYHBleException.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const HYHBleTimeOutDomain;
FOUNDATION_EXPORT NSErrorDomain const HYHConnectExceptionDomain;
FOUNDATION_EXPORT NSErrorDomain const HYHOtherExceptionDomain;
typedef enum : NSUInteger {
    HYHBleErrorTimeoutCode = 100,
    HYHBleErrorOtherCode = 102,
    HYHBleErrorNotSupportBleCode = 2005,
    HYHBleErrorBluetoothNotEnabledCode = 2006,
    HYHBleErrorDeviceNotConnectedCode = 2007,
    HYHBleErrorCharacteristicsNotSupportCode = 2012,
    HYHBleErrorActiveCancelCode = 2014,
} HYHBleErrorCode;

@interface HYHBleError : NSError
+(HYHBleError *)timeoutException;
-(instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;
@end

NS_ASSUME_NONNULL_END
