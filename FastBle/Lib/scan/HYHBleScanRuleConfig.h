//
//  HYHBleScanRuleConfig.h
//  FastBle
//
//  Created by GTPOWER on 2023/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYHBleScanRuleConfig : NSObject
@property (strong,nonatomic,readonly) NSMutableArray<NSString *> *identifiers;
@property (strong,nonatomic,readonly) NSMutableArray<NSString *> *names;
@property (assign,nonatomic) BOOL fuzzyName;
@property (assign,nonatomic) NSInteger scanTimeout;
@end

NS_ASSUME_NONNULL_END
