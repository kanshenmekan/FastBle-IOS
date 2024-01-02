//
//  HYHBleException.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import "HYHBleError.h"

NSErrorDomain const HYHBleTimeOutDomain = @"HYH_TIME_OUT";
NSErrorDomain const HYHConnectExceptionDomain = @"HYH_CONNECT_EXCEPTION";
NSErrorDomain const HYHOtherExceptionDomain = @"HYH_OTHER_EXCEPTOPN";
@implementation HYHBleError
+ (HYHBleError *)timeoutException{
    return [[HYHBleError alloc]initWithDomain:HYHBleTimeOutDomain code:HYHBleErrorTimeoutCode userInfo:@{NSLocalizedDescriptionKey:@"Time out"}];
}
- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription{
    return [self initWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}
@end
