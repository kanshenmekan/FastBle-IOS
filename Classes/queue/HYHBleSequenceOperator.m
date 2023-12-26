//
//  HYHBleOperateTask.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import "HYHBleSequenceOperator.h"

@implementation HYHBleSequenceOperator
- (void)setTimeout:(NSInteger)timeout{
    if (self.continuous) {
        if (timeout < 0) {
            timeout = 1000;
        }
    }
    _timeout = timeout;
}
- (void)execute:(nonnull HYHBleBluetooth *)bleBluetooth {

}

@end
