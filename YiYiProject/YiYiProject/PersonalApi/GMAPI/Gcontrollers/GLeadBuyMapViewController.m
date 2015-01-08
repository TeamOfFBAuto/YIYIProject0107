//
//  GLeadBuyMapViewController.m
//  YiYiProject
//
//  Created by gaomeng on 14/12/27.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "GLeadBuyMapViewController.h"
#import "BMapKit.h"
#import "GLeadbuyTableViewCell.h"

@interface GLeadBuyMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKAnnotation,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    BMKMapView* _mapView;//地图
    BMKLocationService* _locService;//定位服务
    
    
    //下面详细信息的view
    UIView *_downInfoView;
    UITableView *_tableView;
    BOOL _isShowDownInfoView;
    
    //底层弹上来的view
    UIView *_downBackView;
    
    //信息字典
    NSMutableDictionary *_poiAnnotationDic;
    
    //拨号
    NSString *_phoneNum;
    //用于获取高度的临时cell
    GLeadbuyTableViewCell *_tmpCell;
    
    
    

    
    
}

@property(nonatomic,strong)BMKPoiInfo *tableViewCellDataModel;

//协议属性
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation GLeadBuyMapViewController


- (void)dealloc {
    
    if (_mapView) {
        _mapView = nil;
    }
    
    if (_locService) {
        _locService = nil;
    }
}



-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    
    //停止定位
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
    
    //代理置空
    _mapView.delegate = nil;
    _locService.delegate = nil;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitleLabel.textColor = [UIColor whiteColor];
    self.myTitle = self.storeName;
    
    //初始化地图
    [self setGMap];
    //初始化定位服务
    [self setGLocationService];
    
    //开启定位
    [self startFollowHeading];
    
    
    //初始化分配内存
    _poiAnnotationDic  = [[NSMutableDictionary alloc]init];
    
    
    //添加附近商家标注
    [self addMapAnnotations];
    
    
}


#pragma mark - 初始化地图
-(void)setGMap{
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-44)];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
}

#pragma mark - 初始化定位服务
-(void)setGLocationService{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
}

#pragma mark - 初始化下层弹出view
-(void)setDownInfoView{
    //下面信息view
    _downInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 568, 320, 206)];
    _downInfoView.backgroundColor = RGBCOLOR(211, 214, 219);
    
    //底层view
    _downBackView = [[UIView alloc]initWithFrame:CGRectMake(10, 12, 300, 206-12-14)];
    _downBackView.backgroundColor = [UIColor whiteColor];
    _downBackView.layer.borderWidth = 0.5;
    _downBackView.layer.borderColor = [RGBCOLOR(200, 199, 204)CGColor];
    _downBackView.layer.cornerRadius = 5;
    [_downInfoView addSubview:_downBackView];
    
    
    [self.view addSubview:_downInfoView];
}

#pragma mark - 开启定位罗盘态
// 罗盘态
-(void)startFollowHeading{
    NSLog(@"进入罗盘态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.zoomLevel = 17;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
}



#pragma mark - 定位相关

//在地图View将要启动定位时，会调用此函数
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

//用户方向更新后，会调用此函数
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
    
}

//用户位置更新后，会调用此函数
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    [_mapView updateLocationData:userLocation];
}


//在地图View停止定位后，会调用此函数
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}



#pragma mark - UITableViewDelegate && UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"dd";
    GLeadbuyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GLeadbuyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0,53,0,0);
    
    
    [cell loadViewWithIndexPath:indexPath];
    
    [cell configWithDataModel:self.tableViewCellDataModel indexPath:indexPath];
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0.0f;
    if (_tmpCell) {
        cellHeight = [_tmpCell configWithDataModel:self.tableViewCellDataModel indexPath:indexPath];
    }else{
        _tmpCell = [[GLeadbuyTableViewCell alloc]init];
        cellHeight = [_tmpCell configWithDataModel:self.tableViewCellDataModel indexPath:indexPath];
    }
    return cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d",indexPath.row);
        if (indexPath.row == 3) {
            if ([[GMAPI exchangeStringForDeleteNULL:self.tableViewCellDataModel.phone]isEqualToString:@"暂无"]) {
                
            }else{
                NSString *phoneStr = [self.tableViewCellDataModel.phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                NSString *phoneStr1 = [phoneStr stringByReplacingOccurrencesOfString:@")" withString:@""];
                _phoneNum = phoneStr1;
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"拨号" message:phoneStr1 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
            
        }
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    
    //0取消    1确定
    if (buttonIndex == 1) {
        NSString *strPhone = [NSString stringWithFormat:@"tel://%@",_phoneNum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
    }
}






//添加地图标注
-(void)addMapAnnotations{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    NSArray *modelArray = [self.dataDic objectForKey:@"datainfo"];
    for (int i = 0; i < modelArray.count; i++) {
        NSDictionary *modelInfo = [modelArray objectAtIndex:1];
        BMKPoiInfo *poi = [[BMKPoiInfo alloc]init];
        poi.name = [modelInfo objectForKey:@"name"];
        poi.address = [modelInfo objectForKey:@"address"];
        poi.phone = [modelInfo objectForKey:@"phone"];
        poi.uid = [modelInfo objectForKey:@"id"];
        poi.postcode = [modelInfo objectForKey:@"owner"];//救援队联系人
        CLLocationCoordinate2D pt = CLLocationCoordinate2DMake([[modelInfo objectForKey:@"wei_lat"]floatValue], [[modelInfo objectForKey:@"jing_lng"]floatValue]);
        poi.pt = pt;
        
        [_poiAnnotationDic setObject:poi forKey:poi.name];
        
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = poi.pt;
        item.title = poi.name;
        item.subtitle = poi.address;
        
        
        NSLog(@"%@",item.title);
        
        [_mapView addAnnotation:item];//addAnnotation方法会掉BMKMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
        }
    
    
}




#pragma mark - 地图view代理方法 BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    
    
    //    //加载所有救援队的tableview
    //    _allJiuyuanduiTableView = nil;
    //    _allJiuyuanduiTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, iPhone5?568-216:480-216, 320, 216) style:UITableViewStylePlain];
    //    _allJiuyuanduiTableView.delegate = self;
    //    _allJiuyuanduiTableView.dataSource = self;
    //    _allJiuyuanduiTableView.tag = allJiuyuanduiInfoTableView;
    //    [self.view addSubview:_allJiuyuanduiTableView];
    
    
    
    annotationView.image = [UIImage imageNamed:@"gpin.png"];
    
    return annotationView;
}
#pragma mark - 点击标注执行的方法
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
    NSLog(@"%s",__FUNCTION__);
    
    if (_isShowDownInfoView) {
        [UIView animateWithDuration:0.3 animations:^{
            _downInfoView.frame = CGRectMake(0, 568, 320, 206);
        }];
    }
    
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}


- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}



#pragma mark - 弹出框点击代理方法
// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 206-12-14) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.layer.borderWidth = 0.5;
    _tableView.layer.borderColor = [RGBCOLOR(200, 199, 204)CGColor];
    _tableView.layer.cornerRadius = 5;
    [_downBackView addSubview:_tableView];
    
    NSLog(@"---------%@",[view.annotation title]);
    NSLog(@"---------%@",[view.annotation subtitle]);
    
    BMKPoiInfo *poi = [_poiAnnotationDic objectForKey:[view.annotation title]];
    NSLog(@"%@",poi.postcode);
    NSLog(@"%@",poi.phone);
    
    self.tableViewCellDataModel = poi;
    
    
    if (!_isShowDownInfoView) {
        [UIView animateWithDuration:0.3 animations:^{
            _downInfoView.frame = CGRectMake(0, 568-206, 320, 206);
        } completion:^(BOOL finished) {
            _isShowDownInfoView = !_isShowDownInfoView;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _downInfoView.frame = CGRectMake(0, 568, 320, 206);
        } completion:^(BOOL finished) {
            _isShowDownInfoView = !_isShowDownInfoView;
        }];
    }
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
