//
//  GcustomSearchTableViewCell.m
//  YiYiProject
//
//  Created by gaomeng on 15/3/29.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GcustomSearchTableViewCell.h"
#import "GsearchViewController.h"
#import "NSDictionary+GJson.h"

@implementation GcustomSearchTableViewCell

{
    NSIndexPath *_flagIndexPath;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGFloat)loadCustomViewWithData:(NSDictionary*)theData indexPath:(NSIndexPath*)theIndex showDidtance:(BOOL)isShow{
    
    CGFloat height = 0.0f;
    if (self.theType == GSEARCHTYPE_SHANGPU) {//商铺
        height = [self loadCustomCellWithDic:theData type:GSEARCHTYPE_SHANGPU showDidtance:isShow];
    }else if (self.theType == GSEARCHTYPE_DANPIN){//单品
        [self loadCustomCellWithDicOfProduct:theData showDidtance:isShow];
        height = 90;
    }else if (self.theType == GSEARCHTYPE_PINPAI){//品牌
        height = [self loadCustomCellWithDic:theData type:GSEARCHTYPE_PINPAI showDidtance:isShow];
    }
    
    
    return height;
    
}




//搜索品牌或商铺
-(CGFloat)loadCustomCellWithDic:(NSDictionary *)dic type:(GSEARCHTYPE)theType showDidtance:(BOOL)isShow{
    
    CGFloat cellHeight = 0.0f;
    
    //name
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 18, 0, 16)];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    if (theType == GSEARCHTYPE_SHANGPU) {
        nameLabel.text = [dic stringValueForKey:@"mall_name"];
        [nameLabel sizeToFit];
        cellHeight += nameLabel.frame.size.height;
        
        //距离
        UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+15, nameLabel.frame.origin.y+4, 0, nameLabel.frame.size.height)];
        distanceLabel.font = [UIFont systemFontOfSize:12];
        distanceLabel.textColor = RGBCOLOR(153, 153, 153);
        distanceLabel.text = [NSString stringWithFormat:@"%@m",[dic stringValueForKey:@"distance"]];
        NSString *juli = [dic stringValueForKey:@"distance"];
        CGFloat juli_f = 0.0f;
        if ([juli intValue] >=1000) {
            juli_f = [juli floatValue]*0.001;
            distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",juli_f];
        }
        [distanceLabel sizeToFit];
        if (!isShow) {
            distanceLabel.hidden = YES;
        }
        
        
        //箭头
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectZero];
        [jiantouImv setImage:[UIImage imageNamed:@"gcustomstore.png"]];
        
        [self.contentView addSubview:jiantouImv];
        
        
        //活动
        UILabel *activeLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, CGRectGetMaxY(nameLabel.frame)+10, DEVICE_WIDTH - 50 , 15)];
        activeLabel.font = [UIFont systemFontOfSize:14];
        activeLabel.textColor = RGBCOLOR(114, 114, 114);
        activeLabel.text = [dic stringValueForKey:@"activity_title"];
        activeLabel.numberOfLines = 1;
        if (activeLabel.text.length == 0) {
            activeLabel.frame = CGRectZero;
        }
        
        cellHeight += distanceLabel.frame.size.height+activeLabel.frame.size.height;
        
        cellHeight += 20;
        
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:distanceLabel];
        [self.contentView addSubview:activeLabel];
        
        
        [jiantouImv setFrame:CGRectMake(DEVICE_WIDTH - 20, cellHeight*0.5-6, 7, 12)];
        
//        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(15, cellHeight-0.5, DEVICE_WIDTH-15, 0.5)];
//        downLine.backgroundColor = RGBCOLOR(226, 226, 228);
//        [self.contentView addSubview:downLine];
        
    }else if (theType == GSEARCHTYPE_PINPAI){
        
        if (self.isHaveKeyWord) {//搜索品牌 并且有关键字
            nameLabel.text = [dic stringValueForKey:@"brand_name"];
        }else{
            nameLabel.text = [dic stringValueForKey:@"brand_name"];
        }
        [self.contentView addSubview:nameLabel];
        [nameLabel sizeToFit];
        cellHeight = 50;
        
        //箭头
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectZero];
        [jiantouImv setImage:[UIImage imageNamed:@"gcustomstore.png"]];
        [jiantouImv setFrame:CGRectMake(DEVICE_WIDTH - 20, cellHeight*0.5-6, 7, 12)];
        [self.contentView addSubview:jiantouImv];
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    return cellHeight;
    
}



-(void)loadCustomCellWithDicOfProduct:(NSDictionary *)dic showDidtance:(BOOL)isShow{
    //图片
    UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 70)];
    [self.contentView addSubview:picImv];
    
    NSDictionary *images = [dic dictionaryValueForKey:@"images"];
    NSDictionary *middle = [images dictionaryValueForKey:@"540Middle"];
    NSString *imageUrl = [middle stringValueForKey:@"src"];
    [picImv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"searchproductdefaulpic.png"]];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picImv.frame)+5, picImv.frame.origin.y, DEVICE_WIDTH-10-60-10, picImv.frame.size.height*0.5)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = [dic stringValueForKey:@"product_name"];
    [self.contentView addSubview:titleLabel];
    
    //附加信息
     UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame), titleLabel.frame.size.width, titleLabel.frame.size.height)];
    
    if (!isShow) {
       
        detailLabel.font = [UIFont systemFontOfSize:15];
        detailLabel.numberOfLines = 2;
        detailLabel.text = [NSString stringWithFormat:@"%@元",[dic stringValueForKey:@"product_price"]];
    }else{
       
        detailLabel.font = [UIFont systemFontOfSize:15];
        detailLabel.numberOfLines = 2;
        NSString *distance = [dic stringValueForKey:@"distance"];
        detailLabel.text = [NSString stringWithFormat:@"%@元   %@m",[dic stringValueForKey:@"product_price"],distance];
        
        CGFloat juli_f = 0.0f;
        if ([distance intValue] >=1000) {
            juli_f = [distance floatValue]*0.001;
            distance = [NSString stringWithFormat:@"%.2f",juli_f];
            detailLabel.text = [NSString stringWithFormat:@"%@元   %@km",[dic stringValueForKey:@"product_price"],distance];
        }
    }
    
    
    
    
    
    
    
    
    
    [self.contentView addSubview:detailLabel];
}


@end
