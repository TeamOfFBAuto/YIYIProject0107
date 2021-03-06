//
//  GupClothesViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/1/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GupClothesViewController.h"
#import "UploadPicViewController.h"
#import "AFNetworking.h"
#import "JKImagePickerController.h"
#import "PhotoCell.h"


@interface GupClothesViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate,JKImagePickerControllerDelegate>
{
    UIView *_view1;//填写信息view
    UIView *_view2;//上传图片view
    
    
    
    NSMutableArray *_imageArray;//所选图片数组
    NSMutableArray *_showPicsBtnArray;//展示图片的btn
    NSMutableArray *_deleteImageIndexArray;//删除的图片在_imageArray中的下标
    
    
    NSMutableArray *_upImagesArray;//上传图片的数组
    
    
    NSMutableArray *_shurukuangArray;//输入框的数组
    
    
    //单品类型 打折 新品 热销
    UILabel *_leixingLabel;
    
    
    //性别
    UILabel *_genderLabel;
    
    //分类
    UILabel *_fenleiLabel;
    
    NSString *_oldImages_Ids_str;//老图id字符串
    NSMutableArray *_oldImages_Ids_Array;//老图id数组
    
    
    UIView *_dateChooseView;//时间选择view
    UIDatePicker *_datePicker;//时间选择器
    UILabel *_endTime;//结束时间
    NSDate *_date_end;//结束时间
    
    CGSize _theSize;
    CGSize _theSize_haveKeyboard;
    
    
    
    
}
@end

@implementation GupClothesViewController


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}



-(id)initWithType:(GUPCLOTHTYPE)theType editProduct:(ProductModel*)theModel{
    self = [super init];
    if (self) {
        self.theEditProduct = theModel;
        self.thetype = theType;
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    if (self.thetype == GEDITCLOTH) {
        return;
    }
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle=@"上传衣服";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    //初始化
    _shurukuangArray = [NSMutableArray arrayWithCapacity:1];
    _showPicsBtnArray = [NSMutableArray arrayWithCapacity:1];
    
    
    //主scrollview
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-15)];
    
    
    _mainScrollView.backgroundColor = RGBCOLOR(242, 242, 242);
    [self.view addSubview:_mainScrollView];
    
    
    //填写信息view
    [self creatView1];
    
    //上传图片view
    [self creatView2];
    
    //提交按钮
    [self creatTijiaoBtn];
    
    [self creatDatePickerChooseView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gShou) name:UIKeyboardWillHideNotification object:nil];
    
    
    if (self.thetype == GEDITCLOTH) {
        self.myTitle = @"修改单品";
        [self setDataWithModel:self.theEditProduct];
    }
    
    
}





-(void)setDataWithModel:(ProductModel *)theModel{
    UITextField *tf = _shurukuangArray[0];//品牌
    UITextField *tf1 = _shurukuangArray[1];//品名
    UITextField *tf2 = _shurukuangArray[2];//原价
    UITextField *tf3 = _shurukuangArray[3];//现价
    UITextField *tf4 = _shurukuangArray[4];//折扣
    UITextField *tf5 = _shurukuangArray[5];//标签
    UITextField *tf6 = _shurukuangArray[10];//货号
    
    if (theModel.product_brand_name.length>0) {
        tf.text = theModel.product_brand_name;
    }
    tf1.text = theModel.product_name;
    tf2.text = theModel.original_price;
    tf3.text = theModel.product_price;
    CGFloat zhekou = theModel.discount_num;
    float zhe_f = zhekou*10;
    tf4.text = [NSString stringWithFormat:@"%.1f",zhe_f];
    tf5.text = theModel.product_tag;
    
    //类型
    if ([theModel.product_new intValue] == 0 && [theModel.product_hotsale intValue] == 0) {
        _leixingLabel.text = @"折扣";
    }else if ([theModel.product_new intValue] == 1 && [theModel.product_hotsale intValue] == 0){
        _leixingLabel.text = @"新品";
    }else if ([theModel.product_new  intValue]== 0 && [theModel.product_hostsale intValue] == 0){
        _leixingLabel.text = @"畅销";
    }
    _leixingLabel.textColor = [UIColor blackColor];
    
    
    //性别
    if ([theModel.product_gender intValue] ==2) {
        _genderLabel.text = @"男";
        _genderLabel.textColor = [UIColor blackColor];
    }else if ([theModel.product_gender intValue] == 1){
        _genderLabel.text = @"女";
        _genderLabel.textColor = [UIColor blackColor];
    }
    
    //按钮
    UIButton *btn = (UIButton*)[_mainScrollView viewWithTag:567];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    
    
    //图片
    self.oldImageArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *imageList = theModel.imagelist;
    NSInteger imageListCount = imageList.count;
    if (imageListCount>5) {
        imageListCount = 5;
    }
    for (int i = 0;i<imageListCount;i++) {
        NSDictionary *dic = imageList[i];
        NSString *imageName = [[dic objectForKey:@"original"]objectForKey:@"src"];
        NSLog(@"图片地址%@",imageName);
        UIImageView *imv = [[UIImageView alloc]init];
        [imv sd_setImageWithURL:[NSURL URLWithString:imageName] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            UIButton *btn = _showPicsBtnArray[i];
            [btn setBackgroundImage:imv.image forState:UIControlStateNormal];
            NSString *image_idstr = [[dic objectForKey:@"original"]objectForKey:@"img_id"];
            
            if (!_oldImages_Ids_Array) {
                _oldImages_Ids_Array = [NSMutableArray arrayWithCapacity:1];
            }
            [_oldImages_Ids_Array addObject:image_idstr];
            [self.oldImageArray addObject:imv.image];
            
            NSLog(@"%@",_oldImages_Ids_Array);
        }];
    }
    
    
    
    //下架
    _endTime.text = [GMAPI timechangeAll2:self.theEditProduct.auto_down_time];
    _endTime.textColor = [UIColor blackColor];
    
    //分类
    _fenleiLabel.textColor = [UIColor blackColor];
    
    int p_type = [self.theEditProduct.product_type intValue];
    switch (p_type) {
        case Product_qita:
            _fenleiLabel.text = @"其他";
            break;
        case Product_shangyi:
            _fenleiLabel.text = @"上衣";
            break;
        case Product_kuzi:
            _fenleiLabel.text = @"裤子";
            break;
        case Product_qunzi:
            _fenleiLabel.text = @"裙子";
            break;
        case Product_neiyi:
            _fenleiLabel.text = @"内衣";
            break;
        case Product_peishi:
            _fenleiLabel.text = @"配饰";
            break;
        
        
        default:
            break;
    }
    
    
    //货号
    tf6.text = self.theEditProduct.product_sku;
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//空白点击收键盘start=======
-(void)gShou{
    NSLog(@"收键盘了");
    
//    if (_mainScrollView.contentOffset.y>=58) {
//        _mainScrollView.contentOffset = CGPointMake(0, 0);
//    }
    for (UITextField *tf in _shurukuangArray) {
        [tf resignFirstResponder];
    }
    
    [self datePickerHideen];
    
    
    UITextField *tf2 = _shurukuangArray[2];
    UITextField *tf3 = _shurukuangArray[3];
    UITextField *tf4 = _shurukuangArray[4];
    
    if (tf2.text.length>0 && tf3.text.length>0) {
        CGFloat tf2_num = [tf2.text floatValue];
        CGFloat tf3_num = [tf3.text floatValue];
        
        CGFloat zhekou = tf3_num/tf2_num;
        CGFloat zhekou_f = zhekou *10;
        tf4.text = [NSString stringWithFormat:@"%.1f",zhekou_f];
        
        if ([tf4.text intValue] == 10) {
            tf4.text = @"无折扣";
        }
        
    }
    
    
    
    
    
    
    
    _mainScrollView.contentSize = _theSize;
    
}



-(void)jisuanZekou{
    
    
    UITextField *tf2 = _shurukuangArray[2];
    UITextField *tf3 = _shurukuangArray[3];
    UITextField *tf4 = _shurukuangArray[4];
    
    if (tf2.text.length>0 && tf3.text.length>0) {
        CGFloat tf2_num = [tf2.text floatValue];
        CGFloat tf3_num = [tf3.text floatValue];
        
        CGFloat zhekou = tf3_num/tf2_num;
        CGFloat zhekou_f = zhekou *10;
        tf4.text = [NSString stringWithFormat:@"%.1f",zhekou_f];
        
        if ([tf4.text intValue] == 10) {
            tf4.text = @"无折扣";
        }
        
    }
}





- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSLog(@"%ld",(long)textField.tag);
    _mainScrollView.contentSize = _theSize_haveKeyboard;
    _mainScrollView.userInteractionEnabled = YES;
    

    
    
    NSInteger tt = textField.tag - 200;
    if (_mainScrollView.contentOffset.y < tt * 51) {
        [_mainScrollView setContentOffset:CGPointMake(0, tt*51) animated:YES];
    }
    
    [self jisuanZekou];
    
}




- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self jisuanZekou];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    if (textField.tag == 202 || textField.tag == 203) {//原价 现价
        
        
        
        UITextField *tf2 = _shurukuangArray[2];//原价
        UITextField *tf3 = _shurukuangArray[3];//现价
        if (textField.tag == 202 && tf3.text.length>0) {
            NSMutableString *yuanjia;
            if (string.length == 0) {
                yuanjia = [NSMutableString stringWithFormat:@"%@",textField.text];
                yuanjia = (NSMutableString*)[yuanjia substringWithRange:NSMakeRange(0, yuanjia.length-1)];
                if (yuanjia.length == 0) {
                    UITextField *tf4 = _shurukuangArray[4];
                    tf4.text = nil;
                }
            }else{
                yuanjia = [NSMutableString stringWithFormat:@"%@%@",textField.text,string];
            }
            
            NSString *xianjia = tf3.text;
            [self dongtaijisuanWithYuanjia:yuanjia xianjia:xianjia];
        }else if (textField.tag == 203 &&tf2.text.length>0){
            NSString *yuanjia = tf2.text;
            NSMutableString *xianjia;
            if (string.length == 0) {
                xianjia = [NSMutableString stringWithString:textField.text];
                xianjia = (NSMutableString *)[xianjia substringWithRange:NSMakeRange(0, xianjia.length-1)];
                if (xianjia.length == 0) {
                    UITextField *tf4 = _shurukuangArray[4];
                    tf4.text = nil;
                }
            }else{
                xianjia = [NSMutableString stringWithFormat:@"%@%@",textField.text,string];
            }
            [self dongtaijisuanWithYuanjia:yuanjia xianjia:xianjia];
        }
    }
    
    return YES;
}

-(void)dongtaijisuanWithYuanjia:(NSString *)yuanj xianjia:(NSString *)xianj{
    
    UITextField *tf4 = _shurukuangArray[4];
    
    if (yuanj.length>0 && xianj.length>0) {
        CGFloat tf2_num = [yuanj floatValue];
        CGFloat tf3_num = [xianj floatValue];
        
        CGFloat zhekou = tf3_num/tf2_num;
        CGFloat zhekou_f = zhekou *10;
        tf4.text = [NSString stringWithFormat:@"%.1f",zhekou_f];
        
        if ([tf4.text intValue] == 10) {
            tf4.text = @"无折扣";
        }
        
    }
}



//空白点击手键盘end======





-(void)creatTijiaoBtn{
    UIButton *tijiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tijiaoBtn setTitle:@"提  交" forState:UIControlStateNormal];
    tijiaoBtn.tag = 567;
    [tijiaoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tijiaoBtn setBackgroundColor:RGBCOLOR(217, 66, 93)];
    tijiaoBtn.layer.cornerRadius = 5;
    [tijiaoBtn setFrame:CGRectMake(20, CGRectGetMaxY(_view2.frame)+13, DEVICE_WIDTH-40, 44)];
    [tijiaoBtn addTarget:self action:@selector(tijiao) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainScrollView addSubview:tijiaoBtn];
    
    
    _theSize = CGSizeMake(DEVICE_WIDTH, CGRectGetMaxY(tijiaoBtn.frame)+100);
    _theSize_haveKeyboard = CGSizeMake(DEVICE_WIDTH, CGRectGetMaxY(tijiaoBtn.frame)+100+300);
    _mainScrollView.contentSize = _theSize;
    
}



-(void)tijiao{
    
    
    //判断信息完整性
    for (UITextField *tf in _shurukuangArray) {
        if (tf.text.length == 0 || _showPicsBtnArray.count == 0) {
            [GMAPI showAutoHiddenMBProgressWithText:@"请完善信息" addToView:self.view];
            return;
        }
        
    }
    
    
    BOOL leixing = [_leixingLabel.text isEqualToString:@"请选择单品类型"];
    BOOL fenlei = [_fenleiLabel.text isEqualToString:@"请选择分类"];
    BOOL gender = [_genderLabel.text isEqualToString:@"请选择性别"];
    
    if (leixing || fenlei || gender) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请完善信息" addToView:self.view];
        return;
    }
    
    
    if (self.assetsArray.count == 0 && self.thetype == GUPCLOTH) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请添加图片" addToView:self.view];
        return;
    }
    
    
    //获取需要上传的图片
    [self getChoosePics];
    
    
    
}





#pragma mark - 上传图片 & 上传信息

//发布单品上传
-(void)upLoadImage:(NSArray *)aImage_arr{
    
    NSLog(@"老图id:%@",_oldImages_Ids_str);
    NSLog(@"老图 %@",_oldImages_Ids_Array);
    NSLog(@"uploadImage and info");
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //上传的url
    NSString *uploadImageUrlStr = GFABUDIANPIN;
    
    UITextField *tf = _shurukuangArray[0];//品牌
    UITextField *tf1 = _shurukuangArray[1];//品名
    UITextField *tf2 = _shurukuangArray[2];//原价
    UITextField *tf3 = _shurukuangArray[3];//现价
    UITextField *tf4 = _shurukuangArray[4];//折扣
    UITextField *tf5 = _shurukuangArray[5];//标签
    UITextField *tf6 = _shurukuangArray[10];//货号
    
    //下架时间
    NSString *down_timeStr = @"0";
    if (_endTime.text.length>0) {
        down_timeStr = _endTime.text;
    }
    
    //分类
    NSString *fenleiStr_int = nil;
    
    if ([_fenleiLabel.text isEqualToString:@"上衣"]) {
        fenleiStr_int = @"1";
    }else if ([_fenleiLabel.text isEqualToString:@"裤子"]){
        fenleiStr_int = @"2";
    }else if ([_fenleiLabel.text isEqualToString:@"裙子"]){
        fenleiStr_int = @"3";
    }else if ([_fenleiLabel.text isEqualToString:@"内衣"]){
        fenleiStr_int = @"4";
    }else if ([_fenleiLabel.text isEqualToString:@"配饰"]){
        fenleiStr_int = @"5";
    }else if ([_fenleiLabel.text isEqualToString:@"其他"]){
        fenleiStr_int = @"0";
    }
    
    

    //类型
    NSString *product_hotsale = nil;//热销
    NSString *product_new = nil;//新品
    
    NSString *gengder = nil;
    if ([_genderLabel.text isEqualToString:@"男"]) {
        gengder = @"2";
    }else if ([_genderLabel.text isEqualToString:@"女"]){
        gengder = @"1";
    }
    
    if ([_leixingLabel.text isEqualToString:@"折扣"]) {
        product_new = @"0";
        product_hotsale = @"0";
    }else if ([_leixingLabel.text isEqualToString:@"新品"]){
        product_new = @"1";
        product_hotsale = @"0";
    }else if ([_leixingLabel.text isEqualToString:@"畅销"]){
        product_new = @"0";
        product_hotsale = @"1";
    }
    
    if ([tf4.text floatValue]<10.0f && [tf4.text floatValue]>100.0f) {
        [GMAPI showAutoHiddenMBProgressWithText:@"折扣输入错误" addToView:self.view];
        return;
    }
    
    CGFloat zhekou = 0;
    if ([tf4.text isEqualToString:@"无折扣"]) {
        zhekou = 10;
    }else{
        zhekou = [tf4.text floatValue];
    }
    
    NSString *zhekouStr = [NSString stringWithFormat:@"%.1f",zhekou];
    NSDictionary *dataDic = [NSDictionary dictionary];
    
    if (self.thetype == GEDITCLOTH) {
        
        NSString *product_id = self.theEditProduct.product_id;
        uploadImageUrlStr = GEDITPRODUCT_MANAGE;
        
        
        if (self.oldImageArray.count>0 && self.assetsArray.count>0) {//有老图有新图
            dataDic = @{
                        @"product_name":tf1.text,//产品名
                        @"product_gender":gengder,//产品适用性别
                        @"product_price":tf3.text,//现价
                        @"original_price":tf2.text,//原价
                        @"product_brand_id":self.mallInfo.brand_id,//产品品牌id
                        @"product_brand_name":tf.text,//品牌名称
                        @"product_shop_id":self.userInfo.shop_id,//商店id
                        @"product_hotsale":product_hotsale,//是否热销
                        @"product_new":product_new,//是否新品
                        @"discount_num":zhekouStr,//打折力度
                        @"product_tag":tf5.text,//标签
                        @"authcode":[GMAPI getAuthkey],//用户标示
                        @"product_id":product_id,
                        @"img_id":_oldImages_Ids_str,
                        @"down_time":down_timeStr,
                        @"product_sku":tf6.text,//货号
                        @"product_type":fenleiStr_int//分类
                        };
        }else if (self.oldImageArray.count>0){//只有老图
            
            NSString *postStr = [NSString stringWithFormat:@"&product_name=%@&product_gender=%@&product_price=%@&original_price=%@&product_brand_id=%@&product_brand_name=%@&product_shop_id=%@&product_hotsale=%@&product_new=%@&discount_num=%@&product_tag=%@&authcode=%@&product_id=%@&img_id=%@&down_time=%@&product_sku=%@&product_type=%@",tf1.text,gengder,tf3.text,tf2.text,self.mallInfo.brand_id,tf.text,self.userInfo.shop_id,product_hotsale,product_new,zhekouStr,tf5.text,[GMAPI getAuthkey],product_id,_oldImages_Ids_str,down_timeStr,tf6.text,fenleiStr_int];
            
            NSData *postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            
            LTools *ccc = [[LTools alloc]initWithUrl:uploadImageUrlStr isPost:YES postData:postData];
            [ccc requestCompletion:^(NSDictionary *result, NSError *erro) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSDictionary *mydic=result;
                if (mydic == nil) {
                     [GMAPI showAutoHiddenMBProgressWithText:@"上传失败" addToView:self.view];
                    return;
                }
                
                if ([[mydic objectForKey:@"errorcode"]intValue]==0) {
                    [GMAPI showAutoHiddenMBProgressWithText:@"修改成功" addToView:self.view];
                    [[NSNotificationCenter defaultCenter]postNotificationName:GEDITPRODUCT_SUCCESS object:nil];
                    [self performSelector:@selector(fabuyifuSuccessToGoBack) withObject:[NSNumber numberWithBool:YES] afterDelay:1.2];
                    
                }else{
                }
            } failBlock:^(NSDictionary *failDic, NSError *erro) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            return;
        }else if (self.assetsArray.count>0){//只有新图
            dataDic = @{
                        @"product_name":tf1.text,//产品名
                        @"product_gender":gengder,//产品适用性别
                        @"product_price":tf3.text,//现价
                        @"original_price":tf2.text,//原价
                        @"product_brand_id":self.mallInfo.brand_id,//产品品牌id
                        @"product_brand_name":tf.text,//品牌名称
                        @"product_shop_id":self.userInfo.shop_id,//商店id
                        @"product_hotsale":product_hotsale,//是否热销
                        @"product_new":product_new,//是否新品
                        @"discount_num":zhekouStr,//打折力度
                        @"product_tag":tf5.text,//标签
                        @"authcode":[GMAPI getAuthkey],//用户标示
                        @"product_id":product_id,
                        @"down_time":down_timeStr,
                        @"product_sku":tf6.text,//货号
                        @"product_type":fenleiStr_int//分类
                        };
        }else{
            [GMAPI showAutoHiddenMidleQuicklyMBProgressWithText:@"请添加图片" addToView:self.view];
            return;
        }
        
        //设置接收响应类型为标准HTTP类型(默认为响应类型为JSON)
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        AFHTTPRequestOperation  * o2= [manager
                                       POST:uploadImageUrlStr
                                       parameters:dataDic
                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                       {
                                           
                                           for (int i = 0; i < aImage_arr.count; i ++) {
                                               
                                               UIImage *aImage = aImage_arr[i];
                                               
                                               NSData * data= UIImageJPEGRepresentation(aImage, 0.8);
                                               
                                               NSLog(@"---> 大小 %ld",(unsigned long)data.length);
                                               
                                               NSString *imageName = [NSString stringWithFormat:@"icon%d.jpg",i];
                                               
                                               NSString *picName = [NSString stringWithFormat:@"images%d",i];
                                               
                                               [formData appendPartWithFileData:data name:picName fileName:imageName mimeType:@"image/jpg"];
                                               
                                           }
                                           
                                           
                                       }
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
                                       {
                                           
                                           
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           
                                           NSLog(@"success %@",responseObject);
                                           
                                           NSError * myerr;
                                           
                                           NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:&myerr];
                                           
                                           
                                           NSLog(@"mydic == %@ err0 = %@",mydic,myerr);
                                           
                                           if (mydic == nil) {
                                               [GMAPI showAutoHiddenMBProgressWithText:@"上传失败" addToView:self.view];
                                               return;
                                           }
                                           
                                           if ([[mydic objectForKey:@"errorcode"]intValue]==0) {
                                               [GMAPI showAutoHiddenMBProgressWithText:@"修改成功" addToView:self.view];
                                               [[NSNotificationCenter defaultCenter]postNotificationName:GEDITPRODUCT_SUCCESS object:nil];
                                               [self performSelector:@selector(fabuyifuSuccessToGoBack) withObject:[NSNumber numberWithBool:YES] afterDelay:1.2];
                                               
                                           }else{
                                               [GMAPI showAutoHiddenMBProgressWithText:[mydic objectForKey:@"msg"] addToView:self.view];
                                           }
                                           
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           
                                           [GMAPI showAutoHiddenMBProgressWithText:@"修改失败请重新修改" addToView:self.view];
                                           
                                           NSLog(@"失败 : %@",error);
                                           
                                           
                                       }];
        
        //设置上传操作的进度
        [o2 setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
        }];
        
        
        return;
    }
    
    
    
    
    
    
    //设置接收响应类型为标准HTTP类型(默认为响应类型为JSON)
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation  * o2= [manager
                                   POST:uploadImageUrlStr
                                   parameters:@{
                                                @"product_name":tf1.text,//产品名
                                                @"product_gender":gengder,//产品适用性别
                                                @"product_price":tf3.text,//现价
                                                @"product_brand_id":self.mallInfo.brand_id,//产品品牌id
                                                @"product_brand_name":tf.text,//品牌名称
                                                @"product_shop_id":self.userInfo.shop_id,//商店id
                                                @"product_hotsale":product_hotsale,//是否热销
                                                @"product_new":product_new,//是否新品
                                                @"discount_num":zhekouStr,//打折力度
                                                @"product_tag":tf5.text,//标签
                                                @"original_price":tf2.text,//原价
                                                @"authcode":[GMAPI getAuthkey],//用户标示
                                                @"down_time":down_timeStr,
                                                @"product_sku":tf6.text,//货号
                                                @"product_type":fenleiStr_int//分类
                                                }
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                   {
                                       
                                       for (int i = 0; i < aImage_arr.count; i ++) {
                                           
                                           UIImage *aImage = aImage_arr[i];
                                           
                                           NSData * data= UIImageJPEGRepresentation(aImage, 0.8);
                                           
                                           NSLog(@"---> 大小 %ld",(unsigned long)data.length);
                                           
                                           NSString *imageName = [NSString stringWithFormat:@"icon%d.jpg",i];
                                           
                                           NSString *picName = [NSString stringWithFormat:@"images%d",i];
                                           
                                           [formData appendPartWithFileData:data name:picName fileName:imageName mimeType:@"image/jpg"];
                                           
                                       }
                                       
                                       
                                   }
                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
                                   {
                                       
                                       
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       NSLog(@"success %@",responseObject);
                                       
                                       NSError * myerr;
                                       
                                       NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:&myerr];
                                       
                                       
                                       NSLog(@"mydic == %@ err0 = %@",mydic,myerr);
                                       
                                       if (mydic == nil) {
                                           [GMAPI showAutoHiddenMBProgressWithText:@"上传失败" addToView:self.view];
                                           return;
                                       }
                                       
                                       if ([[mydic objectForKey:@"errorcode"]intValue]==0) {
                                           [GMAPI showAutoHiddenMBProgressWithText:@"添加成功" addToView:self.view];
                                           [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FABUDANPIN_SUCCESS object:nil];
                                           [self performSelector:@selector(fabuyifuSuccessToGoBack) withObject:[NSNumber numberWithBool:YES] afterDelay:1.2];
                                           
                                       }else{
                                           [GMAPI showAutoHiddenMBProgressWithText:[mydic objectForKey:@"msg"] addToView:self.view];
                                       }
                                       
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       
                                       [GMAPI showAutoHiddenMBProgressWithText:@"添加失败请重新上传" addToView:self.view];
                                       
                                       NSLog(@"失败 : %@",error);
                                       
                                       
                                   }];
    
    //设置上传操作的进度
    [o2 setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
    }];
    
    
}




-(void)fabuyifuSuccessToGoBack{
    [self.navigationController popViewControllerAnimated:YES];
}




//创建信息填写view
-(void)creatView1{
    
    
    
    _view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 15, DEVICE_WIDTH, 553)];
    _view1.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview:_view1];
    
    
    NSString *pinpai = nil;
    if ([self.mallInfo.brand_id isEqualToString:@"0"]) {//精品店
        
    }else{//商场店
        pinpai = self.mallInfo.shop_name;//品牌
    }
    
    NSArray *titleNameArray = @[@"品牌",@"品名",@"原价",@"现价",@"折扣",@"标签",@"类型",@"性别",@"下架",@"分类",@"货号"];
    
    for (int i = 0; i<11; i++) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0+i*50.5, DEVICE_WIDTH, 50)];
        //收键盘
        UIControl *tapshou = [[UIControl alloc]initWithFrame:backView.bounds];
        [tapshou addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchDown];
        [backView addSubview:tapshou];
        
        //分割线
        if (i == 0) {
            UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
            line1.backgroundColor = RGBCOLOR(234, 234, 234);
            UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, DEVICE_WIDTH, 0.5)];
            line2.backgroundColor = RGBCOLOR(234, 234, 234);
            [backView addSubview:line1];
            [backView addSubview:line2];
        }else{
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, DEVICE_WIDTH, 0.5)];
            line.backgroundColor = RGBCOLOR(234, 234, 234);
            [backView addSubview:line];
        }
        
        //标题
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 15, 35, 20)];
        titleLabel.tag = 1000+i;
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = RGBCOLOR(114, 114, 114);
        titleLabel.text = titleNameArray[i];
        [backView addSubview:titleLabel];
        
        
        //输入框
        UITextField *shuruTf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+20, titleLabel.frame.origin.y, DEVICE_WIDTH-17-17-20-titleLabel.frame.size.width, titleLabel.frame.size.height)];
        shuruTf.font = [UIFont systemFontOfSize:17];
        shuruTf.textColor = RGBCOLOR(3, 3, 3);
        shuruTf.tag = 200+i;
        shuruTf.delegate = self;
        [_shurukuangArray addObject:shuruTf];
        [backView addSubview:shuruTf];
        
        
        if (i == 0) {
            if (pinpai) {
                shuruTf.text = pinpai;
                shuruTf.userInteractionEnabled = NO;
            }
        }
        
        
        if (i == 6) {
            shuruTf.text = @"123";
            shuruTf.hidden = YES;
            _leixingLabel = [[UILabel alloc]initWithFrame:shuruTf.frame];
            _leixingLabel.userInteractionEnabled = YES;
            _leixingLabel.textColor = RGBCOLOR(199, 199, 205);
            _leixingLabel.text = @"请选择单品类型";
            UITapGestureRecognizer *ttt = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseLeixing)];
            [_leixingLabel addGestureRecognizer:ttt];
            [backView addSubview:_leixingLabel];
        }
        
        if (i == 7) {
            shuruTf.text = @"123";
            shuruTf.hidden = YES;
            _genderLabel = [[UILabel alloc]initWithFrame:shuruTf.frame];
            _genderLabel.userInteractionEnabled = YES;
            _genderLabel.textColor = RGBCOLOR(199, 199, 205);
            _genderLabel.text = @"请选择性别";
            UITapGestureRecognizer *ttt = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseGender)];
            [_genderLabel addGestureRecognizer:ttt];
            [backView addSubview:_genderLabel];
        }
        
        if (i == 9) {
            shuruTf.text = @"123";
            shuruTf.hidden = YES;
            _fenleiLabel = [[UILabel alloc]initWithFrame:shuruTf.frame];
            _fenleiLabel.userInteractionEnabled = YES;
            _fenleiLabel.textColor = RGBCOLOR(199, 199, 205);
            _fenleiLabel.text = @"请选择分类";
            UITapGestureRecognizer *ttt = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseFenlei)];
            [_fenleiLabel addGestureRecognizer:ttt];
            [backView addSubview:_fenleiLabel];
        }
        
        
        
        if (i == 3) {
            shuruTf.placeholder = @"单位:元";
            shuruTf.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 4){
            shuruTf.placeholder = @"自动生成:88即为88折";
            shuruTf.userInteractionEnabled = NO;
        }else if (i == 5){
            shuruTf.placeholder = @"如:运动,休闲,时尚,商务";
        }else if (i == 1){
            shuruTf.placeholder = @"请填写单品名称";
        }else if (i == 2){
            shuruTf.placeholder = @"单位:元";
            shuruTf.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 8){
            shuruTf.text = @"123";
            shuruTf.hidden = YES;
            //结束时间
            _endTime = [[UILabel alloc]initWithFrame:shuruTf.frame];
            _endTime.text = @"选择自动下架时间(选填)";
            _endTime.textColor = RGBCOLOR(199, 199, 205);
            _endTime.userInteractionEnabled = YES;
            [backView addSubview:_endTime];
            UITapGestureRecognizer *tapc = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseEndTime:)];
            [_endTime addGestureRecognizer:tapc];
            
            
            if (self.thetype == GEDITCLOTH) {
                _endTime.text = [GMAPI timechangeAll2:self.theEditProduct.auto_down_time];
                _endTime.textColor = [UIColor blackColor];
            }
        }else if (i == 10){
            shuruTf.placeholder = @"请填写货号";
            shuruTf.keyboardType = UIKeyboardTypeEmailAddress;
        }
        
        [_view1 addSubview:backView];
        
    }
    
}

//选择类型
-(void)chooseLeixing{
    
    [self jisuanZekou];
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"选择商品类型" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"折扣",@"新品",@"畅销", nil];
    al.tag = -5;
    
    [al show];
}

//选择性别
-(void)chooseGender{
    
    [self jisuanZekou];
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"选择性别" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女", nil];
    al.tag = -6;
    
    [al show];
}

//选择单品分类
-(void)chooseFenlei{
    
    [self jisuanZekou];
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"选择分类" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上衣",@"裤子",@"裙子",@"内衣",@"配饰",@"其他", nil];
    al.tag = -7;
    [al show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == -5) {
        _leixingLabel.textColor = [UIColor blackColor];
        if (buttonIndex == 1) {
            _leixingLabel.text = @"折扣";
        }else if (buttonIndex == 2){
            _leixingLabel.text = @"新品";
        }else if (buttonIndex == 3){
            _leixingLabel.text = @"畅销";
        }else{
            _leixingLabel.textColor = RGBCOLOR(199, 199, 205);
            _leixingLabel.text = @"请选择单品类型";
        }
    }else if (alertView.tag == -6){
        _genderLabel.textColor = [UIColor blackColor];
        if (buttonIndex == 1) {
            _genderLabel.text = @"男";
        }else if (buttonIndex == 2){
            _genderLabel.text = @"女";
        }else{
            _genderLabel.textColor = RGBCOLOR(199, 199, 205);
            _genderLabel.text = @"请选择性别";
        }
    }else if (alertView.tag == -7){
        _fenleiLabel.textColor = [UIColor blackColor];
        if (buttonIndex == 1) {
            _fenleiLabel.text = @"上衣";
        }else if (buttonIndex == 2){
            _fenleiLabel.text = @"裤子";
        }else if (buttonIndex == 3){
            _fenleiLabel.text = @"裙子";
        }else if (buttonIndex == 4){
            _fenleiLabel.text = @"内衣";
        }else if (buttonIndex == 5){
            _fenleiLabel.text = @"配饰";
        }else if (buttonIndex == 6){
            _fenleiLabel.text = @"其他";
        }else{
            _fenleiLabel.textColor = RGBCOLOR(199, 199, 205);
            _fenleiLabel.text = @"请选择分类";
        }
    }
    
    
}



-(void)creatView2{
    _view2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_view1.frame)+12, DEVICE_WIDTH, 120)];
    if (DEVICE_WIDTH>320) {
        [_view2 setFrame:CGRectMake(0, CGRectGetMaxY(_view1.frame)+12, DEVICE_WIDTH, 180)];
    }
    _view2.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview:_view2];
    
    
    
    //收键盘
    UIControl *tapshou = [[UIControl alloc]initWithFrame:_view2.bounds];
    [tapshou addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchDown];
    [_view2 addSubview:tapshou];
    
    
    
    //上传衣服标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 15, 70, 20)];
    titleLabel.textColor = RGBCOLOR(114, 114, 114);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.text = @"上传图片";
    [_view2 addSubview:titleLabel];
    
    
    //上传衣服加号和图片view
    
    CGFloat btnWeight = (DEVICE_WIDTH - 13*7)/6.0f;
    
    for (int i = 0; i<6; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100+i;
        if (i == 0) {
            [btn setBackgroundImage:[UIImage imageNamed:@"gaddphoto.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(tianjiatupian:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(removeSelf:) forControlEvents:UIControlEventTouchUpInside];
            [_showPicsBtnArray addObject:btn];
        }
        
        
        
        
        [btn setFrame:CGRectMake(13+(btnWeight+13)*i, CGRectGetMaxY(titleLabel.frame)+13, btnWeight, btnWeight)];
        
        [_view2 addSubview:btn];
    }
    
    
    
    //提示
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, _view2.frame.size.height-50, DEVICE_WIDTH-24, 20)];
    if (DEVICE_WIDTH == 320) {
        [tishiLabel setFrame:CGRectMake(15, _view2.frame.size.height - 25, DEVICE_WIDTH-24, 20)];
    }
    tishiLabel.font = [UIFont systemFontOfSize:13];
    tishiLabel.textColor = [UIColor grayColor];
    tishiLabel.text = @"提示：选择图片完成后点击图片进行删除操作。";
    [_view2 addSubview:tishiLabel];
    
    
    
}



-(void)removeSelf:(UIButton *)sender{
    
    NSInteger xiabiao = sender.tag - 101;
    
    
    if (self.thetype == GEDITCLOTH) {//修改
        
        if (self.oldImageArray.count>0 && self.assetsArray.count>0) {//有老图有新图
            if (self.oldImageArray.count>xiabiao) {//要删除的位置有老图
                [self.oldImageArray removeObjectAtIndex:xiabiao];
                [_oldImages_Ids_Array removeObjectAtIndex:xiabiao];
                for (UIButton *btn in _showPicsBtnArray) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
                }
                for (int i = 0; i<self.oldImageArray.count; i++) {
                    UIButton *btn = _showPicsBtnArray[i];
                    [btn setBackgroundImage:self.oldImageArray[i] forState:UIControlStateNormal];
                }
                NSInteger oldImvArrayCount = self.oldImageArray.count;
                NSInteger assetArrayCount = self.assetsArray.count;
                for (int i = 0; i<assetArrayCount; i++) {
                    JKAssets *asset = self.assetsArray[i];;
                    ALAssetsLibrary  *lib = [[ALAssetsLibrary alloc] init];
                    [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                        if (asset) {
                            UIButton *btn = _showPicsBtnArray[i+oldImvArrayCount];
                            [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                        }
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
                
                
            }else{//再判断要删除的位置有没有新图
                if (self.assetsArray.count>(xiabiao-self.oldImageArray.count)){//有新图
                    
                    NSInteger oldImvArrayCount = self.oldImageArray.count;
                    NSInteger assetArrayCount = self.assetsArray.count;
                    [self.assetsArray removeObjectAtIndex:(xiabiao - oldImvArrayCount)];
                    
                    for (UIButton *btn in _showPicsBtnArray) {
                        [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
                    }
                    
                    for (int i = 0; i<oldImvArrayCount; i++) {
                        UIButton *btn = _showPicsBtnArray[i];
                        [btn setBackgroundImage:self.oldImageArray[i] forState:UIControlStateNormal];
                    }
                    assetArrayCount = self.assetsArray.count;//新图的个数发生了变化
                    for (int i = 0; i<assetArrayCount; i++) {
                        JKAssets *asset = self.assetsArray[i];;
                        ALAssetsLibrary  *lib = [[ALAssetsLibrary alloc] init];
                        [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                            if (asset) {
                                UIButton *btn = _showPicsBtnArray[i+oldImvArrayCount];
                                [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                            }
                        } failureBlock:^(NSError *error) {
                            
                        }];
                    }

                }
            }
        }else if (self.assetsArray.count>0){//只有新图
            if (self.assetsArray.count>xiabiao){
                [self.assetsArray removeObjectAtIndex:xiabiao];
                for (UIButton *btn in _showPicsBtnArray) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
                }
                ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
                for (int i = 0; i<self.assetsArray.count; i++) {
                    JKAssets *asset = self.assetsArray[i];
                    [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                        if (asset) {
                            UIButton *btn = _showPicsBtnArray[i];
                            [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                        }
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            }
            
            
        }else if (self.oldImageArray.count>0){//只有老图
            if (self.oldImageArray.count>xiabiao) {//要删除的位置有老图
                [self.oldImageArray removeObjectAtIndex:xiabiao];
                [_oldImages_Ids_Array removeObjectAtIndex:xiabiao];
                for (UIButton *btn in _showPicsBtnArray) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
                }
                for (int i = 0; i<self.oldImageArray.count; i++) {
                    UIButton *btn = _showPicsBtnArray[i];
                    [btn setBackgroundImage:self.oldImageArray[i] forState:UIControlStateNormal];
                }
            }
        }else{//没图
            
        }
        
        
        
        
    }else if (self.thetype == GUPCLOTH){//上传单品
        if (self.assetsArray.count<=xiabiao) {
            return;
        }
        [self.assetsArray removeObjectAtIndex:xiabiao];
        for (UIButton *btn in _showPicsBtnArray) {
            [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
        }
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        for (int i = 0; i<self.assetsArray.count; i++) {
            JKAssets *asset = self.assetsArray[i];
            [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    UIButton *btn = _showPicsBtnArray[i];
                    [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                }
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }
    
    
    
    
    
}





-(void)nnnn:(UISwitch*)sender{
    if (sender.on) {
        _genderLabel.text = @"女";
    }else{
        _genderLabel.text = @"男";
    }
}




//弹出action提示
-(void)tianjiatupian:(UIButton *) sender
{
    UIActionSheet *selectPhotoSheet=[[UIActionSheet alloc]initWithTitle:@"选择照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取", nil];
    selectPhotoSheet.actionSheetStyle=UIActionSheetStyleDefault;
    [selectPhotoSheet showInView:self.view];
}



#pragma mark--UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self composePicAdd];
    }
    
}




#pragma mark - 获取所选图片
-(void)getChoosePics{
    
    _oldImages_Ids_str = @" ";
    
    //老图
    self.uploadImageArray = [NSMutableArray arrayWithCapacity:1];
    
    
    if (self.oldImageArray.count>0 && self.assetsArray.count>0) {//有老图有新图
        //先传老图id
        
        _oldImages_Ids_str = [_oldImages_Ids_Array componentsJoinedByString:@","];
        //再传新图
        for (int i = 0;i<self.assetsArray.count;i++) {
            JKAssets* jkAsset = self.assetsArray[i];
            ALAssetsLibrary* lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    [self.uploadImageArray addObject:image];
                    if (self.uploadImageArray.count == self.assetsArray.count) {
                        [self upLoadImage:self.uploadImageArray];
                    }
                }
                
            } failureBlock:^(NSError *error) {
                
            }];
        }
        
    }else if (self.oldImageArray.count>0){//只有老图
        //传老图id
        _oldImages_Ids_str = [_oldImages_Ids_Array componentsJoinedByString:@","];
        [self upLoadImage:nil];
        
        
    }else if (self.assetsArray.count>0){//只有新图
        //传新图
        for (int i = 0;i<self.assetsArray.count;i++) {
            JKAssets* jkAsset = self.assetsArray[i];
            ALAssetsLibrary* lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:jkAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    [self.uploadImageArray addObject:image];
                    if (self.uploadImageArray.count == self.assetsArray.count) {
                        [self upLoadImage:self.uploadImageArray];
                    }
                }
                
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }else{
        [GMAPI showAutoHiddenMidleQuicklyMBProgressWithText:@"请添加图片" addToView:self.view];
    }
    
    
    
    

    
    
}





//相册
- (void)composePicAdd
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 0;
    imagePickerController.maximumNumberOfSelection = 5;
    if (self.thetype == GEDITCLOTH) {
        if (self.oldImageArray.count>0) {
            imagePickerController.maximumNumberOfSelection = 5 - self.oldImageArray.count;
        }
    }
    imagePickerController.selectedAssetArray = self.assetsArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    self.assetsArray = [NSMutableArray arrayWithArray:assets];
    for (UIButton *btn in _showPicsBtnArray) {
        [btn setBackgroundImage:[UIImage imageNamed:@"gremovephoto.png"] forState:UIControlStateNormal];
    }
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
        
        if (self.thetype == GEDITCLOTH) {
            
            NSInteger oldImvArrayCount = self.oldImageArray.count;
            NSInteger assetArrayCount = self.assetsArray.count;
            
            
            for (int i = 0; i<oldImvArrayCount; i++) {
                UIButton *btn = _showPicsBtnArray[i];
                [btn setBackgroundImage:self.oldImageArray[i] forState:UIControlStateNormal];
            }
            
            for (int i = 0; i<assetArrayCount; i++) {
                JKAssets *asset = self.assetsArray[i];;
                ALAssetsLibrary  *lib = [[ALAssetsLibrary alloc] init];
                [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        UIButton *btn = _showPicsBtnArray[i+oldImvArrayCount];
                        [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                    }
                } failureBlock:^(NSError *error) {
                    
                }];
            }
            
            
            
        }else if (self.thetype == GUPCLOTH){
            ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
            for (int i = 0; i<self.assetsArray.count; i++) {
                JKAssets *asset = self.assetsArray[i];
                [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        UIButton *btn = _showPicsBtnArray[i];
                        [btn setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
                    }
                } failureBlock:^(NSError *error) {
                    
                }];
            }
        }
        
        
    }];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


//创建时间选择器view
-(void)creatDatePickerChooseView{
    _dateChooseView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 300)];
    _dateChooseView.backgroundColor = [UIColor whiteColor];
    
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 260)];
    [_dateChooseView addSubview:_datePicker];
    
    //取消按钮
    UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quxiaoBtn setTitle:@"取消" forState:UIControlStateNormal];
    [quxiaoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quxiaoBtn.frame = CGRectMake(10, 5, 60, 40);
    quxiaoBtn.layer.borderColor = [[UIColor blackColor]CGColor];
    quxiaoBtn.layer.borderWidth = 1;
    quxiaoBtn.layer.cornerRadius = 5;
    [quxiaoBtn addTarget:self action:@selector(datePickerQuxiao) forControlEvents:UIControlEventTouchUpInside];
    [_dateChooseView addSubview:quxiaoBtn];
    
    //确定按钮
    UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quedingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
    [quedingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quedingBtn.frame = CGRectMake(DEVICE_WIDTH-70, 5, 60, 40);
    quedingBtn.layer.borderWidth = 1;
    quedingBtn.layer.borderColor = [[UIColor blackColor]CGColor];
    quedingBtn.layer.cornerRadius = 5;
    [quedingBtn addTarget:self action:@selector(datePickerHideen) forControlEvents:UIControlEventTouchUpInside];
    [_dateChooseView addSubview:quedingBtn];
    
    
    
    
    [self.view addSubview:_dateChooseView];
    
    
}

//隐藏datepick
-(void)datePickerHideen{
    [UIView animateWithDuration:0.3 animations:^{
        _dateChooseView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, _dateChooseView.frame.size.height);
        if (_dateChooseView.tag == 1001){//结束时间
            _date_end = _datePicker.date;
            _endTime.text = [GMAPI getTimeWithDate1:_datePicker.date];
            _endTime.textColor = [UIColor blackColor];
        }
    } completion:^(BOOL finished) {
        
    }];
}

//取消选择日期
-(void)datePickerQuxiao{
    [UIView animateWithDuration:0.3 animations:^{
        _dateChooseView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, _dateChooseView.frame.size.height);
        if (_dateChooseView.tag == 1001){//结束时间
            _date_end = nil;
            _endTime.text = @"选择自动下架时间(选填)";
            _endTime.textColor = RGBCOLOR(199, 199, 205);
            
        }
    } completion:^(BOOL finished) {
        
    }];
}



//选择结束时间
-(void)chooseEndTime:(UITapGestureRecognizer*)sender{
    for (UITextField *tf in _shurukuangArray) {
        [tf resignFirstResponder];
    }
    
    _mainScrollView.contentSize = _theSize_haveKeyboard;
    
    if (_mainScrollView.contentOffset.y < 8 *51) {
        [_mainScrollView setContentOffset:CGPointMake(0, 8*51) animated:YES];
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _dateChooseView.frame = CGRectMake(0, DEVICE_HEIGHT-_dateChooseView.frame.size.height, DEVICE_WIDTH, _dateChooseView.frame.size.height);
        _dateChooseView.tag = 1001;
    } completion:^(BOOL finished) {
        
    }];
}








@end
