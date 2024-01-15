//
//  HYHBlockingQueue.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYHBlockingQueue<T> : NSObject
- (void)clear;
- (void)remove:(T)obj;
- (nullable T)dequeue;
- (void)enqueue:(T)object;
- (NSUInteger)count;
@end

NS_ASSUME_NONNULL_END
