//
//  HYHDataUtils.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import "HYHDataUtils.h"

@implementation HYHDataUtils
+(HYHQueue<NSData *> *)splitPacketForByte:(NSData *)data length:(NSInteger)length{
    HYHQueue<NSData *> *queue = [HYHQueue arrayQueue];
    if(data != nil){
        NSUInteger index = 0;
        do {
            NSData *surplusData = [NSData dataWithBytes:data.bytes+index length:data.length-index];
            NSData *currentData;
            if(surplusData.length <= length){
                currentData = [NSData dataWithBytes:surplusData.bytes length:surplusData.length];
                index += surplusData.length;
            }else{
                currentData = [NSData dataWithBytes:surplusData.bytes length:length];
                index += length;
            }
            [queue offer:currentData];
        } while (index < data.length);
    }
    return queue;
}
@end
