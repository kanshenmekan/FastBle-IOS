//
//  HYHBleSplitWriter.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "HYHBleOperator.h"
#import "HYHBleWriteCallback.h"
NS_ASSUME_NONNULL_BEGIN

@interface HYHBleSplitWriter : NSObject
@property (weak,nonatomic)  HYHBleOperator *weakBleOperator;
-(void)splitwrite:(NSData *)data splitNum:(NSInteger)splitNum continueWhenLastFail:(BOOL)continueWhenLastFail intervalBetweenTwoPackage:(NSInteger)intervalBetweenTwoPackage callback:(HYHBleWriteCallback *)callback writeType:(CBCharacteristicWriteType)writeType;
@end

NS_ASSUME_NONNULL_END
