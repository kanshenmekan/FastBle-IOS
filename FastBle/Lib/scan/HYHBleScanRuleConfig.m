//
//  HYHBleScanRuleConfig.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import "HYHBleScanRuleConfig.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface HYHBleScanRuleConfig()

@end
@implementation HYHBleScanRuleConfig
static NSInteger DEFAULT_SCAN_TIME = 10;
-(instancetype)init{
    if (self = [super init]) {
        _names = [NSMutableArray array];
        _identifiers = [NSMutableArray array];
        _fuzzyName = NO;
        _scanTimeout = DEFAULT_SCAN_TIME;
    }
    return self;
}
@end
