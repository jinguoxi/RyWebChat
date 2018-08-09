//
//  MARyChatViewController.h
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

typedef NS_ENUM(NSInteger, MAMAPTYPE) {
    MAMAPTYPE_Gaode,
    MAMAPTYPE_Baidu
};

@interface MARyChatViewController : RCConversationViewController

//满意度评价视图
@property (strong, nonatomic) UIView *satisfactionView;

/**
 选择地图类型，默认是高德，（支持百度地图）
 */
@property (assign, nonatomic) MAMAPTYPE mapType;

@end
