//
//  GChooseColorSizeTableViewCell.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GChooseColorSizeTableViewCell.h"
#import "GBtn.h"
#import "UILabel+GautoMatchedText.h"
#import "GChooseColorAndSizeViewController.h"


@implementation GChooseColorSizeTableViewCell
{
    UILabel *_numLabel;
    NSMutableArray *_colorLabelArray;
    NSMutableArray *_sizeLabelArray;
    NSIndexPath *_theIndexPath;
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)loadCustomViewWithIndexPath:(NSIndexPath*)theIndexPath netDatamodel:(NSDictionary *)dic{
    
    
    _theIndexPath = theIndexPath;
    ProductModel *amodel = self.delegate.productModelArray[theIndexPath.row];
    self.netDataDic = dic;
    
    //选择button
    GBtn *chooseBtn = [GBtn buttonWithType:UIButtonTypeCustom];
    [chooseBtn setFrame:CGRectMake(0, 8, 35, 44)];
    [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze_xuanzhong.png"] forState:UIControlStateSelected];
    [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze1.png"] forState:UIControlStateNormal];
    chooseBtn.theIndex = theIndexPath;
    [chooseBtn addTarget:self action:@selector(GchooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (amodel.isChoose) {
        chooseBtn.selected = YES;
    }else{
        chooseBtn.selected = NO;
    }
    
    [self.contentView addSubview:chooseBtn];
    
    
    
    
    NSString *imvUrl = amodel.product_cover_pic[@"src"];
    
    NSLog(@"李白 imvurl %@ ",imvUrl);
    
    
    UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(35, 8, 44, 44)];
    [picImv l_setImageWithURL:[NSURL URLWithString:imvUrl] placeholderImage:DEFAULT_YIJIAYI];
    [self.contentView addSubview:picImv];
    
    UILabel *productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picImv.frame)+10, picImv.frame.origin.y, DEVICE_WIDTH - CGRectGetMaxX(picImv.frame)-10, picImv.frame.size.height*0.5)];
    productNameLabel.font = [UIFont systemFontOfSize:12];
    if ([LTools isEmpty:amodel.product_type_name]) {
        
        amodel.product_type_name = @" ";
    }
    if ([LTools isEmpty:amodel.product_name]) {
        
        amodel.product_name = @" ";
    }
    productNameLabel.text = [NSString stringWithFormat:@"%@:%@",amodel.product_type_name,amodel.product_name];
    [self.contentView addSubview:productNameLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(productNameLabel.frame.origin.x, CGRectGetMaxY(productNameLabel.frame), productNameLabel.frame.size.width, productNameLabel.frame.size.height)];
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.textColor = RGBCOLOR(249, 165, 196);
    priceLabel.text = [NSString stringWithFormat:@"￥%@",amodel.product_price];
    [self.contentView addSubview:priceLabel];
    
    
    UIView *fline = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(priceLabel.frame)+8, DEVICE_WIDTH - 10, 0.5)];
    fline.backgroundColor = RGBCOLOR(219, 220, 222);
    [self.contentView addSubview:fline];
    
    //选择颜色view
    UIView *colorChooseView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fline.frame)+2.5, DEVICE_WIDTH, 65)];
    [self.contentView addSubview:colorChooseView];
    UILabel *title_color = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-10, 25)];
    title_color.text = @"颜色:";
    title_color.font = [UIFont systemFontOfSize:12];
    [colorChooseView addSubview:title_color];
    
    
    UIScrollView *colorScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(title_color.frame), DEVICE_WIDTH, 35)];
    colorScrollView.showsHorizontalScrollIndicator = NO;
    colorScrollView.showsVerticalScrollIndicator = NO;
    [colorChooseView addSubview:colorScrollView];
    
    
    
    NSDictionary *colorDic= [dic dictionaryValueForKey:amodel.product_id];
    NSArray *colorArray = [colorDic arrayValueForKey:@"color"];
    NSMutableArray *colorNameArray = [NSMutableArray arrayWithCapacity:1];
//    NSArray *colorNameArray = colorArray
    for (NSDictionary *dic in colorArray) {
        NSString *color_name = [dic stringValueForKey:@"color_name"];
        [colorNameArray addObject:color_name];
    }
    
    NSMutableArray *coloridArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in colorArray) {
        NSString *color_id = [dic stringValueForKey:@"color_id"];
        [coloridArray addObject:color_id];
    }
    
    
    CGFloat colorScrollViewContentWidth = 10;
    NSMutableArray *colorWidthArray = [NSMutableArray arrayWithCapacity:1];
    CGFloat last_x_color = 10.0f;
    
    _colorLabelArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0; i<colorNameArray.count; i++) {
        NSString *colorName = colorNameArray[i];
        UILabel *colorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        colorLabel.textColor = RGBCOLOR(243, 75, 137);
        colorLabel.text = colorName;
        colorLabel.font = [UIFont systemFontOfSize:12];
        colorLabel.layer.borderWidth = 0.5;
        colorLabel.layer.borderColor = [RGBCOLOR(134, 135, 136)CGColor];
        [colorLabel setMatchedFrame4LabelWithOrigin:CGPointMake(last_x_color, 2.5) height:30 limitMaxWidth:DEVICE_WIDTH];
        [colorLabel setWidth:colorLabel.width +25];
        [colorWidthArray addObject:[NSString stringWithFormat:@"%f",colorLabel.frame.size.width]];
        last_x_color += colorLabel.frame.size.width+10;
        colorLabel.textAlignment = NSTextAlignmentCenter;
        colorLabel.layer.borderColor = [RGBCOLOR(134, 135, 136)CGColor];
        colorLabel.tag = i+100;
        [colorLabel addTapGestureTarget:self action:@selector(colorLabelClicked:) tag:i+100];
        [colorScrollView addSubview:colorLabel];
        [_colorLabelArray addObject:colorLabel];
        colorScrollViewContentWidth += (colorLabel.frame.size.width +10);
        
        if (amodel.ischooseColor) {
            NSLog(@"colorName:%@ model.color:%@",colorName,[amodel.colorDic stringValueForKey:@"color_name"]);
            if ([colorName isEqualToString:[amodel.colorDic stringValueForKey:@"color_name"]]) {
                colorLabel.backgroundColor = RGBCOLOR(244, 76, 139);
                colorLabel.textColor = [UIColor whiteColor];
                colorLabel.layer.borderWidth = 0;
            }
        }else{
            if (i == 0) {
                colorLabel.backgroundColor = RGBCOLOR(244, 76, 139);
                colorLabel.textColor = [UIColor whiteColor];
                colorLabel.layer.borderWidth = 0;
                NSString *aa = coloridArray[i];
                NSString *bb = colorNameArray[i];
                ProductModel *model = self.delegate.productModelArray[theIndexPath.row];
                model.colorDic = @{
                                @"color_id":aa,
                                @"color_name":bb
                                };
            }
        }
        
        
        
        
    }
    [colorScrollView setContentSize:CGSizeMake(colorScrollViewContentWidth, 30)];
    
    
    UIView *fline1 = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(colorChooseView.frame)+5, DEVICE_WIDTH-10, 0.5)];
    fline1.backgroundColor = RGBCOLOR(219, 220, 222);
    [self.contentView addSubview:fline1];
    
    
    
    //选择尺码view
    UIView *sizeChooseView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fline1.frame)+2.5, DEVICE_WIDTH, 65)];
    [self.contentView addSubview:sizeChooseView];
    UILabel *title_size = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 25)];
    title_size.text = @"尺码:";
    title_size.font = [UIFont systemFontOfSize:12];
    [sizeChooseView addSubview:title_size];
    
    UIScrollView *sizeScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(title_color.frame), DEVICE_WIDTH, 35)];
    sizeScrollView.showsHorizontalScrollIndicator = NO;
    sizeScrollView.showsVerticalScrollIndicator = NO;
    [sizeChooseView addSubview:sizeScrollView];
    
    
    NSDictionary *sizeDic = [dic dictionaryValueForKey:amodel.product_id];
    NSArray *sizeArray = [sizeDic arrayValueForKey:@"size"];
    NSMutableArray *sizeNameArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in sizeArray) {
        NSString *size_name = [dic stringValueForKey:@"size_name"];
        [sizeNameArray addObject:size_name];
    }
    
    NSMutableArray *sizeidArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in sizeArray) {
        NSString *size_id = [dic stringValueForKey:@"size_id"];
        [sizeidArray addObject:size_id];
    }
    
    CGFloat sizeScrollViewContentWidth = 10;
    NSMutableArray *sizeWidthArray = [NSMutableArray arrayWithCapacity:1];
    CGFloat last_x_size = 10.0f;
    _sizeLabelArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0; i<sizeNameArray.count; i++) {
        NSString *sizeName = sizeNameArray[i];
        UILabel *sizeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        sizeLabel.textColor = RGBCOLOR(243, 75, 137);
        sizeLabel.text = sizeName;
        sizeLabel.font = [UIFont systemFontOfSize:12];
        sizeLabel.layer.borderWidth = 0.5;
        sizeLabel.layer.borderColor = [RGBCOLOR(234, 235, 236)CGColor];
        [sizeLabel setMatchedFrame4LabelWithOrigin:CGPointMake(last_x_size, 2.5) height:30 limitMaxWidth:DEVICE_WIDTH];
        [sizeLabel setWidth:sizeLabel.width +25];
        [sizeWidthArray addObject:[NSString stringWithFormat:@"%f",sizeLabel.frame.size.width]];
        last_x_size += sizeLabel.frame.size.width+10;
        sizeLabel.textAlignment = NSTextAlignmentCenter;
        sizeLabel.layer.borderColor = [RGBCOLOR(134, 135, 136)CGColor];
        sizeLabel.tag = i+1000;
        [sizeLabel addTapGestureTarget:self action:@selector(sizeLabelClicked:) tag:i+1000];
        [sizeScrollView addSubview:sizeLabel];
        [_sizeLabelArray addObject:sizeLabel];
        sizeScrollViewContentWidth += (sizeLabel.frame.size.width +10);
        
        
        if (amodel.ischooseSize) {
            if ([sizeName isEqualToString:[amodel.sizeDic stringValueForKey:@"size_name"]]) {
                sizeLabel.backgroundColor = RGBCOLOR(244, 76, 139);
                sizeLabel.textColor = [UIColor whiteColor];
                sizeLabel.layer.borderWidth = 0;
            }
        }else{
            if (i == 0) {
                sizeLabel.backgroundColor = RGBCOLOR(244, 76, 139);
                sizeLabel.textColor = [UIColor whiteColor];
                sizeLabel.layer.borderWidth = 0;
                NSString *aa = sizeidArray[i];
                NSString *bb = sizeNameArray[i];
                ProductModel *model = self.delegate.productModelArray[theIndexPath.row];
                model.sizeDic = @{
                               @"size_id":aa,
                               @"size_name":bb
                               };
            }
        }
        
        
        
        
    }
    [sizeScrollView setContentSize:CGSizeMake(sizeScrollViewContentWidth, 30)];
    
    
    UIView *fline2 = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(sizeChooseView.frame)+5, DEVICE_WIDTH-10, 0.5)];
    fline2.backgroundColor = RGBCOLOR(219, 220, 222);
    [self.contentView addSubview:fline2];

    
    //数量
    UIView *numChooseView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fline2.frame)+2.5, DEVICE_WIDTH, 65)];
    [self.contentView addSubview:numChooseView];
    UILabel *title_num = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 25)];
    title_num.font = [UIFont systemFontOfSize:12];
    title_num.text = @"数量";
    [numChooseView addSubview:title_num];
    
    UIView *numBackView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(title_num.frame), 120, 35)];
    numBackView.backgroundColor = [UIColor whiteColor];
    numBackView.layer.borderColor = [RGBCOLOR(244, 76, 139)CGColor];
    numBackView.layer.cornerRadius = 5;
    numBackView.layer.borderWidth = 0.5;
    [numChooseView addSubview:numBackView];
    
    UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jianBtn setFrame:CGRectMake(0, 0, numBackView.frame.size.width *0.25, 35)];
    [jianBtn addTarget:self action:@selector(jianBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    jianBtn.backgroundColor = [UIColor orangeColor];
    [numBackView addSubview:jianBtn];
    
    UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaBtn setFrame:CGRectMake(numBackView.frame.size.width*0.75, 0, numBackView.frame.size.width*0.25, 35)];
    [jiaBtn addTarget:self action:@selector(jiaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    jiaBtn.backgroundColor = [UIColor orangeColor];
    [numBackView addSubview:jiaBtn];
    
    _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jianBtn.frame), 0, numBackView.frame.size.width*0.5, 35)];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.textColor = RGBCOLOR(80, 81, 82);
    _numLabel.text = [NSString stringWithFormat:@"%ld",amodel.tnum];
    [numBackView addSubview:_numLabel];
    
    
    
    UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(numChooseView.frame)+10, DEVICE_WIDTH, 7)];
    fengeView.backgroundColor = RGBCOLOR(241, 242, 244);
    [self.contentView addSubview:fengeView];
    
    
}


-(void)jianBtnClicked{
    
    ProductModel *model = self.delegate.productModelArray[_theIndexPath.row];
    
    NSInteger num = model.tnum;
    num--;
    if (num <= 1) {
        num = 1;
    }
    _numLabel.text = [NSString stringWithFormat:@"%ld",num];
    
    
    model.tnum = num;
}

-(void)jiaBtnClicked{
    ProductModel *model = self.delegate.productModelArray[_theIndexPath.row];
    NSInteger num = model.tnum;
    num++;
    _numLabel.text = [NSString stringWithFormat:@"%ld",num];
    model.tnum = num;
}


-(void)GchooseBtnClicked:(GBtn *)sender{

    sender.selected = !sender.selected;
    
    ProductModel *model = self.delegate.productModelArray[_theIndexPath.row];
    model.isChoose = sender.selected;
    
    [self.delegate jisuanPrice];
    
}


-(void)colorLabelClicked:(UITapGestureRecognizer *)sender{
    
    ProductModel *amodel = self.delegate.productModelArray[_theIndexPath.row];
    
    for (UILabel *label in _colorLabelArray) {
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = RGBCOLOR(244, 76, 139);
        label.layer.borderWidth = 0.5;
    }
    sender.view.backgroundColor = RGBCOLOR(244, 76, 139);
    UILabel *ll = (UILabel*)sender.view;
    ll.textColor = [UIColor whiteColor];
    ll.layer.borderWidth = 0;
    
    NSInteger index = sender.view.tag-100;
    NSDictionary *dic = [self.netDataDic dictionaryValueForKey:amodel.product_id];
    NSArray *colorArray = [dic arrayValueForKey:@"color"];
    NSDictionary *colorDic = colorArray[index];
    
    NSString *color_id = [colorDic stringValueForKey:@"color_id"];
    NSString *color_name = [colorDic stringValueForKey:@"color_name"];
    
    amodel.ischooseColor = YES;
    amodel.colorDic = @{
                    @"color_id":color_id,
                    @"color_name":color_name
                    };
    
}

-(void)sizeLabelClicked:(UITapGestureRecognizer *)sender{
    
    ProductModel *amodel = self.delegate.productModelArray[_theIndexPath.row];
    
    for (UILabel *label in _sizeLabelArray) {
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = RGBCOLOR(244, 76, 139);
        label.layer.borderWidth = 0.5;
        
    }
    sender.view.backgroundColor = RGBCOLOR(244, 76, 139);
    UILabel *ll = (UILabel*)sender.view;
    ll.textColor = [UIColor whiteColor];
    ll.layer.borderWidth = 0;
    
    NSInteger index = sender.view.tag-1000;
    NSDictionary *dic = [self.netDataDic dictionaryValueForKey:amodel.product_id];
    NSArray *sizeArray = [dic arrayValueForKey:@"size"];
    NSDictionary *sizeDic = sizeArray[index];
    
    NSString *size_id = [sizeDic stringValueForKey:@"size_id"];
    NSString *size_name = [sizeDic stringValueForKey:@"size_name"];
    
    amodel.ischooseSize = YES;
    amodel.sizeDic = @{
                   @"size_id":size_id,
                   @"size_name":size_name
                   };
    
}



@end
