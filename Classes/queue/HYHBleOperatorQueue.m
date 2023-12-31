//
//  HYHBleOperatorQueue.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import "HYHBleOperatorQueue.h"
#import "HYHBlockingQueue.h"

@interface HYHBleOperatorQueue()
@property (strong,nonatomic) NSCondition *condition;
@property (strong,nonatomic) HYHBlockingQueue<HYHBleSequenceOperator *> *taskQueue;
@property (assign,nonatomic) BOOL isActive;
@property (strong,nonatomic) dispatch_queue_t threadQueue;
@property (strong,nonatomic) dispatch_semaphore_t delaySemaphore;
@property (strong,nonatomic) HYHBleSequenceOperator *currentTask;
@property (weak,nonatomic) HYHBleBluetooth *bleBluetooth;
@property (assign,nonatomic) BOOL hasDelay;
@end

@implementation HYHBleOperatorQueue
- (instancetype)initWithKey:(nonnull NSString *)key bleBluetooth:(HYHBleBluetooth *)bleBluetooth
{
    self = [super init];
    if (self) {
        _condition = [[NSCondition alloc]init];
        _threadQueue = dispatch_queue_create([key cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        _delaySemaphore = dispatch_semaphore_create(0);
        _taskQueue = [[HYHBlockingQueue alloc]init];
        _hasDelay = NO;
        self.bleBluetooth = bleBluetooth;
    }
    return self;
}
- (void)resume{
    if (self.isActive) {
        return;
    }
    self.isActive = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_block_t threadTask = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.condition lock];
        while (strongSelf.isActive) {
            HYHBleSequenceOperator *task = [weakSelf.taskQueue dequeue];
            strongSelf.currentTask = task;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([task respondsToSelector:@selector(execute:)]) {
                    [task execute:strongSelf.bleBluetooth];
                }
                
            });
            if (task.continuous && strongSelf.isActive) {
                [strongSelf.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:task.timeout/1000.0]];
            }
            if (task.delay > 0 && strongSelf.isActive) {
                strongSelf.hasDelay = YES;
                dispatch_semaphore_wait(strongSelf.delaySemaphore, dispatch_time(DISPATCH_TIME_NOW, task.delay * NSEC_PER_MSEC));
                strongSelf.hasDelay = NO;
            }
        }
        [strongSelf.condition unlock];
    };
    dispatch_block_t scheduledTask = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, threadTask);
    dispatch_async(self.threadQueue, scheduledTask);
}

- (void)bleOperatorTaskEnd:(nonnull HYHBleSequenceOperator *)task result:(BOOL)result { 
    if (self.currentTask == task) {
        [self.condition signal];
    }
}
- (void)pause{
    self.isActive = NO;
    [self.condition signal];
    if (self.hasDelay) {
        dispatch_semaphore_signal(self.delaySemaphore);
    }
}
- (void)remove:(HYHBleSequenceOperator *)operator{
  [self.taskQueue remove:operator];
}
- (void)clear{
    [self.taskQueue clear];
}
- (void)destroy{
    [self pause];
    [self clear];
    self.bleBluetooth = nil;
}
- (void)offer:(HYHBleSequenceOperator *)sequenceOperator{
    if(self.isActive){
        sequenceOperator.operatorQueue = self;
        [self.taskQueue enqueue:sequenceOperator];
    }
}
@end
