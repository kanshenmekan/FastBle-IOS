//
//  HYHTimepiece.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/14.
//

#import "HYHTimepiece.h"
@interface HYHTimepiece()
@property (nonatomic,strong) dispatch_source_t gcdTimer;
@property (assign,nonatomic) BOOL valid;
@end

@implementation HYHTimepiece
+ (HYHTimepiece *)scheduleWithTime:(NSInteger)time async:(BOOL)async timeoutBlock:(nullable HYHTimepieceTimeoutBlock)timeoutBlock{
    HYHTimepiece *timepiece = [[HYHTimepiece alloc]init];
    timepiece.timeoutBlock = timeoutBlock;
    dispatch_queue_t queue;
    if(async){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }else{
        queue = dispatch_get_main_queue();
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    timepiece.valid = YES;
    timepiece.gcdTimer = timer;
    // 设置首次执行事件、执行间隔和精确度(默认为0.01s)
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), time * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
    __weak typeof(timepiece) weakObj = timepiece;
    dispatch_source_set_event_handler(timer, ^{
        __strong typeof(timepiece) strongObj = weakObj;
        if (strongObj.timeoutBlock) {
            strongObj.timeoutBlock();
        }
        dispatch_source_cancel(timer);
        strongObj.valid = NO;
    });
    dispatch_resume(timer);
    return timepiece;
}
+ (HYHTimepiece *)scheduleWithTime:(NSInteger)time timeoutBlock:(nullable HYHTimepieceTimeoutBlock)timeoutBlock{
    return [self scheduleWithTime:time async:NO timeoutBlock:timeoutBlock];
}
- (void)cancelTimer{
    if (self.valid) {
        dispatch_source_cancel(self.gcdTimer);
        self.valid = NO;
    }
}
@end
