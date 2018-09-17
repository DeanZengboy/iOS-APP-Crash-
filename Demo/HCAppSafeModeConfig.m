//
//  HCAppSafeModeConfig.m
//  Demo
//
//  Created by ZengCong on 2018/8/23.
//  Copyright © 2018年 ZengCong. All rights reserved.
//

#import "HCAppSafeModeConfig.h"
#import <UIKit/UIKit.h>


static NSString *const k

static HCAppSafeModeConfig *instance;
@implementation HCAppSafeModeConfig
/**
 参数 isCrash crashCount crashTime
 原理：每次启动检查一次isCrash，如果是YES，则数值crashCount+1，也就是第四次启动，则会清空内存
 整体思路：程序启动把isCrash置为YES，程序退出时isCrash置为NO。
 **/

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HCAppSafeModeConfig alloc]init];
    });
    return instance;
}

// app进入后台
- (void)appEnterBackground
{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"Dean_isCrash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// app回到前台
- (void)appEnterForeground
{
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Dean_isCrash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//存储当前时间戳
-(double)storageTimeInDefaults
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    double timeFloat = [timeString doubleValue];
    
    NSString *timeSting = [NSString stringWithFormat:@"%0.f",timeFloat];
    
    [[NSUserDefaults standardUserDefaults] setObject:timeSting forKey:@"Dean_time"];
    
    return timeFloat;
}

//记录奔溃次数
-(void)recordCrashCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //每次进来先判断上次APP是否奔溃
    BOOL isCrash = [[defaults objectForKey:@"Dean_isCrash"] boolValue];
    
    //取完isCrash后设置为YES
    [defaults setObject:@"YES" forKey:@"Dean_isCrash"];
    
    //取上次进入App的时间
    NSString *lastTime = [defaults objectForKey:@"Dean_time"];
    
    double dLastTime = lastTime==nil?0.0:[lastTime doubleValue];
    
    //记录当前时间戳并返回当前时间
    double nowTime = [self storageTimeInDefaults];
    
    NSInteger crashtime = nowTime - dLastTime;
   
    if(isCrash){
        if (crashtime>60) {
            //如果奔溃时间间隔大于60秒 则清空CrashCount 并不再执行下去
            [defaults setObject:@"0" forKey:@"CrashCount"];
            [defaults synchronize];
            return;
        }
        //如果奔溃，并且在预定时间内奔溃，则存下奔溃次数
        NSString *crashNumber = [defaults objectForKey:@"CrashCount"];
        NSLog(@"取上次count值=====%@",crashNumber);
        NSInteger count;
        if(crashNumber != nil){
            count = [crashNumber integerValue] + 1;
        }else{
            count = 1;
        }
        
        //如果达到三次,此处执行方法 method
        if(count == 3){
            //本地次数清零
            [defaults setObject:@"0" forKey:@"CrashCount"];
            [defaults synchronize];
            NSString *ccccc = [defaults objectForKey:@"CrashCount"];
            NSLog(@"cccccccc%@",ccccc);
            //清除缓存
//            [self clearCacheAndFile];
            return;
        }
        
        //没达到3次存储到本地
        NSString *countString = [NSString stringWithFormat:@"%ld",(long)count];
        NSLog(@"显示count值并保存====%@",countString);
        [defaults removeObjectForKey:@"CrashCount"];
        [defaults setObject:countString forKey:@"CrashCount"];
        [defaults synchronize];
        NSString *aaaaa = [defaults objectForKey:@"CrashCount"];
        NSLog(@"取count值=======%@",aaaaa);

    }
}

- (void)setCount
{
    
}

-(void)clearCacheAndFile
{
    //循环路径下的每个子文件，并清空数据
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *subPathArry = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    NSString *anotherPath = nil;
    NSError *error = nil;
    for(NSString *subpath in subPathArry)
    {
        //清空数据
        anotherPath = [filePath stringByAppendingPathComponent:subpath];
        [[NSFileManager defaultManager] removeItemAtPath:anotherPath error:&error];
        //初始化
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除缓存成功" message:@"清除缓存成功" delegate:self cancelButtonTitle:@"取消按钮" otherButtonTitles:@"其他按钮1", @"其他按钮2", @"其他按钮3", nil];
        //显示alertView
        [alert show];
        
    }
    
}
@end
