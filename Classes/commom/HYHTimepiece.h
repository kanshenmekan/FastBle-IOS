//
//  HYHTimepiece.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^HYHTimepieceTimeoutBlock)(void);
@interface HYHTimepiece : NSObject
@property (assign,nonatomic,readonly) BOOL valid;
@property (copy,nonatomic,nullable) HYHTimepieceTimeoutBlock timeoutBlock;
- (void)cancelTimer;

+ (HYHTimepiece *)scheduleWithTime:(NSInteger)time timeoutBlock:(nullable HYHTimepieceTimeoutBlock)timeoutBlock;
+ (HYHTimepiece *)scheduleWithTime:(NSInteger)time async:(BOOL)async timeoutBlock:(nullable HYHTimepieceTimeoutBlock)timeoutBlock;
@end

NS_ASSUME_NONNULL_END
