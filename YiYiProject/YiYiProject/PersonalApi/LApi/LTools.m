//
//  LCWTools.m
//  FBAuto
//
//  Created by lichaowei on 14-7-9.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"

@implementation LTools
{
    NSMutableData *_data;
}

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static LTools *dataBlock;
    
    dispatch_once(&once_t, ^{
        dataBlock = [[LTools alloc]init];
    });
    
    return dataBlock;
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UINavigationController *)rootNavigationController
{
    return (UINavigationController *)[LTools appDelegate].window.rootViewController;
}

#pragma - mark MD5 加密

/**
 *  获取验证码的时候加此参数
 *
 *  @param phone 手机号
 *
 *  @return 手机号和特定字符串MD5之后的结果
 */
+ (NSString *)md5Phone:(NSString *)phone
{
//    13718570646_ala-yy@_2015
    NSString *mdPhone = [NSString stringWithFormat:@"%@_ala-yy@_2015",phone];
    
    return [self md5:mdPhone];
}

+ (NSString *) md5:(NSString *) text
{
    const char * bytes = [text UTF8String];
    unsigned char md5Binary[16];
    CC_MD5(bytes, (CC_LONG)strlen(bytes), md5Binary);
    
    NSString * md5String = [NSString
                            stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            md5Binary[0], md5Binary[1], md5Binary[2], md5Binary[3],
                            md5Binary[4], md5Binary[5], md5Binary[6], md5Binary[7],
                            md5Binary[8], md5Binary[9], md5Binary[10], md5Binary[11],
                            md5Binary[12], md5Binary[13], md5Binary[14], md5Binary[15]
                            ];
    return md5String;
}

#pragma - mark AFNetWork 网络请求

+ (void)getRequestWithBaseUrl:(NSString *)baseUrl
                   parameters:(NSDictionary *)paramsDic
                   completion:(void(^)(NSDictionary *result,NSError *erro))completionBlock
                    failBlock:(void(^)(NSDictionary *result,NSError *erro))failBlock
{
    baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *operation = [[AFHTTPRequestOperationManager alloc]init];
    
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];;
    
    [operation GET:baseUrl parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            int erroCode = [[result objectForKey:@"errcode"]intValue];
            NSString *erroInfo = [result objectForKey:@"errinfo"];
            
            if (erroCode != 0) { //0代表无错误,  && erroCode != 1 1代表无结果
                
                NSDictionary *failDic = @{RESULT_INFO:erroInfo,@"errcode":[NSString stringWithFormat:@"%d",erroCode]};
                failBlock(failDic,0);
                
                return ;
            }else
            {
                completionBlock(result,0);//传递的已经是没有错误的结果
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        NSLog(@"---->response %@",operation.responseString);
        
        
        NSString *errInfo = @"网络有问题,请检查网络";
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
                
                errInfo = @"无网络连接";
                break;
            case NSURLErrorTimedOut:
                
                errInfo = @"网络连接超时";
                break;
            default:
                break;
        }
        
        NSDictionary *failDic = @{RESULT_INFO: errInfo};
        failBlock(failDic,error);
        
    }];
    
}

#pragma - mark 拼接get请求接口

/**
 *  拼接get请求url
 *
 *  @param url    url
 *  @param params 参数组成的字典
 *
 *  @return 返回url字符串
 */
+ (NSString *)url:(NSString *)url
       withParams:(NSDictionary *)params
{
    NSArray *allkeys = [params allKeys];
    
    if (url == nil) {
        url = @"";
    }
    
    NSMutableString *url_mutable = [NSMutableString stringWithString:url];
    
    for (NSString *key in allkeys) {
        
        NSString *param = [NSString stringWithFormat:@"&%@=%@",key,params[key]];
        [url_mutable appendString:param];
    }
    return url_mutable;
}


#pragma - mark 网络数据请求

- (id)initWithUrl:(NSString *)url isPost:(BOOL)isPost postData:(NSData *)postData//post
{
    self = [super init];
    if (self) {
        requestUrl = url;
        
        if (isPost) {
            requestData = postData;
            isPostRequest = isPost;
        }
    }
    return self;
}

- (void)requestCompletion:(void(^)(NSDictionary *result,NSError *erro))completionBlock failBlock:(void(^)(NSDictionary *failDic,NSError *erro))failedBlock{
    successBlock = completionBlock;
    failBlock = failedBlock;
    
    NSString *newStr = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![newStr rangeOfString:@"get_my_msg"].length) {
        NSLog(@"requestUrl %@",newStr);
    }
    NSURL *urlS = [NSURL URLWithString:newStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlS cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    if (isPostRequest) {
        
        [request setHTTPMethod:@"POST"];
        
        [request setHTTPBody:requestData];
    }
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
}

- (void)cancelRequest
{
    NSLog(@"取消请求");
    [connection cancel];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _data = [NSMutableData data];
    
//    NSLog(@"response :%@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    NSString *str = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"response string %@",str);
    
    if (_data.length > 0) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int erroCode = [[dic objectForKey:RESULT_CODE]intValue];
            NSString *erroInfo = [dic objectForKey:RESULT_INFO];
            
            if (erroCode != 0) { //0代表无错误,  && erroCode != 1 1代表无结果
                
                
                //大于2000的可以正常提示错误,小于2000的为内部错误 参数错误等
                if (erroCode > 2000) {
                    
                    NSDictionary *failDic = @{RESULT_INFO:erroInfo,RESULT_CODE:[NSString stringWithFormat:@"%d",erroCode]};
                    failBlock(failDic,0);
                    
                    [self showErroInfo:erroInfo];

                    
                }else
                {
                    NSLog(@"errcode:%d erroInfo:%@",erroCode,erroInfo);
                    
                    NSDictionary *failDic = @{RESULT_INFO:@"获取数据异常",RESULT_CODE:[NSString stringWithFormat:@"%d",erroCode]};
                    failBlock(failDic,0);
                }
                
                
            }else
            {
                successBlock(dic,0);//传递的已经是没有错误的结果
            }
        }else
        {
            NSLog(@"-----------解析数据为空");
            
            NSDictionary *failDic = @{RESULT_INFO:@"获取数据异常",RESULT_CODE:@"999"};
            failBlock(failDic,0);
            
//            [self showErroInfo:@"获取数据异常"];
        }
        
    }else
    {
        
        NSLog(@"-----------请求数据为空");
        
        NSDictionary *failDic = @{RESULT_INFO:@"获取数据异常",RESULT_CODE:@"999"};
        
        failBlock(failDic,0);
//        [self showErroInfo:@"获取数据异常"];

    }
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"data 为空 connectionError %@",error);
    
    NSString *errInfo = @"网络有问题,请检查网络";
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            
            errInfo = @"无网络连接";
            break;
        case NSURLErrorTimedOut:
            
            errInfo = @"网络连接超时";
            break;
        default:
            break;
    }
    
    //- 11 代表网络问题
    NSDictionary *failDic = @{RESULT_INFO: errInfo,RESULT_CODE:NSStringFromInt(-11)};
    failBlock(failDic,error);
    
    [self showErroInfo:errInfo];
    
}

/**
 *  显示错误提示
 *
 *  @param errInfo
 */
- (void)showErroInfo:(NSString *)errInfo
{
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
    [LTools showMBProgressWithText:errInfo addToView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - 版本更新信息

- (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version//是否有新版本、新版本更新下地址
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //test FBLife 605673005 fbauto 904576362
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appid];
    
    NSString *newStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestUrl = newStr;
    requestData = nil;
    isPostRequest = NO;
    
    [self requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSArray *results = [result objectForKey:@"results"];
        
        if (results.count == 0) {
            
            version(NO,@"no",@"没有更新");
            return ;
        }
        
        //appStore 版本
        NSString *newVersion = [[results objectAtIndex:0]objectForKey:@"version"];
        
        NSString *updateContent = [[results objectAtIndex:0]objectForKey:@"releaseNotes"];
        //本地版本
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _downUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appid];

        BOOL isNew = NO;
        if (newVersion && ([newVersion compare:currentVersion] == 1)) {
            isNew = YES;
        }
        
        version(isNew,_downUrl,updateContent);
        
        if (isNew) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:updateContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }
        
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        
    }];
    
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_downUrl]];
    }
}

//+ (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version//是否有新版本、新版本更新下地址
//{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    
//    //test FBLife 605673005
//    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appid];
//    
//    NSString *newStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSLog(@"requestUrl %@",newStr);
//    NSURL *urlS = [NSURL URLWithString:newStr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlS cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        
//        if (data.length > 0) {
//            
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:Nil];
//            
//            NSArray *results = [dic objectForKey:@"results"];
//            
//            if (results.count == 0) {
//                version(NO,@"no",@"没有更新");
//                return ;
//            }
//            
//            //appStore 版本
//            NSString *newVersion = [[[dic objectForKey:@"results"] objectAtIndex:0]objectForKey:@"version"];
//            NSString *updateContent = [[[dic objectForKey:@"results"] objectAtIndex:0]objectForKey:@"releaseNotes"];
//            //本地版本
//            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//            NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//            NSString *downUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appid];
//            BOOL isNew = NO;
//            if (newVersion && ([newVersion compare:currentVersion] == 1)) {
//                isNew = YES;
//            }
//            version(isNew,downUrl,updateContent);
//            
//        }else
//        {
//            NSLog(@"data 为空 connectionError %@",connectionError);
//            
////            NSString *errInfo = @"网络有问题,请检查网络";
////            switch (connectionError.code) {
////                case NSURLErrorNotConnectedToInternet:
////                    
////                    errInfo = @"无网络连接";
////                    break;
////                case NSURLErrorTimedOut:
////                    
////                    errInfo = @"网络连接超时";
////                    break;
////                default:
////                    break;
////            }
////            
////            NSDictionary *failDic = @{RESULT_INFO: errInfo};
//            
////            NSLog(@"version erro %@",failDic);
//            
//        }
//        
//    }];
//
//}

#pragma mark - NSUserDefault缓存

#pragma mark 缓存融云用户数据

+ (void)cacheRongCloudUserName:(NSString *)userName forUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userName_%@",userId];
    [LTools cache:userName ForKey:key];
}
+ (NSString *)rongCloudUserNameWithUid:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userName_%@",userId];
    return [LTools cacheForKey:key];
}

+ (void)cacheRongCloudUserIcon:(NSString *)iconUrl forUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userIcon_%@",userId];
    [LTools cache:iconUrl ForKey:key];
}

+ (NSString *)rongCloudUserIconWithUid:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userIcon_%@",userId];
    return [LTools cacheForKey:key];
}

/**
 *  融云 记录更新数据时间
 *
 *  @param userId 用户id
 */
+ (void)cacheRongCloudTimeForUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"updateTime_%@",userId];
    
    NSString *nowTime = [LTools timechangeToDateline];
    
    [LTools cache:nowTime ForKey:key];
}

/**
 *  是否需要更新userId对应的信息
 *
 *  @param userId
 *
 *  @return 是否
 */
+ (BOOL)rongCloudNeedRefreshUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"updateTime_%@",userId];

    NSDate *oldDate = [LTools timeFromString:[LTools cacheForKey:key]];
    
    NSInteger between = [oldDate hoursBetweenDate:oldDate];
    
    if (between >= 1) { //大于一个小时需要更新
        
        NSLog(@"需要更新融云用户信息 %@ bew:%ld",oldDate,between);
        
        return YES;
    }
    
    return NO;
}

/**
 *  归档的方式
 *
 *  @param aModel   <#aModel description#>
 *  @param modelKey <#modelKey description#>
 */
+ (void)cacheModel:(id)aModel forKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aModel];
    [userDefaults setObject:data forKey:modelKey];
    [userDefaults synchronize];
}

+ (id)cacheModelForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:modelKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

//存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key
{
    
    @try {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:key];
        [defaults setObject:dataInfo forKey:key];
        [defaults synchronize];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"exception %@",exception);
        
    }
    @finally {
        
    }
    
}

//取
+ (id)cacheForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)cacheBool:(BOOL)boo ForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]setBool:boo forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (BOOL)cacheBoolForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}


//根据url获取SDWebImage 缓存的图片

+ (UIImage *)sd_imageForUrl:(NSString *)url
{
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    NSString *imageKey = [manager cacheKeyForURL:[NSURL URLWithString:url]];
//    
//    SDImageCache *cache = [SDImageCache sharedImageCache];
//    UIImage *cacheImage = [cache imageFromDiskCacheForKey:imageKey];
//    
//    return cacheImage;
    
    return nil;
}

#pragma mark - 常用视图快速创建


/**
 *  通过xib创建cell
 *
 *  @param identify  标识名称
 *  @param tableView
 *  @param cellName
 *
 *  @return cell
 */
+ (UITableViewCell *)cellForIdentify:(NSString *)identify
                            cellName:(NSString *)cellName
                            forTable:(UITableView *)tableView
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellName owner:self options:nil]objectAtIndex:0];
    }
    return cell;
}

+ (UIButton *)createButtonWithType:(UIButtonType)buttonType
                             frame:(CGRect)aFrame
                             normalTitle:(NSString *)normalTitle
                             image:(UIImage *)normalImage
                    backgroudImage:(UIImage *)bgImage
                         superView:(UIView *)superView
                            target:(id)target
                            action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.frame = aFrame;
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:btn];
    return btn;
}

+ (UILabel *)createLabelFrame:(CGRect)aFrame
                        title:(NSString *)title
                         font:(CGFloat)size
                        align:(NSTextAlignment)align
                    textColor:(UIColor *)textColor
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:aFrame];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:size];
    titleLabel.textAlignment = align;
    titleLabel.textColor = textColor;
    return titleLabel;
}

/**
 *  计算宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text sizeWithAttributes:attributes];
    return aSize.width;
}

+ (CGFloat)widthForText:(NSString *)text boldFont:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]};
    CGSize aSize = [text sizeWithAttributes:attributes];
    return aSize.width;
}

+ (CGFloat)widthForText:(NSString *)text height:(CGFloat)height font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.width;
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.height;
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width Boldfont:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.height;
}

#pragma mark - 验证有消息

//是否是字典
+ (BOOL)isDictinary:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

#pragma - mark 判断为空或者是空格

+ (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        
        return YES;
        
    } else {
        
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            
            return YES;
            
        } else {
            
            return NO;
            
        }
        
    }
    
}

#pragma - mark 验证邮箱、电话等有效性

/*匹配正整数*/
+ (BOOL)isValidateInt:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*匹配整浮点数*/
+ (BOOL)isValidateFloat:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString * emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateName:(NSString *)userName
{
    NSString * emailRegex = @"^[\u4E00-\u9FA5a-zA-Z0-9_]{1,20}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:userName];
}

//数字和字母 和 _
+ (BOOL)isValidatePwd:(NSString *)pwdString
{
    NSString * emailRegex = @"^[a-zA-Z0-9_]{6,20}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:pwdString];
}



/*手机及固话*/
+ (BOOL)isValidateMobile:(NSString *)mobileNum
{
    
//    //手机号 13 14 15 17 18  后面9位
//    NSString *mobie = @"^1[3-578]\\d{9}$";
    
    //手机号 1开头  后面10位
    NSString *mobie = @"^1\\d{10}$";
    
//    /**
//     * 手机号码
//     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
//     * 联通：130,131,132,152,155,156,185,186
//     * 电信：133,1349,153,180,189
//     */
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    /**
//     10         * 中国移动：China Mobile
//     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
//     12         */
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    /**
//     15         * 中国联通：China Unicom
//     16         * 130,131,132,152,155,156,185,186
//     17         */
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    /**
//     20         * 中国电信：China Telecom
//     21         * 133,1349,153,180,189
//     22         */
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
//    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSString *PHS = @"^(0(10|2[0-5789]|\\d{3})\\-?)?\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobie];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
  
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

///*手机及固话*/
//+ (BOOL)isValidateMobile:(NSString *)mobileNum
//{
//    /**
//     * 手机号码
//     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
//     * 联通：130,131,132,152,155,156,185,186
//     * 电信：133,1349,153,180,189
//     */
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    /**
//     10         * 中国移动：China Mobile
//     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
//     12         */
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    /**
//     15         * 中国联通：China Unicom
//     16         * 130,131,132,152,155,156,185,186
//     17         */
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    /**
//     20         * 中国电信：China Telecom
//     21         * 133,1349,153,180,189
//     22         */
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
//    /**
//     25         * 大陆地区固话及小灵通
//     26         * 区号：010,020,021,022,023,024,025,027,028,029
//     27         * 号码：七位或八位
//     28         */
//    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
//    
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    
//    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
//        || ([regextestcm evaluateWithObject:mobileNum] == YES)
//        || ([regextestct evaluateWithObject:mobileNum] == YES)
//        || ([regextestcu evaluateWithObject:mobileNum] == YES))
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}

#pragma - mark 小工具

#pragma - mark 小工具

/**
 *  根据6的屏幕计算比例宽度
 *
 *  @param aWidth 6上的宽
 *
 *  @return 等比例的宽
 */
+ (CGFloat)fitWidth:(CGFloat)aWidth
{
    return (aWidth * DEVICE_WIDTH) / 375;
}

/**
 *  根据6的屏幕计算比例高度
 *
 *  @param aWidth 6上的高
 *
 *  @return 等比例的高
 */
+ (CGFloat)fitHeight:(CGFloat)aHeight
{
    return (aHeight * DEVICE_HEIGHT) / 667;
}

/**
 *  根据color id获取优惠劵背景图
 *
 *  @param color color 的id
 *
 *  @return image
 */
+ (UIImage *)imageForCoupeColorId:(NSString *)color
{
    UIImage *aImage = [UIImage imageNamed:@"youhuiquan_r"];
    if ([color intValue] == 1) {
        aImage = [UIImage imageNamed:@"youhuiquan_r"];
    }else if ([color intValue] == 2){
        aImage = [UIImage imageNamed:@"youhuiquan_y"];
    }else if ([color intValue] == 3){
        aImage = [UIImage imageNamed:@"youhuiquan_b"];
    }
    return aImage;
}

/**
 *  返回距离 大于1000 为km,小于m
 *
 *  @param distance 距离
 *
 *  @return
 */
+ (NSString *)distanceString:(NSString *)distance
{
    NSString *distanceStr;
    
    double dis = [distance doubleValue];
    
    if (dis > 1000) {
        
        distanceStr = [NSString stringWithFormat:@"%.1fkm",dis/1000];
    }else
    {
        distanceStr = [NSString stringWithFormat:@"%@m",distance];
    }
    return distanceStr;
}


#pragma - mark 时间相关

/**
 *  时间戳转化为响应格式时间
 *
 *  @param placetime 时间线
 *  @param format    时间格式 @"yyyy-MM-dd HH:mm:ss"
 *
 *  @return 返回时间字符串
 */
+(NSString *)timeString:(NSString *)placetime withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

/**
 *  显示间隔时间 一天内显示时分、几天前、几周前、大于一周 显示具体日期
 *
 *  @param myTime 时间线
 *  @param format 时间格式 “HH:mm”
 *
 *  @return
 */
+ (NSString*)showIntervalTimeWithTimestamp:(NSString*)myTime
                        withFormat:(NSString *)format{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    
    //小于一天的显示时、分
    
    if (distance < 60 * 60 * 24) {
        
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
        
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
            [dateFormatter setDateFormat:format];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}

+(NSString*)showTimeWithTimestamp:(NSString*)myTime{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    
    //小于一天的显示时、分
    
    if (distance < 60 * 60 * 24) {
    
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
        
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


//当前时间转换为 时间戳

+(NSString *)timechangeToDateline
{
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}

//时间戳 转 NSDate
+(NSDate *)timeFromString:(NSString *)timeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    return confromTimesp;
}

//时间线转化

+(NSString *)timechange:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString *)timechange2:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
/**
 *  时间转化格式:MM月dd日
 */
+(NSString *)timechangeMMDD:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM月dd日"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString *)timechangeAll:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString *)timechange3:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}


+ (NSString *)currentTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [outputFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"时间 === %@",date);
    return date;
}

/**
 *  是否需要更新
 *
 *  @param hours      时间间隔
 *  @param recordDate 上次记录时间
 *
 *  @return 是否需要更新
 */
+ (BOOL)needUpdateForHours:(CGFloat)hours recordDate:(NSDate *)recordDate
{
    if (recordDate) {
        
        NSTimeInterval timeIn = [recordDate timeIntervalSinceNow];
        
        CGFloat daySeconds = hours * 60 * 60.f;//秒数
        
        if ((timeIn * -1) >= daySeconds) { //预定时间
            
            return YES;
        }else
        {
            return NO;
        }
    }
    
    return YES;
}


+ (void)alertText:(NSString *)text viewController:(UIViewController *)vc
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        [vc presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


//alert 提示

+ (void)alertText:(NSString *)text
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        
        UIViewController *viewC = ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        
        [viewC presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


+ (void)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 150.f;
    hud.opacity = 0.7f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

+ (MBProgressHUD *)MBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:aView];
//    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
//    hud.margin = 15.f;
//    hud.yOffset = 0.0f;
    [aView addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma - mark 特殊

+ (BOOL)isLogin:(UIViewController *)viewController
{
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:login];
        
        [viewController presentViewController:unVc animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)isLogin:(UIViewController *)viewController loginBlock:(LoginBlock)aBlock
{
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        [login setLoginBlock:aBlock];//登录block
        
        LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:login];
        
        [viewController presentViewController:unVc animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma - mark 非空字符串

+(NSString *)numberToString:(long)number
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: number]];
    return numberString;
}

/**
 *  排除NSNull null 和 (null)
 *
 *  @param text
 *
 *  @return 空格
 */
+ (NSString *)NSStringNotNull:(NSString *)text
{
    if (![text isKindOfClass:[NSString class]]) {
        return @"";
    }else if ([text isEqualToString:@"(null)"] || [text isEqualToString:@"null"] || [text isKindOfClass:[NSNull class]]){
        return @"";
    }
    return text;
}

+ (NSString *)safeString:(NSString *)string
{
    if (string == nil) {
        return @"";
    }
    return string;
}

/**
 *  去除开头的空格
 */
+ (NSString *)stringHeadNoSpace:(NSString *)string
{
    string = string.length == 0 ? @"" : string;
    NSMutableString *mu_str = [NSMutableString stringWithString:string];
    [mu_str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, mu_str.length)];
    return mu_str;
}

/**
 *  给字符串加逗号
 *
 *  @param string 源字符串 如： 123456.78 或者 123456
 *
 *  @return 逗号分割字符串  1,234,567.89 或者 123,456
 */

+ (NSString *)NSStringAddComma:(NSString *)string{//添加逗号
    
    if (string == nil) {
        return @"";
    }
    
    NSRange range = [string rangeOfString:@"."];
    
    NSMutableString *temp = [NSMutableString stringWithString:string];
    int i;
    if (range.length > 0) {
        //有.
        
        i = (int)range.location;
        
    }else
    {
        i = (int)string.length;
    }
    
    while ((i-=3) > 0) {
        
        [temp insertString:@"," atIndex:i];
    }
    
    return temp;
    
}

/**
 *  行间距string
 */

+ (NSAttributedString *)attributedString:(NSString *)string lineSpaceing:(CGFloat)lineSpage
{
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpage];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}

/**
 *  行间距string 字体大小
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
{
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpage];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}

/**
 *  行间距string 字体大小 字体颜色
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor
{
    NSMutableAttributedString * attributedString1 = (NSMutableAttributedString *)[self attributedString:string lineSpaceing:lineSpage fontSize:fontSize];
    
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}

/**
 *  加下划线
 *
 *  @param content
 *
 *  @return
 */
+ (NSAttributedString *)attributedUnderlineString:(NSString *)content
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:content];
    [attString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, content.length)];
    return attString;
}


/**
 *  关键词特殊显示
 *
 *  @param content   源字符串
 *  @param aKeyword  关键词
 *  @param textColor 关键词颜色
 */
+ (NSAttributedString *)attributedString:(NSString *)content keyword:(NSString *)aKeyword color:(UIColor *)textColor
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:content];
    
    if (content.length <= aKeyword.length) {
        return string;
    }
    
    for (int i = 0; i <= content.length - aKeyword.length; i ++) {
        
        NSRange tmp = NSMakeRange(i, aKeyword.length);
        
        NSRange range = [content rangeOfString:aKeyword options:NSCaseInsensitiveSearch range:tmp];
        
        if (range.location != NSNotFound) {
            [string addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
    }
    
    return string;
}
/**
 *  每次只给一个关键词加高亮颜色
 *
 *  @param attibutedString 可以为空
 *  @param string          attibutedString 为空时,用此进行初始化;并且用于找到关键词的range
 *  @param keyword         需要高亮的部分
 *  @param color           高亮的颜色
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)attributedString:(NSMutableAttributedString *)attibutedString originalString:(NSString *)string AddKeyword:(NSString *)keyword color:(UIColor *)color
{
    if (attibutedString == nil) {
        attibutedString = [[NSMutableAttributedString alloc]initWithString:string];
    }
    
    if (keyword.length == 0) {
        keyword = @"";
    }
    
    NSRange range = [string rangeOfString:keyword options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    
    [attibutedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    return attibutedString;
}

+ (BOOL)NSStringIsNull:(NSString *)string
{
    NSMutableString *str = [NSMutableString stringWithString:string];
    [str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, str.length)];
    if (str.length == 0) {
        return YES;
    }
    return NO;
}

#pragma - mark 切图

+(UIImage *)scaleToSizeWithImage:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - 适配尺寸计算

/**
 *  计算等比例高度
 *
 *  @param image_height   图片的高度
 *  @param image_width    图片的宽度
 *  @param show_Width     实际显示宽度
 *
 *  @return 实际显示高度
 */
+ (CGFloat)heightForImageHeight:(CGFloat)image_height
                     imageWidth:(CGFloat)image_width
                      showWidth:(CGFloat)show_Width
{
    float rate;
    
    if (image_width == 0.0 || image_height == 0.0) {
        image_width = image_height;
    }else
    {
        rate = image_height/image_width;
    }
    
    CGFloat imageHeight = show_Width * rate;
    
    return imageHeight;

}

#pragma mark - 分类论坛图片获取

+ (UIImage *)imageForBBSId:(NSString *)bbsId
{
    NSString *name = [NSString stringWithFormat:@"mirco_icon_%@",bbsId];
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

#pragma mark - 动画

/**
 *  view先变大再恢复原样
 *
 *  @param annimationView 需要做动画的view
 *  @param duration       动画时间
 *  @param scacle         变大比例
 */
+ (void)animationToBigger:(UIView *)annimationView
                 duration:(CGFloat)duration
                   scacle:(CGFloat)scacle
{
    //下边是嵌套使用,先变大再恢复的动画效果.
    [UIView animateWithDuration:duration animations:^{
        CGAffineTransform newTransform = CGAffineTransformMakeScale(scacle, scacle);
        [annimationView setTransform:newTransform];
        
    }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.1 animations:^{
                             
                             [annimationView setTransform:CGAffineTransformIdentity];
                             
                         } completion:^(BOOL finished){
                             
                             
                         }];
                     }];
}


@end
