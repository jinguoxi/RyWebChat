//
//  MABaiduAnnotation.h
//  SocketDemo
//
//  Created by nwk on 2017/1/10.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>

@interface MABaiduAnnotation : NSObject<BMKAnnotation>
{
    @package
    NSString *_title;
    NSString *_subtitle;
}

/// 要显示的标题
@property (copy) NSString *title;
/// 要显示的副标题
@property (copy) NSString *subtitle;

@end
