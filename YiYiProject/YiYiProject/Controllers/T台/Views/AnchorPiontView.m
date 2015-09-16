//
//  AnchorPiontView.m
//  YiYiProject
//
//  Created by lichaowei on 15/4/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AnchorPiontView.h"

#define ACHORVIEW_HEIGHT 22

@implementation AnchorPiontView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{
//    NSLog(@"--%s--",__FUNCTION__);
    self.annimationView = nil;
    self.halo = nil;
    self.titleLabel = nil;
}

-(instancetype)initWithAnchorPoint:(CGPoint)anchorPoint
                             title:(NSString *)title
                             price:(NSString *)thePrice
{
    self = [super initWithFrame:CGRectMake(anchorPoint.x, anchorPoint.y, 0, ACHORVIEW_HEIGHT)];
    if (self) {
        
        
        BOOL isRight  = YES;
        
        //满足此条件则放左侧
        if (anchorPoint.x > DEVICE_WIDTH*0.5) {
            
            isRight = NO;
        }
        
        thePrice = [NSString stringWithFormat:@"￥%d",[thePrice intValue]];
        
        if (isRight) {
            
            //标记位置view
            
            self.annimationView = [[UIView alloc]initWithFrame:CGRectMake(0, (ACHORVIEW_HEIGHT - 7) /2.f, 7, 7)];
            self.annimationView.backgroundColor = [UIColor whiteColor];
            self.annimationView.layer.cornerRadius = 3.5f;
            self.annimationView.clipsToBounds = YES;
            [self addSubview:_annimationView];
            
            self.halo = [PulsingHaloLayer layer];
            self.halo.position = self.annimationView.center;
            self.halo.animationDuration = 1.f;
            self.halo.radius = 10.f;
            self.halo.backgroundColor = [UIColor blackColor].CGColor;
            [self.layer insertSublayer:self.halo below:self.annimationView.layer];
            
            
            //文字宽度
            
            CGFloat aWidth = [LTools widthForText:title font:12.f];
            
            CGFloat aWidth1 = [LTools widthForText:thePrice font:12.f];
            aWidth1+=2;
            if (aWidth>DEVICE_WIDTH*0.5-aWidth1) {
                aWidth = DEVICE_WIDTH*0.5-aWidth1-10;
            }
            CGFloat aWidth_imageView = aWidth + aWidth1 + 5.5 * 2;//左侧 右侧 7
            
            //箭头imageView
            
            CGFloat left = _annimationView.right + 5;
            
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, aWidth_imageView, ACHORVIEW_HEIGHT)];
            UIImage *image = [UIImage imageNamed:@"jiantou_anchor_right"];
            _imageView.image = [image stretchableImageWithLeftCapWidth:15 topCapHeight:ACHORVIEW_HEIGHT];
            [self addSubview:_imageView];
            
            //文字显示label
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, aWidth, ACHORVIEW_HEIGHT)];
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.titleLabel.textColor = [UIColor whiteColor];
            self.titleLabel.text = title;
            [_imageView addSubview:self.titleLabel];
            
            //价钱
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame)+2, 0, aWidth1, ACHORVIEW_HEIGHT)];
            priceLabel.backgroundColor = RGBCOLOR(244, 76, 139);
            priceLabel.textColor = [UIColor whiteColor];
            priceLabel.font = [UIFont systemFontOfSize:12];
            priceLabel.textAlignment = NSTextAlignmentLeft;
            priceLabel.text = [NSString stringWithFormat:@"%@",thePrice];
            [_imageView addSubview:priceLabel];
            
            
            
            [self setTheRightLocationAndFrame];
            
        }else
        {
            //文字宽度
            
            
            CGFloat aWidth = [LTools widthForText:title font:12.f];
            CGFloat aWidth1 = [LTools widthForText:thePrice font:12.f];
            aWidth1+=2;
            if (aWidth>DEVICE_WIDTH*0.5-aWidth1) {
                aWidth = DEVICE_WIDTH*0.5-aWidth1-10;
            }
            CGFloat aWidth_imageView = aWidth + aWidth1 + 5.5 * 2;//左侧 右侧 7
            
            //箭头imageView
            
            CGFloat left = 0;
            
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, aWidth_imageView, ACHORVIEW_HEIGHT)];
            UIImage *image = [UIImage imageNamed:@"jiantou_anchor_left"];
            _imageView.image = [image stretchableImageWithLeftCapWidth:15 topCapHeight:ACHORVIEW_HEIGHT];
            [self addSubview:_imageView];
            
            //价钱
            UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, aWidth1, ACHORVIEW_HEIGHT)];
            priceLabel.backgroundColor = RGBCOLOR(244, 76, 139);
            priceLabel.textColor = [UIColor whiteColor];
            priceLabel.font = [UIFont systemFontOfSize:12];
            priceLabel.textAlignment = NSTextAlignmentLeft;
            priceLabel.text = [NSString stringWithFormat:@"%@",thePrice];
            [_imageView addSubview:priceLabel];
            
            
            
            //文字显示label
            
            self.titleLabel = [LTools createLabelFrame:CGRectMake(CGRectGetMaxX(priceLabel.frame)+2, 0, aWidth, ACHORVIEW_HEIGHT) title:title font:12.f align:NSTextAlignmentLeft textColor:[UIColor whiteColor]];
            [_imageView addSubview:_titleLabel];
            
            
            //标记位置view
            
            self.annimationView = [[UIView alloc]initWithFrame:CGRectMake(_imageView.right + 5, (ACHORVIEW_HEIGHT - 5) /2.f, 7, 7)];
            self.annimationView.backgroundColor = [UIColor whiteColor];
            self.annimationView.layer.cornerRadius = 3.5f;
            self.annimationView.clipsToBounds = YES;
            [self addSubview:_annimationView];
            
            self.halo = [PulsingHaloLayer layer];
            self.halo.position = self.annimationView.center;
            self.halo.animationDuration = 1.f;
            self.halo.radius = 10.f;
            self.halo.backgroundColor = [UIColor blackColor].CGColor;
            [self.layer insertSublayer:self.halo below:self.annimationView.layer];
            
            [self setTheLeftLocationAndFrame];

        }
        
        //判端右侧边界情况
        
        if (self.right > DEVICE_WIDTH - 10) {
            
            CGFloat dis = self.right - (DEVICE_WIDTH - 10);
            self.width -= dis;
            _titleLabel.width -= dis;
            _imageView.width -= dis;
        }
        
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clickButton.frame = self.bounds;
        clickButton.backgroundColor = [UIColor clearColor];
        [clickButton addTarget:self action:@selector(clickToDo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickButton];
        
        
        
        
        
    }
    return self;
}


//设置右边 在init方法里使用
-(void)setTheRightLocationAndFrame{
    
    
    
    CGRect r = self.frame;
    r.origin.x = self.frame.origin.x - 2;
    r.origin.y = self.frame.origin.y - ACHORVIEW_HEIGHT*0.5;
    r.size.width = self.annimationView.frame.size.width + 5 + self.imageView.frame.size.width;
    self.frame = r;
    
    self.location_x = self.frame.origin.x;
    self.location_y = self.frame.origin.y + ACHORVIEW_HEIGHT * 0.5;
//    NSLog(@"right 初始化的locationx = %f locationy = %f",self.location_x,self.location_y);
    
}


//设置左边 在init方法里使用
-(void)setTheLeftLocationAndFrame{
    
    
    CGRect r = self.frame;
    r.origin.x = self.frame.origin.x - self.imageView.frame.size.width - 5 - self.annimationView.frame.size.width;
    r.origin.y = self.frame.origin.y - ACHORVIEW_HEIGHT * 0.5;
    r.size.width = self.annimationView.frame.size.width + 5 + self.imageView.frame.size.width;
    
    self.location_x = r.origin.x + ACHORVIEW_HEIGHT *0.5 + r.size.width - 2;
    self.location_y = r.origin.y + ACHORVIEW_HEIGHT*0.5;
    
//    NSLog(@"left 初始化的locationx = %f locationy = %f",self.location_x,self.location_y);
    
    self.frame = r;
}



-(instancetype)initWithAnchorPoint:(CGPoint)anchorPoint
                             title:(NSString *)title
                    superViewWidth:(CGFloat)superViewWidth
{
    self = [super initWithFrame:CGRectMake(anchorPoint.x, anchorPoint.y, 0, ACHORVIEW_HEIGHT)];
    if (self) {
        
                self.backgroundColor = [UIColor orangeColor];
        
        BOOL isRight  = YES;
        
        //满足此条件则放左侧
        if (anchorPoint.x > superViewWidth - 50) {
            
            isRight = NO;
        }
        
        if (isRight) {
            
            //标记位置view
            
            self.annimationView = [[UIView alloc]initWithFrame:CGRectMake(0, (ACHORVIEW_HEIGHT - 5) /2.f, 7, 7)];
            self.annimationView.backgroundColor = [UIColor whiteColor];
            self.annimationView.layer.cornerRadius = 3.5f;
            self.annimationView.clipsToBounds = YES;
            [self addSubview:_annimationView];
            
            self.halo = [PulsingHaloLayer layer];
            self.halo.position = self.annimationView.center;
            self.halo.animationDuration = 1.f;
            self.halo.radius = 10.f;
            self.halo.backgroundColor = [UIColor blackColor].CGColor;
            [self.layer insertSublayer:self.halo below:self.annimationView.layer];
            
            
            //文字宽度
            
            CGFloat aWidth = [LTools widthForText:title font:12.f];
            
            CGFloat aWidth_imageView = aWidth + 7 * 2;//左侧 右侧 7
            
            //箭头imageView
            
            CGFloat left = _annimationView.right + 5;
            
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, aWidth_imageView, ACHORVIEW_HEIGHT)];
            UIImage *image = [UIImage imageNamed:@"jiantou_anchor_right"];
            _imageView.image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:ACHORVIEW_HEIGHT];
            [self addSubview:_imageView];
            
            //文字显示label
            
            self.titleLabel = [LTools createLabelFrame:CGRectMake(10, 0, aWidth, ACHORVIEW_HEIGHT) title:title font:12.f align:NSTextAlignmentLeft textColor:[UIColor whiteColor]];
            [_imageView addSubview:_titleLabel];
            
        }else
        {
            //文字宽度
            
            CGFloat aWidth = [LTools widthForText:title font:12.f];
            
            CGFloat aWidth_imageView = aWidth + 7 * 2;//左侧 右侧 7
            
            //箭头imageView
            
            CGFloat left = 0;
            
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, aWidth_imageView, ACHORVIEW_HEIGHT)];
            UIImage *image = [UIImage imageNamed:@"jiantou_anchor_left"];
            _imageView.image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:ACHORVIEW_HEIGHT];
            [self addSubview:_imageView];
            
            //文字显示label
            
            self.titleLabel = [LTools createLabelFrame:CGRectMake(5, 0, aWidth, ACHORVIEW_HEIGHT) title:title font:12.f align:NSTextAlignmentLeft textColor:[UIColor whiteColor]];
            [_imageView addSubview:_titleLabel];
            
            
            //标记位置view
            
            self.annimationView = [[UIView alloc]initWithFrame:CGRectMake(_imageView.right + 5, (ACHORVIEW_HEIGHT - 5) /2.f, 7, 7)];
            self.annimationView.backgroundColor = [UIColor whiteColor];
            self.annimationView.layer.cornerRadius = 3.5f;
            self.annimationView.clipsToBounds = YES;
            [self addSubview:_annimationView];
            
            self.halo = [PulsingHaloLayer layer];
            self.halo.position = self.annimationView.center;
            self.halo.animationDuration = 1.f;
            self.halo.radius = 10.f;
            self.halo.backgroundColor = [UIColor blackColor].CGColor;
            [self.layer insertSublayer:self.halo below:self.annimationView.layer];
            
            self.left = anchorPoint.x - _imageView.width - 5 - _annimationView.width;
            
        }
        
        self.width = _imageView.width + 5 + _annimationView.width;
        
        //        self.height += 50;
        
        
        //判端右侧边界情况
        
        if (self.right > superViewWidth - 10) {
            
            CGFloat dis = self.right - (superViewWidth - 10);
            self.width -= dis;
            _titleLabel.width -= dis;
            _imageView.width -= dis;
        }
        
        
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clickButton.frame = self.bounds;
        clickButton.backgroundColor = [UIColor clearColor];
        [clickButton addTarget:self action:@selector(clickToDo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickButton];
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"----->began");
}

- (void)setAnchorBlock:(AnchorClickBlock)anchorBlock
{
    _anchorClickBlock = anchorBlock;
}

-(void)clickToDo:(UIButton *)sender
{
    NSLog(@"----->end");

    if (_anchorClickBlock) {
        
        _anchorClickBlock(_infoId,_infoName,_shopType);
    }
}

@end
