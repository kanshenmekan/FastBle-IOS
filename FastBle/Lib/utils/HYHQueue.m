//
//  GTQueue.m
//  CustomView
//
//  Created by 123 on 2019/6/9.
//  Copyright © 2019 123. All rights reserved.
//

#import "HYHQueue.h"
@interface HYHQueue<T>()
@property (strong, nonatomic) NSMutableArray<T> *array;
@end

@implementation HYHQueue
+ (instancetype) arrayQueue{
   return [[HYHQueue alloc]initWithCapacity:10];
}
+ (instancetype) arrayQueueWithCapacity:(NSUInteger)capacity{
    return [[HYHQueue alloc]initWithCapacity:capacity];
}
- (instancetype) initWithCapacity:(NSUInteger)numItems{
    if(self = [super init]){
        _array = [NSMutableArray arrayWithCapacity:numItems];
    }
    
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}
-(nullable id)peek{
    if ([self isEmpty]) {
        return nil;
    }
    id obj = [self.array firstObject];
    return obj;
}
-(id)poll{
    if ([self isEmpty]) {
        return nil;
    }
    id obj = [self.array firstObject];
    [self.array removeObjectAtIndex:0];
    return obj;
}
-(void)offer:(id)obj{
    [self.array addObject:obj];
}
-(void)addAll:(nonnull NSArray *)array{
    [self.array addObjectsFromArray:array];
}
-(void)setAll:(nonnull NSArray *)array{
    [self.array setArray:array];
}
-(void)clear{
    [self.array removeAllObjects];
}

- (NSUInteger)count{
    return self.array.count;
}
-(BOOL)isEmpty{
    return self.array.count == 0;
}

-(NSString *)description{
    NSString * desc = @"\n";
    for (id obj in self.array) {
        desc = [desc stringByAppendingFormat:@"%@;\n",obj];
    }
    return desc;
}
@end
