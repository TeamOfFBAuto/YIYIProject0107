//
//  ApiHeader.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/11.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#ifndef YiYiProject_ApiHeader_h
#define YiYiProject_ApiHeader_h

//颜色相关
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

//屏幕尺寸相关
#define ALL_FRAME [UIScreen mainScreen].applicationFrame
//宽
#define ALL_FRAME_WIDTH ALL_FRAME.size.width
//高
#define ALL_FRAME_HEIGHT ALL_FRAME.size.height

//版本判断相关
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

//int 转 string

#define NSStringFromFloat(float) [NSString stringWithFormat:@"%f",(float)]
#define NSStringFromInt(int) [NSString stringWithFormat:@"%d",(int)]

//常用变量

//根视图
#define ROOTVIEWCONTROLLER (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController

//数据更新状态

#define UPDATE_PARAM @"updateParam" //要更新的参数
#define UPDATE_TPLAT_ISLIKE @"tPlatIsLike" //是否喜欢标识
#define UPDATE_TPLAT_LIKENUM @"likeNum" //喜欢个数
#define UPDATE_TPLAT_COMENTNUM @"commentNum" //评论个数


//保存用户信息设备信息相关

#define USER_INFO @"userInfo"//用户信息
#define USER_FACE @"userface"
#define USER_NAME @"username"
#define USER_PWD @"userPw"
#define USER_UID @"useruid"

#define USERINFO_MODEL @"USERINFO_MODEL" //存储在本地用户model
#define USERINFO_DIC @"USERINFO_DIC"//存储在本地用户dic

#define CHOUJIANG_MODEL @"CHOUJIANG_MODEL" //存储在本地抽奖model

//两个登陆标识
#define LOGIN_SERVER_STATE @"user_login_state" //登陆衣加衣服务器 no是未登陆  yes是已登陆
#define LOGIN_RONGCLOUD_STATE @"rongcloudLoginState"//融云登陆状态

#define USER_AUTHOD @"user_authod"
#define USER_CHECKUSER @"checkfbuser"
#define USER_HEAD_IMAGEURL @"userHeadImageUrl"//头像url

#define USER_SHOP_ID @"shop_id"//店铺id

#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_DEVICE_TOKEN @"DEVICE_TOKEN"

#define USER_UNREADNUM @"unreadNum"//未读消息条数

#define RONGCLOUD_TOKEN @"rongCloudToken"//融云对应的token

#define USER_CHOUJIANG_BIG @"chouJiang_big"//标识抽奖大图是否显示过

//本地数据保存

#define CACHE_DESERVE_BUY @"deserveBuy"//值得买
#define CACHE_TPLAT @"tPlat"//t台
#define CACHE_THELOCATION @"CACHE_THELOCATION"//定位信息

//位置记录标识
#define USER_LOCATION_LAT @"lat" //维度
#define USER_LOCATION_LONG @"long" //经度
#define USER_LOCATION_ADDRESS_DETAIL @"addressDetail"//当前的地址详情
#define USER_LOCATION_PROVINCE @"province" //当前所在省份
#define USER_LOCATION_CITY @"city" //当前所在城市
#define USER_LOCATION_STATE @"locationState"//定位是否成功

//错误提示信息 

#define ALERT_ERRO_PHONE @"请输入有效手机号"
#define ALERT_ERRO_PASSWORD @"密码格式有误,请输入6~15位英文字母或数字"
#define ALERT_ERRO_SECURITYCODE @"验证码格式有误,请输入6位数字"
#define ALERT_ERRO_FINDPWD @"两次密码不一致"

#define L_PAGE_SIZE 20

//通知 信息相关

#define NOTIFICATION_LOGIN @"loginin_success" //登录成功通知
#define NOTIFICATION_LOGOUT @"logout_success" //退出登录通知

#define NOTIFICATION_TTAI_PUBLISE_SUCCESS @"TTAI_PUBLISE_SUCCESS"//t台发布成功
#define NOTIFICATION_TTAI_EDIT_SUCCESS @"TTAI_EDIT_SUCCESS"//T台编辑成功

#define NOTIFICATION_SHENQINGDIANPU_SUCCESS @"GSHENQINGDIANPU_SUCCESS"//申请店铺成功

#define NOTIFICATION_SHENQINGDIANPU_STATE @"GSHENQINGDIANPU_STATE"//申请店铺成功状态 成功或者失败

#define NOTIFICATION_APPENTERFOREGROUND @"notification_appEnterForeground" //应用从后台转向前台

#define NOTIFICATION_EDIT_SHOP_PHONE_SUCCESS @"NOTIFICATION_EDIT_SHOP_PHONE_SUCCESS"//编辑店铺电话成功

#define NOTIFICATION_GETCHOUJIANGSTATE @"NOTIFICATION_GETCHOUJIANGSTATE"//获取是否抽奖状态

#define NOTIFICATION_MINEVC_THREENUMLABEL @"NOTIFICATION_MINEVC_THREENUMLABEL"//我的界面上方三个数字lable

#define NOTIFICATION_USER_EDITPHONENUM_SUCCESS @"NOTIFICATION_USER_EDITPHONENUM"//绑定手机号成功

#define NOTIFICATION_UPDATELOCATION_SUCCESS @"NOTIFICATION_UPLOADLOCATION_SUCCESS"//定位成功后通知

#define NOTIFICATION_TUIKUAN_SUCCESS @"NOTIFICATION_TUIKUAN_SUCCESS"//退款成功

//单品关注相关操作
#define NOTIFICATION_GUANZHU_PRODUCT @"guanzhu_product"
//T台关注相关操作
#define NOTIFICATION_GUANZHU_TTai @"guanzhu_ttai"

//刷新t台
#define NOTIFICATION_REFRESH_TTai @"refresh_ttai"

//关注商场
#define NOTIFICATION_GUANZHU_STORE @"guanzhu_store"
//取消关注商场
#define NOTIFICATION_GUANZHU_STORE_QUXIAO @"guanzhu_store_quxiao"
//关注品牌
#define NOTIFICATION_GUANZHU_PINPAI @"guanzhu_pinpai"
//取消关注品牌
#define NOTIFICATION_GUANZHU_PINPAI_QUXIAO @"guanzhu_pinpai_quxiao"
//发布单品成功
#define NOTIFICATION_FABUDANPIN_SUCCESS @"fabudanpin_success"
//发布活动成功
#define NOTIFICATION_FABUHUODONG_SUCCESS @"fabuhuodong_success"

//取消红点
#define NOTIFICATION_CANCEL_HOTPOINT @"cancelHotPoint"

//推送消息
#define NOTIFICATION_REMOTE_MESSAGE @"remoteMessage"

//修改单品完成
#define GEDITPRODUCT_SUCCESS @"GeditProduct_success"

//发布买衣日记完成
#define GUPBUYCLOTHES_SUCCESS @"GUPBUYCLOTHES_SUCCESS"

//更新赞数字
#define NOTIFICATION_UPDATE_ZANNUM @"updateZanNum"
//更新评论数字
#define NOTIFICATION_UPDATE_COMMENTNUM @"updateCommentNum"

//隐藏t台详情状态栏和导航栏
#define NOTIFICATION_TPLATDETAIL_HIDDEN @"TPlatDetailhiddenAction"

//显示t台详情状态栏和导航栏
#define NOTIFICATION_TPLATDETAIL_SHOW @"TPlatDetailShowAction"

//T台详情页close通知
#define NOTIFICATION_TPLATDETAILCLOSE @"TPlatDetailclose"


////////////购买支付相关通知////////////

#define NOTIFICATION_ADDADDRESS @"addAddress"//添加新地址
#define NOTIFICATION_UPDATE_TO_CART @"updateProductToCart"//更新购物车
#define NOTIFICATION_PAY_WEIXIN_RESULT @"weiXinPayResult" //微信支付结果成功或者失败
#define NOTIFICATION_PAY_ALI_RESULT @"aliPayResult" //支付宝支付结果成功或者失败
#define NOTIFICATION_PAY_SUCCESS @"pay_success" //支付成功通知
#define NOTIFICATION_BUY_AGAIN @"buy_again" //再次购买通知
#define NOTIFICATION_RECIEVE_CONFIRM @"recieve_confirm" //确认收货通知
#define NOTIFICATION_ORDER_CANCEL @"cancelOrder" //取消订单
#define NOTIFICATION_ORDER_DEL @"delOrder" //删除订单
#define NOTIFICATION_GO_TO_PAY @"goToPayOrder" //去支付订单
#define NOTIFICATION_COMMENTSUCCESS @"NOTIFICATION_COMMENTSUCCESS"//评价成功


//登录类型 normal为正常手机登陆，sweibo、qq、weixin分别代表新浪微博、qq、微信登陆
typedef enum{
    Login_Normal = 0,
    Login_Sweibo,
    Login_QQ,
    Login_Weixin
}Login_Type;

//性别
typedef enum{
    Gender_Girl = 1,
    Gender_Boy
}Gender;

//注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册
typedef enum{
    Register_Phone = 1,
    Register_Email
}Register_Type;

//验证码用途 1=》注册 2=》商店短信验证 3=》找回密码 4⇒申请成为搭配师获取验证码 默认为1) int
typedef enum{
    SecurityCode_Register = 1,
    SecurityCode_Shop,
    SecurityCode_FindPWD,
    SecurityCode_Match
}SecurityCode_Type;

typedef enum {
    
    Sort_Sex_No = 0,//0 不按照性别 默认为0
    Sort_Sex_Women,//女
    Sort_Sex_Man  //男
    
}SORT_SEX_TYPE; //排序方式

typedef enum {
    
    Sort_Discount_No = 0,// discount 折扣排序 1 是 0 否 默认为0
    Sort_Discount_Yes
    
}SORT_Discount_TYPE; //排序方式

/**
 *  商家消息列表
 */
//action= yy(衣加衣) shop（商家） dynamic（动态）

typedef enum{
    Message_List_Yy = 0,
    Message_List_Shop,
    Message_List_Dynamic
}Message_List_Type;


/**
 * 消息类型
 * 1 衣加衣通知消息 2 关注用户通知消息 3 回复主题消息 4 回复主题回复
 * 5 回复T台通知消息 6 回复T台回复通知消息 7 品牌促销通知消息 8 商场促销通知
 * 9 申请店铺成功  10 申请店铺失败
 * 11 修改活动
 * 12关注商家通知消息
 */
typedef enum {
    
    MessageType_yiyiTeam = 1,//衣衣团队消息 (衣加衣团队消息)
    
    MessageType_concernUser = 2,//关注用户消息(动态消息)
    MessageType_concernShop = 12,//关注商家通知消息(动态消息)
    
    MessageType_replyTopic = 3,//回复主题(动态消息)
    MessageType_replyTopicReply = 4,//回复主题的回复(动态消息)
    MessageType_replyTPlat = 5,//评论t台(动态消息)
    MessageType_replyTPlatReply = 6,//回复t台评论(动态消息)
    
    MessageType_promotionBrand = 7,//店铺促销(商家消息)
    MessageType_promotionMarket = 8,//商场促销(商家消息)
    MessageType_modifyActivity = 11,//店铺活动修改(商家消息)
    
    MessageType_applyShopSuccess = 9,//申请店铺成功(衣加衣团队消息)
    MessageType_applyShopFail = 10,//申请店铺失败(衣加衣团队消息)
    
    
}MessageType;


typedef enum {
    
    relation_concern_no = 0,//未关注
    relation_concern_yes = 1,//已关注对方
    relation_concern_yes_otherSide = 2,//被对方关注
    relation_concern_all = 3 //相互关注
    
}RelationConcernType;//关注关系



typedef enum {
    ShopType_null = 0,
    ShopType_jingpinDian = 2,//精品店
    ShopType_pinpaiDian = 3,//品牌店
    ShopType_mall = 1   //大商场
    
}ShopType;//店铺类型


typedef enum{
    Product_qita = 0,//其他
    Product_shangyi = 1,//上衣
    Product_kuzi = 2,//裤子
    Product_qunzi = 3,//裙子
    Product_neiyi = 4,//内衣
    Product_peishi = 5//配饰
}ProductType;


typedef enum {

    Action_like_yes = 0,//添加赞
    Action_like_no,//取消赞
    Action_Collect_yes,//添加收藏
    Action_Collect_no//取消收藏

}ACTION_TYPE; //网络请求类型

typedef enum {
    CELLSTYLE_DanPinList = 0, //单品列表样式 有店名、价格、折扣、距离,点赞在图片左下角
    CELLSTYLE_DianPuList = 1, //店铺列表样式 有店名、价格、折扣、不显示距离,点赞不在图片上,在价格等infoView上
    CELLSTYLE_CollectList = 2, //收藏 和 单品列表类似,只是没有店名
    CELLSTYLE_BrandRecommendList = 3 //品牌推荐 只有点赞、大图
}CELLSTYLE;

typedef enum{
    ORDERTYPE_DaiFu = 1, //待付款
    ORDERTYPE_DaiFaHuo,//待发货
    ORDERTYPE_PeiSong, //配送中
    ORDERTYPE_WanCheng, //完成
    ORDERTYPE_TuiHuan //退换
}ORDERTYPE;

//单品分类
#define PRODUCT_FENLEI  @[@"全部",@"上衣",@"裤子",@"裙子",@"内衣",@"配饰",@"其他"]

//接口地址

//融云 token

#define RONCLOUD_GET_TOKEN @"http://www119.alayy.com/index.php?d=api&c=chat&m=get_token&user_id=%@&name=%@&portrait_uri=%@"//获取融云 token

//登录
#define USER_LOGIN_ACTION @"http://www119.alayy.com/index.php?d=api&c=user_api&m=login&type=%@&password=%@&thirdid=%@&nickname=%@&third_photo=%@&gender=%d&devicetoken=%@&mobile=%@&login_source=%@"

//退出登录

#define USER_LOGOUT_ACTION @"http://www119.alayy.com/index.php?d=api&c=user_api&m=login_out&authcode=%@"

//注册

#define USER_REGISTER_ACTION @"http://www119.alayy.com/index.php?d=api&c=user_api&m=register&username=%@&password=%@&gender=%d&type=%d&code=%d&mobile=%@&reg_source=%@"

//获取验证码
#define USER_GET_SECURITY_CODE @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_code&mobile=%@&type=%d&encryptcode=%@"
//找回密码
#define USER_GETBACK_PASSWORD @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_back_password&mobile=%@&code=%d&new_password=%@&confirm_password=%@"

//首页--值得买
#define HOME_DESERVE_BUY @"http://www119.alayy.com/?d=api&c=products&m=listWorthBuy&long=%@&lat=%@&sex=%d&discount=%d&page=%d&count=%d&authcode=%@"


//首页--衣加衣
//获取顶部scrollview图片
#define HOME_CLOTH_TOPSCROLLVIEW @"http://www119.alayy.com/index.php?d=api&c=advertisement&m=get_advertisement"
//获取附近品牌
#define HOME_CLOTH_NEARBYPINPAI @"http://www119.alayy.com/index.php?d=api&c=brand&m=get_nearby_brands"
//获取附近商铺
#define HOME_CLOTH_NEARBYSTORE @"http://www119.alayy.com/index.php?d=api&c=mall&m=getNearMalls"
//获取我关注的店铺
#define HOME_CLOTH_GUANZHUSTORE_MINE @"http://www119.alayy.com/?d=api&c=friendship&m=listMall"
//获取我关注的品牌
#define HOME_CLOTH_GUANZHUPINPAI_MINE @"http://www119.alayy.com/index.php?d=api&c=brand&m=get_attend_brands&authcode=%@&page=%d&lat=%@&long=%@"

//店铺详情  mall_id  精品店
#define HOME_CLOTH_NEARBYSTORE_DETAIL @"http://www119.alayy.com?d=api&c=mall&m=getMallDetail"
//店铺详情 shop_id   品牌店
#define GET_MAIL_DETAIL_INFO @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_shop_info"

//点击品牌进入该品牌的商铺列表
#define HOME_CLOTH_PINPAI_STORELIST @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_mall_by_brand"
//某商场某一品牌下的单品列表
#define HOME_CLOTH_STORE_PINPAILIST @"http://www119.alayy.com/index.php?d=api&c=products&m=getProductList"



//T台列表首页附近的活动列表
#define HOME_TTAI_ACTIVITY @"http://www119.alayy.com/index.php?d=api&c=activity&m=get_near_activity_list"
//T台列表首页顶部滚动视图
#define HOME_TTAI_TOPSCROLLVIEW @"http://www119.alayy.com/index.php?d=api&c=advertisement&m=get_advertisement"
//T台列表
#define HOME_TTAI_LIST @"http://www119.alayy.com/index.php?d=api&c=tplat_v2&m=get_near_tts"


//单品详情

#define HOME_PRODUCT_DETAIL @"http://www119.alayy.com/index.php?d=api&c=products&m=getProductInfo&product_id=%@&authcode=%@"

//单品 - 添加赞
#define HOME_PRODUCT_ZAN_ADD @"http://www119.alayy.com/?d=api&c=products&m=like"

//单品 - 取消赞
#define HOME_PRODUCT_ZAN_Cancel @"http://www119.alayy.com/?d=api&c=products&m=cancelLike"

//单品 - 添加收藏
#define HOME_PRODUCT_COLLECT_ADD @"http://www119.alayy.com/?d=api&c=products&m=favor"

//单品 - 取消收藏
#define HOME_PRODUCT_COLLECT_Cancel @"http://www119.alayy.com/?d=api&c=products&m=cancelFavor&product_id=%@"


//T 台

#define TTAi_LIST @"http://www119.alayy.com/?d=api&c=tplat&m=listT"

//添加T台
#define TTAI_ADD @"http://www119.alayy.com/?d=api&c=tplat&m=addTplat"


//T台详情
#define TTAI_DETAIL @"http://www119.alayy.com/?d=api&c=tplat&m=ttinfo&tt_id=%@&authcode=%@"
#define TTAI_DETAIL_V2 @"http://www119.alayy.com/index.php?d=api&c=tplat_v2&m=get_tt_info"

//T台详情点击标签跳转同标签T台瀑布流
#define TTAI_SAMETAG @"http://www119.alayy.com/index.php?d=api&c=tplat_v2&m=get_tts_by_tag"

//T台相关商场
#define TTAI_STORE @"http://www119.alayy.com/index.php?d=api&c=tplat_v2&m=get_relation_tts"


///t台评论接口
#define TTAI_COMMENTS_URL @"http://www119.alayy.com/?d=api&c=tplat&m=listReply&page=%d&count=20&tt_id=%@"
//T台评论

#define TTAI_COMMENT @"http://www119.alayy.com/?d=api&c=tplat&m=comment"

//T台点赞

#define TTAI_ZAN @"http://www119.alayy.com/?d=api&c=tplat&m=like"

//T台取消赞
#define TTAI_ZAN_CANCEL @"http://www119.alayy.com/?d=api&c=tplat&m=cancelLike"

//转发 + 1
#define TTAI_ZHUANFA_ADD @"http://www119.alayy.com/?d=api&c=tplat&m=incrShare"


//T台收藏

#define TTAI_COLLECT_LIST @"http://www119.alayy.com/index.php?d=api&c=tplat&m=get_favor_list&page=%d&per_page=%d&authcode=%@&uid=%@"

//2.添加收藏
#define TTAI_COLLECT_ADD @"http://www119.alayy.com/index.php?d=api&c=tplat&m=add_favor_tt&tt_id=%@&authcode=%@"

//3.取消收藏
#define TTAI_COLLECT_CANCEL @"http://www119.alayy.com/index.php?d=api&c=tplat&m=cancel_favor_tt&tt_id=%@&authcode=%@"

#define TTAI_COLLECT_ADD1 @"http://www119.alayy.com/index.php?d=api&c=tplat&m=add_favor_tt"
#define TTAI_COLLECT_CANCEL1 @"http://www119.alayy.com/index.php?d=api&c=tplat&m=cancel_favor_tt"

//个人信息相关
#define PERSON_CHANGEUSERBANNER @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_banner"

//加额外参数extra  extra=tt_num时代表需要返回t台总数
#define PERSON_GETUSERINFO @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_user_info"

#define PERSON_CHANGEUSERFACE @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_info"


//根据id获取用户信息
#define GET_PERSONINFO_WITHID @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_user_by_uid&uid=%@"

//关注商场或精品店
#define GUANZHUSHANGCHANG @"http://www119.alayy.com/?d=api&c=friendship&m=mallShipCreate"
//取消关注商场
#define QUXIAOGUANZHU_SHANGCHANG @"http://www119.alayy.com/?d=api&c=friendship&m=mallDestory"

//关注品牌
#define GUANZHUPINPAI @"http://www119.alayy.com/index.php?d=api&c=brand&m=attend_brand"
//取消关注品牌
#define QUXIAOGUANZHUPINPAI @"http://www119.alayy.com/index.php?d=api&c=brand&m=cancel_attend_brand"
//查询品牌是否关注
#define GUANZHUPINPAI_ISORNO @"http://www119.alayy.com/index.php?d=api&c=brand&m=isBrandFriend"


#define ZPOSTDEVICETOKEN @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_info"


//申请店铺界面 
//根据省市区获取商城列表
#define STORELISTWITHPROVINCEANDCITY @"http://www119.alayy.com/api/mall/listMall?province_id=%@&city_id=%@"
//某商场所有楼层的品牌列表
#define STOREALLFLOORPINPAI @"http://www119.alayy.com/?d=api&c=mall&m=listBrandFromMall&mall_id=%@"

//申请店铺
#define SHENQINGJINGPINDIAN @"http://www119.alayy.com/?d=api&c=mall&m=addMall"
//申请商场店
#define SHENQINGSHANGCHANGDIAN @"http://www119.alayy.com/?d=api&c=mall&m=addShop"

//我是店主 发布单品
#define GFABUDIANPIN @"http://www119.alayy.com/?d=api&c=products&m=addProducts"
//编辑单品
//#define GEDITPRODUCT_MANAGE @"http://www119.alayy.com/index.php?d=api&c=products&m=edit_product"
#define GEDITPRODUCT_MANAGE @"http://www119.alayy.com/index.php?d=api&c=products&m=edit_product_v2"

//我是店主 发布活动
#define ACTIVITY_PUBLIST @"http://www119.alayy.com/index.php?d=api&c=mall&m=publish_activity"
//修改活动
#define ACTIVITY_EDIT @"http://www119.alayy.com/index.php?d=api&c=mall&m=edit_activity"



#pragma mark - 搭配师相关接口 ******************************add by sn
/*
 action(该参数有两个值，等于my时表示获取我的搭配师，当popu时表示获取人气搭配师，默认为my)
 authcode(uid加密串，当action参数为my时需要该参数，不是my时不用传)
 tagid(搭配师标签的id，当action参数为popu时并需要做筛选时需要该参数，不是popu时不用传 ，当不做筛选时刻不传该参数或者传0)
 page(页数 默认1)
 perpage(每页显示数量 默认10)
 */
#define GET_DAPEISHI_URL @"http://www119.alayy.com/index.php?d=api&c=division_t&m=get_division_teachers&action=%@&authcode=%@&tagid=%d&page=%d&perpage=%d"
///搭配师界面获取话题接口
#define GET_TOPIC_DATA_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=get_topics&uid=%@&page=%d&per_page=%d"
///搭配师界面获取搭配师搭配接口
/*
 t_uid（搭配师uid，若传该参数表示获取该搭配师的搭配列表，若不传则返回所有搭配师的搭配列表）
 page(页数 默认1)
 per_page(每页显示数量 默认10)
 */
#define GET_MATCH_DATA_URL @"http://www119.alayy.com/index.php?d=api&c=division_t&m=get_division_tts&t_uid=%@&page=%d&per_page=%d"

///申请搭配师
/*
 authcode(uid加密串) string
 mobile（手机号码）string
 code(验证码) int
 qq(qq号码) int
 weixin(微信号码，可不填) int
 pic(身份证照片) string
 */
#define APPLY_MATCH_URL @"http://www119.alayy.com/index.php?d=api&c=division_t&m=apply_division_teacher"

///话题详情接口
#define GET_TOPIC_DETAIL_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=get_topic_info&topic_id=%@&authcode=%@"
///获取话题评论接口
#define GET_TOPIC_COMMENTS_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=get_replies&topic_id=%@&page=%d&per_page=20"
///获取搭配师个人信息
#define GET_MATCH_INFOMATION_URL @"http://www119.alayy.com/index.php?d=api&c=division_t&m=get_division_t_info&t_uid=%@&authcode=%@"
///话题点赞接口
#define TOPIC_ADDFAV_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=like_topic&authcode=%@&topic_id=%@"
///话题取消赞接口
#define TOPIC_DELFAV_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=cancel_like&topic_id=%@&authcode=%@"

///话题评论接口
/*
 参数解释依次为:
 authcode（uid加密串）
 topic_id(话题id)
 repost_content(回复内容)
 level（回复的评论是主评论还是子评论，1=》主评论 2=》子评论） parent_post(回复的主评论id，若level=1则值为0)
 r_reply_id(回复的回复id，当为二级评论的时候需要该参数，若level=1则值为0)
 */
#define TOPIC_COMMENTS_URL @"http://www119.alayy.com/index.php?d=api&c=topic&m=reply_topic"

///关注取消关注接口
/*
 参数解释依次为:
 authcode(uid的加密串) string
 action(取消还是关注 at_friend⇒关注某人 can_friend⇒取消关注某人) str
 friend_uid(操作的对象uid) int
 */
#define ATTENTTION_SOMEBODY_URL @"http://www119.alayy.com/index.php?d=api&c=my_api&m=attention&authcode=%@&action=%@&friend_uid=%@"

#pragma mark - 搭配师相关接口 ******************************add by sn

#pragma mark--我的衣橱接口

#define GET_MY_CILLECTION @"http://www119.alayy.com/?d=api&c=products&m=listFavors&long=%@&lat=%@&page=%d&count=%d&authcode=%@&uid=%@"//我的收藏（只有单品）


#pragma mark--我的衣橱接口


#define GET_MYYICHU_LIST_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=get_wardrobe&authcode=%@"

#define UPLOAD_IMAGE_URL @"http://www119.alayy.com/index.php?d=api&c=upload&m=upload_pic"//action(等于topic_pic为上传话题图片，等于ttinfo为上传T台图片, action=activity上传活动图片)

//添加分类
#define GET_ADDCLASSICATION_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=add_sort&sort_name=%@&authcode=%@"
//删除分类
#define GET_DELETECLASSICATION_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=del_sort&sort_id=%@&authcode=%@"

//编辑分类
#define GET_EDITCLASSICATION_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=update_sort&sort_id=%@&sort_name=%@&authcode=%@"
//获取分类
#define GET_GETCLASSTCATION_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=get_sort&authcode=%@"
//衣橱里面添加衣服
#define POST_ADDCLOTHES_URL     @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=add_clothes"
//获取某个分类下的衣服
#define GET_CLASSICATIONCLOTHES_URL @"http://www119.alayy.com/index.php?d=api&c=wardrobe&m=get_clothes&sort_id=%@&authcode=%@"

#define MY_CONCERN_BRAND @"http://www119.alayy.com/index.php?d=api&c=brand&m=get_attend_brands&authcode=%@&page=%d&uid=%@"//我关注品牌
#define MY_CONCERN_BRAND_CANCEL @"http://www119.alayy.com/index.php?d=api&c=brand&m=cancel_attend_brand"//取消品牌关注

#define MY_CONCERN_SHOP @"http://www119.alayy.com/?d=api&c=friendship&m=listMall&authcode=%@&page=%d&count=%d&uid=%@&lat=%@&long=%@"//我关注商家

#define MY_CONCERN_MAIL_CANCEL @"http://www119.alayy.com/?d=api&c=friendship&m=mallDestory"//取消关注商家

#define POST_EDITMYBODY_URL @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_body_info"//修改我的体型

#define GET_GETMYBODY_URL @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_user_body_info&authcode=%@"//获取我的体型信息

#define GET_GETMYSTYLE_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=get_my_styles&authcode=%@"//获取我的搭配风格

#define GET_ADDSTYLE_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=add_style&style_pid=%@&style_name=%@&authcode=%@"//添加搭配风格

#define GET_EDITSTYLENAME_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=update_style&style_id=%@&style_name=%@&authcode=%@"//修改搭配风格名字

#define GET_DELETESTYLENAME_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=del_style&style_id=%@&authcode=%@"//删除搭配风格

#define POST_ADDDAPEISTYLE_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=add_division"//添加我的搭配
#define GET_DIVISION_INFO @"http://www119.alayy.com/index.php?d=api&c=division&m=get_division_info&division_id=%@&authcode=%@"

#define GET_DIVISOINBYSTYLE_URL @"http://www119.alayy.com/index.php?d=api&c=division&m=get_divisions_by_style&style_id=%@&authcode=%@"
#define POST_MYBODY_URL @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_body_info"//修改我的体型


#pragma - mark 搭配师话题

#define TOPIC_ADD @"http://www119.alayy.com/index.php?d=api&c=topic&m=publish_topic"//添加话题


#pragma mark-----设置
#define	APP_RATING_URL	 @"itms-apps://itunes.apple.com/app/id951259287"

#pragma mark-------------编辑个人资料

#define POST_UPDATEMYINFO_URL @"http://www119.alayy.com/index.php?d=api&c=user_api&m=update_user_info"  //修改个人资料

#pragma mark - 消息

#define MESSAGE_GET_MINE @"http://www119.alayy.com/index.php?d=api&c=msg&m=get_my_msg&authcode=%@"//我的消息

#define MESSAGE_GET_LIST @"http://www119.alayy.com/index.php?d=api&c=msg&m=get_special_msg&action=%@&authcode=%@"//action= yy(衣加衣) shop（商家） dynamic（动态）

#define MESSAGE_GET_DETAIL @"http://www119.alayy.com/index.php?d=api&c=msg&m=get_msg_info&msg_id=%@&authcode=%@"

//店主活动列表


#define GET_MAIL_ACTIVITY_LIST @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_activities&authcode=%@&page=%d&per_page=%d"

//店主单品列表
#define GET_MAIL_PRODUCT_LIST @"http://www119.alayy.com/index.php?d=api&c=products&m=getProductList&mb_id=%@&page=%d&per_page=%d&authcode=%@"


//活动详情
#define GET_MAIL_ACTIVITY_DETAIL @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_activity_info&activity_id=%@"

//发起活动
#define GADD_MAIL_ACTIVITY @"http://www119.alayy.com/index.php?d=api&c=mall&m=publish_activity"


//上架下架单品  参数：authcode  单品id字符串逗号隔开：product_ids   上架或下架action down/up
#define GUPDOWNPRODUCTS @"http://www119.alayy.com/index.php?d=api&c=products&m=product_shelf"

//删除单品  参数：authcode  单品id字符串逗号隔开：product_ids
#define GDELETPRODUCTS @"http://www119.alayy.com/index.php?d=api&c=products&m=del_product"

//搜索接口 品牌 商铺 单品
#define GSEARCH @"http://www119.alayy.com/index.php?d=api&c=search"

//签到
#define GQIANDAO @"http://www119.alayy.com/index.php?d=api&c=user_api&m=sign"

//获取店铺二维码
#define GMYSHOPERWEIMA @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_qrcode_v2"

//获取店铺会员 也就是关注该店铺的人
#define GMYSHOPHUIYUANLIST @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_attention_list"

//修改店铺联系方式 telephone

#define GCHANGESHOPTELEPHONE @"http://www119.alayy.com/index.php?d=api&c=mall&m=set_shop_phone"

//绑定手机
#define GBANGDINGPHONE @"http://www119.alayy.com/index.php?d=api&c=user_api&m=bind_mobile"

//关注品牌店
#define GGUANZHUPINPAIDIAN @"http://www119.alayy.com/index.php?d=api&c=friendship&m=attend_shop"

//取消关注品牌店
#define GQUXIAOGUANZHUPINPAIDIAN @"http://www119.alayy.com/index.php?d=api&c=friendship&m=cancel_attend_shop"


#pragma - mark T台相关接口

//获取赞的列表(relation 是关注关系 0代表未关注  1代表已关注 3代表以互相关注)

#define TPLat_ZanList @"http://www119.alayy.com/index.php?d=api&c=tplat&m=get_like_user&tt_id=%@"

//关注/取消关注某用户

//关注某用户 &friend_uid=%@&authcode=%@
#define USER_CONCERN_ADD @"http://www119.alayy.com/index.php?d=api&c=my_api&m=attention&action=at_friend"

//取消关注某用户 &friend_uid=%@&authcode=%@
#define USER_CONCERN_CANCEL @"http://www119.alayy.com/index.php?d=api&c=my_api&m=attention&action=can_friend"

//d=api&c=my_api&m=get_friend_list&action=get_my_attend&friend_uid=21&authcode=VCsAeVsiBeMAuwyRArIM21P2UbMH8lKjUXwGNwdiUWcBMFBhVzUCNgQzVmNSNAx8BTFXaQ==

//action=get_fans 获取粉丝
#define USER_FANS_LIST @"http://www119.alayy.com/index.php?d=api&c=my_api&m=get_friend_list&action=get_fans"

//action=get_my_attend 获取我关注的
#define USER_CONCERN_LIST @"http://www119.alayy.com/index.php?d=api&c=my_api&m=get_friend_list&action=get_my_attend"

//action=get_friends 获取好友
#define USER_FRIENDS_LIST @"http://www119.alayy.com/index.php?d=api&c=my_api&m=get_friend_list&action=get_friends"


//统计功能
//店铺浏览量加1
#define LIULAN_NUM_SHOP @"http://www119.alayy.com/index.php?d=api&c=statistic&m=add_shop_view"
//商场浏览量+1
#define LIULAN_NUM_STORE @"http://www119.alayy.com/index.php?d=api&c=statistic&m=add_mall_view"
//单品浏览量+1
#define LIULAN_NUM_PRODUCT @"http://www119.alayy.com/index.php?d=api&c=statistic&m=add_product_view"

//店铺访客
#define FANGKE_MYSHOP @"http://www119.alayy.com/index.php?d=api&c=mall&m=get_track_to_shop"

//删除T台
#define DELETE_TTAI @"http://www119.alayy.com/index.php?d=api&c=tplat&m=del_tt"

//编辑T台
#define EDIT_TTAI @"http://www119.alayy.com/index.php?d=api&c=tplat&m=edit_tt"

//分享地址

//T台详情wap
#define SHARE_TPLAT_DETAIL @"http://www119.alayy.com/index.php?d=wap&c=tplat&m=getttinfo&tt_id=%@"

//单品产品详情
#define SHARE_PRODUCT_DETAIL @"http://www119.alayy.com/index.php?d=wap&c=products&m=getProductInfo&product_id=%@"

//我的买衣日志列表
#define MYCLOTHESLOG_LIST @"http://www119.alayy.com/index.php?d=api&c=buylog&m=get_list"

//我的买衣日志上传
#define MYCLOTHESLOG_UPLOAD @"http://www119.alayy.com/index.php?d=api&c=buylog&m=add"

//抽奖相关接口

//获取是否显示取抽奖入口

#define GET_CHOUJIANGSTATE @"http://www119.alayy.com/index.php?d=api&c=prize&m=get_curr&authcode=%@"

//我的奖券列表
#define MYJIANGQUAN_LIST @"http://www119.alayy.com/index.php?d=api&c=prize&m=get_join_list"
//我的奖券
#define MYJIANGQUAN_ONE @"http://www119.alayy.com/index.php?d=api&c=prize&m=get_join_info"

//我的优惠券
#define MYYOUHUIQUAN_LIST @"http://www119.alayy.com/index.php?d=api&c=order&m=my_coupon_list"

//根据T台id 获取关联店铺优惠券
#define GETYOUHUIQUAN_RELATIONSHOP @"http://www119.alayy.com/index.php?d=api&c=order&m=tt_coupon_list"


//删除买衣日志
#define DELETE_BUYCLOTHESLOG @"http://www119.alayy.com/index.php?d=api&c=buylog&m=del"

//抽奖相关接口

//获取是否显示取抽奖入口

#define GET_CHOUJIANGSTATE @"http://www119.alayy.com/index.php?d=api&c=prize&m=get_curr&authcode=%@"


///////////////-新版本0812-////////////////

//同款单品列表
#define HOME_PRODUCT_DETAIL_SAME_STYLE @"http://www119.alayy.com/index.php?d=api&c=products&m=get_same_style_products&long=%f&lat=%f&product_id=%@"
//根据标签获取单品列表
#define PRODUCT_LIST_FORTAG @"http://www119.alayy.com/index.php?d=api&c=products&m=get_near_product_by_tag&long=%@&lat=%@&tag_id=%@&page=%d&per_page=%d&authcode=%@"
//品牌推荐
#define PRODUCT_LIST_SAME_BRAND_RECOMMENT @"http://www119.alayy.com/index.php?d=api&c=products&m=get_same_brand_products&product_id=%@&page=%d&per_page=%d&authcode=%@"
//单品评论列表
#define PRODUCT_COMMENT_LIST @"http://www119.alayy.com/index.php?d=api&c=products&m=listReply&product_id=%@"
//单品添加评论
#define PRODUCT_COMMENT_ADD @"http://www119.alayy.com/index.php?d=api&c=products&m=comment"
//单品赞列表
#define PRODUCT_ZAN_LIST @"http://www119.alayy.com/index.php?d=api&c=products&m=get_like_user&product_id=%@"

//衣加衣支付版本部分接口

//=================================================================================

//收货地址相关接口==================

//获取用户的收货地址列表
#define USER_ADDRESS_LIST @"http://www119.alayy.com/index.php?d=api&c=user_api&m=get_user_address"

//添加用户的收货地址 POST
#define USER_ADDRESS_ADD @"http://www119.alayy.com/index.php?d=api&c=user_api&m=add_user_address"

//编辑用户的收货地址 POST
#define USER_ADDRESS_EDIT @"http://www119.alayy.com/index.php?d=api&c=user_api&m=edit_user_address"

//设置默认地址 POST
#define USER_ADDRESS_SETDEFAULT @"http://www119.alayy.com/index.php?d=api&c=user_api&m=set_default_address"

//删除地址 POST
#define USER_ADDRESS_DELETE @"http://www119.alayy.com/index.php?d=api&c=user_api&m=del_user_address"

//订单相关接口=====================

//40、购物车添加商品
#define ORDER_ADD_TO_CART @"http://www119.alayy.com/index.php?d=api&c=order&m=add_to_cart"

//41、购物车增加/减少商品
#define ORDER_EDIT_CART_PRODUCT @"http://www119.alayy.com/index.php?d=api&c=order&m=edit_cart_product"

//42、删除某条购物车记录
#define ORDER_DEL_CART_PRODUCT @"http://www119.alayy.com/index.php?d=api&c=order&m=del_cart_product"

//43、获取购物车记录
#define ORDER_GET_CART_PRODCUTS @"http://www119.alayy.com/index.php?d=api&c=order&m=get_cart_products"

//44、用户登录后同步购物车数据
#define ORDER_SYNC_CART_INFO @"http://www119.alayy.com/index.php?d=api&c=order&m=sync_cart_info"

//47、提交订单,后台生成订单号
#define ORDER_SUBMIT @"http://www119.alayy.com/index.php?d=api&c=order&m=submit_order"

//45、获取用户默认地址及运费
#define ORDER_GET_DEFAULT_ADDRESS @"http://www119.alayy.com/index.php?d=api&c=order&m=get_default_address"

//46、获取运费

#define ORDER_GET_EXPRESS_FEE @"http://www119.alayy.com/index.php?d=api&c=order&m=get_express_fee"

//48、获取支付宝签名或者微信生成预订单
#define ORDER_GET_SIGN @"http://www119.alayy.com/index.php?d=api&c=order&m=get_sign"

//49、获取订单详情
#define ORDER_GET_ORDER_INFO @"http://www119.alayy.com/index.php?d=api&c=order&m=get_order_info"

//50、获取我的订单列表
#define ORDER_GET_MY_ORDERS @"http://www119.alayy.com/index.php?d=api&c=order&m=get_my_orders"

//51、查看订单支付状态
#define ORDER_GET_ORDER_PAY @"http://www119.alayy.com/index.php?d=api&c=order&m=get_order_pay"

//52、用户确认收货
#define ORDER_RECEIVING_CONFIRM @"http://www119.alayy.com/index.php?d=api&c=order&m=receiving_confirm"

//53、用户取消或删除订单
#define ORDER_HANDLE_ORDER @"http://www119.alayy.com/index.php?d=api&c=order&m=handle_order"


//退款
#define KUIKUAN @"http://www119.alayy.com/index.php?d=api&c=order&m=apply_refund"


//获取购物车数量
#define GET_SHOPPINGCAR_NUM @"http://www119.alayy.com/index.php?d=api&c=order&m=get_cart_pro_num"

//获取北京的地区名称和id
#define GET_ADRESS_BJ @"http://www119.alayy.com/index.php?d=api&c=order&m=get_p_c_list"

//颜色尺码选择
#define CHOOSE_COLORANDSIZE @"http://www119.alayy.com/index.php?d=api&c=products&m=get_product_attr"

//领取优惠劵
#define USER_GETCOUPON @"http://www119.alayy.com/index.php?d=api&c=order&m=receive_coupon"

//62、支付时弹出可以使用的优惠券列表
#define USER_GETCOUPON_LIST @"http://www119.alayy.com/index.php?d=api&c=order&m=use_coupon_list"

#endif





