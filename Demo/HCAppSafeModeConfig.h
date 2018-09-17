//
//  HCAppSafeModeConfig.h
//  Demo
//
//  Created by ZengCong on 2018/8/23.
//  Copyright © 2018年 ZengCong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCAppSafeModeConfig : NSObject
+(instancetype)shareInstance;
-(void)recordCrashCount;
@end
