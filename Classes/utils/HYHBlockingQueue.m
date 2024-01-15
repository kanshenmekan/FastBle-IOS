//
//  HYHBlockingQueue.m
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import "HYHBlockingQueue.h"
@interface HYHBlockingQueue()
@property (strong,nonatomic) NSMutableArray *queue;
@property (strong,nonatomic) dispatch_semaphore_t queueSemaphore;
@property (strong,nonatomic) NSObject *enqueueLock;
@property (strong,nonatomic) NSObject *dequeueLock;
@end

@implementation HYHBlockingQueue
- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [NSMutableArray array];
        _queueSemaphore = dispatch_semaphore_create(0);
        _enqueueLock = [[NSObject alloc]init];
        _dequeueLock = [[NSObject alloc]init];;
    }
    return self;
}
- (void)enqueue:(id)object {
    @synchronized (self.enqueueLock) {
        [_queue addObject:object];
        dispatch_semaphore_signal(_queueSemaphore);
    }
}

- (nullable id)dequeue {
    id object = nil;
    @synchronized(self.dequeueLock) {
        dispatch_semaphore_wait(self.queueSemaphore, DISPATCH_TIME_FOREVER);
        object = _queue.firstObject;
        if (object != nil) {
            [_queue removeObjectAtIndex:0];
        }
    }
    return object;
}
- (void)remove:(id)obj{
    @synchronized (self) {
        if ([self.queue indexOfObject:obj] != NSNotFound) {
            dispatch_semaphore_wait(self.queueSemaphore, DISPATCH_TIME_FOREVER);
            [_queue removeObject:obj];
        }
    }
}
- (NSUInteger)count{
    @synchronized(self) {
        return self.queue.count;
    }
}
- (void)clear{
    @synchronized (self) {
        dispatch_semaphore_signal(_queueSemaphore);
        [self.queue removeAllObjects];
        self.queueSemaphore = dispatch_semaphore_create(0);
    }
}
@end
