//
//  GTimeSwitch.h
//  FBCircle
//
//  Created by gaomeng on 14-5-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTimeSwitch : NSObject

//获取时间

//年月日
+(NSString*)testtime:(NSString *)test;

//距离现在的时间
+(NSString*)timestamp:(NSString*)myTime;


//大于一天显示 年月时分
+(NSString*)timeWithDayHourMin:(NSString*)myTime;


//月日十分
+(NSString *)timechange:(NSString *)placetime;


//年
+(NSString*)testtimeByYear:(NSString *)test;


//返回日月字符串
+(NSAttributedString *)timechangeWithDayAndMonth:(NSString *)test;

@end
