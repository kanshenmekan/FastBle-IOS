//
//  HYHBleConnectCallback.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/18.
//

#import "HYHBleConnectCallback.h"

@implementation HYHBleConnectCallback
- (instancetype)init{
    if (self = [super init]) {
        _onStartConnectBlock = nil;
        _onConnectSuccessBlock = nil;
        _onConnectCancelBlock = nil;
        _onConnectFailBlock = nil;
        _onDisconnectBlock = nil;
    }
    return self;
}
@end
