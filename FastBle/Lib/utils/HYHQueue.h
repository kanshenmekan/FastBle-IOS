//
//  GTQueue.h
//  CustomView
//
//  Created by 123 on 2019/6/9.
//  Copyright © 2019 123. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYHQueue<T> :NSObject
+ (instancetype) arrayQueue;
+ (instancetype) arrayQueueWithCapacity:(NSUInteger)capacity;
- (instancetype) initWithCapacity:(NSUInteger)numItems;
-(void)setAll:(nonnull NSArray<T> *)array;
-(void)addAll:(nonnull NSArray<T> *)array;
-(void)clear;
-(nullable T)peek;
-(nullable T)poll;
-(void)offer:(T)ob;
-(NSUInteger)count;
-(BOOL)isEmpty;
@end

NS_ASSUME_NONNULL_END
