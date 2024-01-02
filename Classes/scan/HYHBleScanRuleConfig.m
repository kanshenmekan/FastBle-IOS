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
- (instancetype)init{
    if (self = [super init]) {
        _names = [NSArray array];
        _identifiers = [NSArray array];
        _fuzzyName = NO;
        _scanTimeout = DEFAULT_SCAN_TIME;
    }
    return self;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    HYHBleScanRuleConfig *copy = [[[self class] allocWithZone:zone] init];
    copy.identifiers = [self.identifiers copy];
    copy.names = [self.names copy];
    copy.fuzzyName = self.fuzzyName;
    copy.scanTimeout = self.scanTimeout;
    
    return copy;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone { 
    HYHBleScanRuleConfig *copy = [[[self class] allocWithZone:zone] init];
    copy.identifiers = [self.identifiers mutableCopy];
    copy.names = [self.names mutableCopy];
    copy.fuzzyName = self.fuzzyName;
    copy.scanTimeout = self.scanTimeout;

    return copy;
}

@end
