//
//  MessageDetailController.m
//  YiYiProject
//
//  Created by lichaowei on 15/1/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MessageDetailController.h"
#import "MailMessageCell.h"

#import "ActivityModel.h"

#import "OHAttributedLabel.h"
#import "OHLableHelper.h"
#import "GLeadBuyMapViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#import "PropertyImageView.h"

@interface MessageDetailController ()<UITableViewDataSource,UITableViewDelegate,OHAttributedLabelDelegate>
{
    UITableView *_table;
    
    id detail_model;
    ActivityModel *_activityModel;
//    NSArray *_activityInfo;//活动详情
}

@end

@implementation MessageDetailController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}
//
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.myTitleLabel.text = self.isActivity ? @"活动详情" : @"消息详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = self.isActivity ? [UIColor whiteColor] : [UIColor colorWithHexString:@"f2f2f3"];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 20)];
    _table.tableFooterView = footer;
    
    [self getMessageInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- 创建视图

/**
 *  活动时创建活动基本信息头部分
 *
 *  @return
 */
- (UIView *)activityTableViewHeaderWithModel:(ActivityModel *)aModel
{
    _activityModel = aModel;
    
    UIView *head = [[UIView alloc]init];
    head.backgroundColor = [UIColor whiteColor];
    
    //是否有封面
    CGFloat showWidth = DEVICE_WIDTH - 20;
    CGFloat imageWidth = [aModel.width floatValue];
    CGFloat imageHeight = [aModel.height floatValue];//封面高度
    //有封面
    if (aModel.cover_pic.length > 0) {
        
        imageHeight = [LTools heightForImageHeight:imageHeight imageWidth:imageWidth showWidth:showWidth];
        PropertyImageView *coverImageView = [[PropertyImageView alloc]initWithFrame:CGRectMake(10, 0, showWidth, imageHeight)];
        [coverImageView sd_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:nil];
        [head addSubview:coverImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
        [coverImageView addGestureRecognizer:tap];
        
        coverImageView.userInteractionEnabled = YES;
        
        coverImageView.imageUrls = @[aModel.cover_pic];
        
        [coverImageView l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_YIJIAYI];
    }
    
    //活动标题
    CGFloat textHeight = [LTools heightForText:aModel.activity_title width:showWidth Boldfont:15];
    UILabel *titleLabel = [LTools createLabelFrame:CGRectMake(10, imageHeight + 10, showWidth, textHeight) title:aModel.activity_title font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ef3c42"]];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [head addSubview:titleLabel];
    
    //活动时间
    UIImageView *timeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, titleLabel.bottom + 8, 13, 13)];
    timeIcon.image = [UIImage imageNamed:@"activity_time"];
    [head addSubview:timeIcon];
    
    NSString *timeString = [NSString stringWithFormat:@"活动时间:%@ - %@",[LTools timeString:aModel.start_time withFormat:@"yyyy.MM.dd"],[LTools timeString:aModel.end_time withFormat:@"yyyy.MM.dd"]];
    CGFloat left = timeIcon.right + 5;
    UILabel *timeLabel = [LTools createLabelFrame:CGRectMake(left, timeIcon.top, showWidth - left, 13) title:timeString font:13 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [head addSubview:timeLabel];
    
    
    CGFloat top = timeLabel.bottom;
    
    if (aModel.address && ![LTools isEmpty:aModel.address]) {
        
        //活动地点
        UIImageView *addressIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, timeIcon.bottom + 8, 13, 13)];
        addressIcon.image = [UIImage imageNamed:@"activity_location"];
        [head addSubview:addressIcon];
        
        NSString *addressString = [NSString stringWithFormat:@"活动地点:%@",aModel.address];
        left = addressIcon.right + 5;
        //    UILabel *addressLabel = [LTools createLabelFrame:CGRectMake(left, addressIcon.top, imageWidth - left, 13) title:addressString font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"b9b9b9"]];
        //    [head addSubview:addressLabel];
        
        
        OHAttributedLabel * label = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(left, addressIcon.top, showWidth - left, 13)];
        label.userInteractionEnabled = YES;
        label.font = [UIFont systemFontOfSize:12];
        [head addSubview:label];
        [OHLableHelper creatAttributedText:addressString Label:label OHDelegate:self WithWidht:14 WithHeight:14 WithLineBreak:NO];
        NSRange range = [addressString rangeOfString:aModel.address];
        label.underlineLinks = NO;
        [label addCustomLink:[NSURL URLWithString:@"坐标"] inRange:range];
        [label setLinkColor:[UIColor colorWithHexString:@"0f60d3"]];
        
        label.textColor = [UIColor blackColor];
        
        top = label.bottom;
    }
    
    head.frame = CGRectMake(0, 0, DEVICE_WIDTH, top + 10 + 10);
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, head.height - 0.5f - 10, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [head addSubview:line];
    
    return head;
}

#pragma mark - 点击小图看大图

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    PropertyImageView *aImageView = (PropertyImageView *)tap.view;
    
    if (!aImageView.imageUrls) {
        return;
    }
    
    NSArray *image_urls = aImageView.imageUrls;
    int count = (int)image_urls.count;

    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        // 替换为中等尺寸图片
        NSString *url = image_urls[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = aImageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

#pragma mark - 网络请求

//action= yy(衣加衣) shop（商家） dynamic（动态）
- (void)getMessageInfo
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *key = [GMAPI getAuthkey];
    
    NSString *url = [NSString stringWithFormat:MESSAGE_GET_DETAIL,self.msg_id,key];
    
    if (self.isActivity) {
        
        url = [NSString stringWithFormat:GET_MAIL_ACTIVITY_DETAIL,self.msg_id];
    }
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        if ([LTools isDictinary:result]) {
            
            if (self.isActivity) {
                
                detail_model = [[ActivityModel alloc]initWithDictionary:result];
                
                _table.tableHeaderView = [self activityTableViewHeaderWithModel:detail_model];

            }else
            {
                detail_model = [[MessageModel alloc]initWithDictionary:result];

            }
            
            [_table reloadData];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"failDic %@",result);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        int errcode = [result[RESULT_CODE]intValue];
        if (errcode == 2003) {
            
            //活动不存在
            
            [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:1.f];
            
            return ;
        }
        
        
        if (errcode == -11) {
            
            [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        }
        
        UIButton *btn = [LTools createButtonWithType:UIButtonTypeCustom frame:self.view.bounds normalTitle:@"点击屏幕,重新加载" image:nil backgroudImage:nil superView:nil target:self action:@selector(getMessageInfo)];
        [self.view addSubview:btn];

        
    }];
}

#pragma mark - 代理

#pragma mark - OHAttributedLabelDelegate
///点击用户名跳转到个人信息界面
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
//    NSString * uid = [linkInfo.URL absoluteString];
    
    //跳转至地图
    
    GLeadBuyMapViewController *cc = [[GLeadBuyMapViewController alloc]init];
    cc.theType = LEADYOUTYPE_STORE;
    cc.storeName = [NSString stringWithFormat:@"%@",_activityModel.address];
    cc.coordinate_store = CLLocationCoordinate2DMake([_activityModel.latitude doubleValue], [_activityModel.longitude doubleValue]);
    
    [self presentViewController:cc animated:YES completion:^{
        
    }];
    
    return YES;
}

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    
}
- (void)loadMoreData
{
    
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSLog(@"详情");
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (self.isActivity) {
        
        return 100.f;
    }
    return [MailMessageCell heightForModel:detail_model seeAll:NO];
}

#pragma mark - UITableDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isActivity) {
        
        NSDictionary *info = nil;
        
        if ([_activityModel.activity_detail isKindOfClass:[NSArray class]]) {
            
            info = _activityModel.activity_detail[indexPath.row];
        }
        
        int type = [info[@"type"] intValue];
        if (type == 1) { //文字
            
            NSString *content = info[@"content"];
            
            CGFloat height = [LTools heightForText:content width:DEVICE_WIDTH - 20 font:14];
            
            return height + 10;
            
        }else if (type == 2){ //图片
            
            CGFloat width = [info[@"width"] floatValue];
            CGFloat height = [info[@"height"] floatValue];
            
            height = [LTools heightForImageHeight:height/2.f imageWidth:width/2.f showWidth:DEVICE_WIDTH - 20];
            
            return height;
        }

        return 0;
    }
    
    return [MailMessageCell heightForModel:detail_model seeAll:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isActivity) {
        
        if ([_activityModel.activity_detail isKindOfClass:[NSArray class]]) {
            
            return _activityModel.activity_detail.count;
        
        }
        
        return 0;
        
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //活动
    if (_isActivity) {
        
        static NSString *identifyText = @"activityText";
        static NSString *identifyImage = @"activityImage";
        
        NSDictionary *info = nil;
        if ([_activityModel.activity_detail isKindOfClass:[NSArray class]]) {
            
            info = _activityModel.activity_detail[indexPath.row];
        }
    
        int type = [info[@"type"] intValue];
        if (type == 1) { //文字
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifyText];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifyText];
            }
            NSString *content = info[@"content"];
            
            NSMutableString *temp = [NSMutableString stringWithString:content];
            
            [temp replaceOccurrencesOfString:@"(null)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, temp.length)];;
            
            content = temp;
            
            cell.textLabel.text = content;
            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel setTextColor:[UIColor colorWithHexString:@"5a5a5a"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }else if (type == 2){ //图片
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifyImage];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifyImage];
            }
            
            for (UIView *aView in cell.contentView.subviews) {
                
                for (UIGestureRecognizer *ges in aView.gestureRecognizers) {
                    
                    [ges removeTarget:self action:@selector(tapImage:)];
                }
                [aView removeFromSuperview];
            }
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSString *content = info[@"src"];
            CGFloat width = [info[@"width"] floatValue];
            CGFloat height = [info[@"height"] floatValue];
            
            height = [LTools heightForImageHeight:height/2.f imageWidth:width/2.f showWidth:DEVICE_WIDTH - 20];

            PropertyImageView *imageView = [[PropertyImageView alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, height)];
            [cell.contentView addSubview:imageView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
            [imageView addGestureRecognizer:tap];
            
            imageView.userInteractionEnabled = YES;
            
            imageView.imageUrls = @[content];//图片数组
            
            [imageView l_setImageWithURL:[NSURL URLWithString:content] placeholderImage:DEFAULT_YIJIAYI];
            
            return cell;
        }
    }
    
    //消息
    static NSString *identify = @"MailMessageCell";
    MailMessageCell *cell = (MailMessageCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    
    [cell setCellWithModel:detail_model seeAll:NO timeType:Time_AddTime];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



@end
