//
//  HYHDataUtils.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHQueue.h"
NS_ASSUME_NONNULL_BEGIN

@interface HYHDataUtils : NSObject
+(HYHQueue<NSData *> *)splitPacketForByte:(NSData *)data length:(NSInteger)length;
@end

NS_ASSUME_NONNULL_END
