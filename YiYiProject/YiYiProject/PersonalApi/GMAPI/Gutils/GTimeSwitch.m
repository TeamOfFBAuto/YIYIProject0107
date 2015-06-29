//
//  GTimeSwitch.m
//  FBCircle
//
//  Created by gaomeng on 14-5-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GTimeSwitch.h"

@implementation GTimeSwitch


+(NSString*)testtime:(NSString *)test{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[test doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    NSLog(@"-----%@---",confromTimespStr);
    
    return confromTimespStr;
}

+(NSString*)testtimeByYear:(NSString *)test{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy"];
    
    
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[test doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    NSLog(@"-----%@---",confromTimespStr);
    
    return confromTimespStr;
}


//距离现在的时间
+(NSString*)timestamp:(NSString*)myTime{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒钟前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"周前"];
    }else
    {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}


//月日十分
+(NSString *)timechange:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MMddHHmm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}



//大于一天显示 年月时分
+(NSString*)timeWithDayHourMin:(NSString*)myTime{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒钟前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        
        
        NSString *timeStr = [GTimeSwitch timechange:myTime];
        NSString *month;//月
        NSString *day;//日
        NSString *hour;//小时
        NSString *fen;//分钟
        
        //判断月第一位是否为0
        if ([[timeStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"]) {
            month = [timeStr substringWithRange:NSMakeRange(1, 1)];
        }else{
            month = [timeStr substringWithRange:NSMakeRange(0, 2)];
        }
        
        NSLog(@"%@",month);
        
        //判断日第一位是否为0
        if ([[timeStr substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]) {
            day = [timeStr substringWithRange:NSMakeRange(3, 1)];
        }else{
            day = [timeStr substringWithRange:NSMakeRange(2, 2)];
        }
        
        
        NSLog(@"%@",day);
        
        //判断是否超多12小时
        if ([[timeStr substringWithRange:NSMakeRange(4, 2)]intValue]<12) {//上午
            hour = [NSString stringWithFormat:@"上午%@",[timeStr substringWithRange:NSMakeRange(5, 1)]];
        }else{
            NSString *tmp = [timeStr substringWithRange:NSMakeRange(4, 2)];
            int tmp1 = [tmp intValue]-12;
            NSString *tmp2 = [NSString stringWithFormat:@"%d",tmp1];
            hour = [NSString stringWithFormat:@"下午%@",tmp2];
        }
        
        
        NSLog(@"%@",hour);
        
        
        //分钟
        fen = [timeStr substringWithRange:NSMakeRange(6, 2)];
        
        NSLog(@"%@",fen);
        
        
        
        NSString *showTime = [NSString stringWithFormat:@"%@月%@日  %@:%@",month,day,hour,fen];
        
        NSLog(@"%@",showTime);
        
        
        
        timestamp = showTime;
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timestamp = [GTimeSwitch timechange:myTime];
    }else
    {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}


+(NSAttributedString *)timechangeWithDayAndMonth:(NSString *)test{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[test doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSString *month = [confromTimespStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [confromTimespStr substringWithRange:NSMakeRange(8, 2)];
    
    NSString *month_str;
    if ([month isEqualToString:@"01"]) {
        month_str = @"一月";
    }else if ([month isEqualToString:@"02"]){
        month_str = @"二月";
    }else if ([month isEqualToString:@"03"]){
        month_str = @"三月";
    }else if ([month isEqualToString:@"04"]){
        month_str = @"四月";
    }else if ([month isEqualToString:@"05"]){
        month_str = @"五月";
    }else if ([month isEqualToString:@"06"]){
        month_str = @"六月";
    }else if ([month isEqualToString:@"07"]){
        month_str = @"七月";
    }else if ([month isEqualToString:@"08"]){
        month_str = @"八月";
    }else if ([month isEqualToString:@"09"]){
        month_str = @"九月";
    }else if ([month isEqualToString:@"10"]){
        month_str = @"十月";
    }else if ([month isEqualToString:@"11"]){
        month_str = @"十一月";
    }else if ([month isEqualToString:@"12"]){
        month_str = @"十二月";
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",day,month_str]];
    
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,day.length)];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0,day.length)];
    
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(day.length, month_str.length)];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(day.length, month_str.length)];
    return title;
}






@end
