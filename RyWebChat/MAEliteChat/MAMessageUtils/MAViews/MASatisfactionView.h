//
//  MASatisfactionView.h
//  RyWebChat
//
//  Created by nwk on 2017/2/20.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MASatisfactionViewDelegate <NSObject>
/**
 *  满意度确定
 *
 *  @param comment  描述
 *  @param ratingId 满意1 不满意0
 */
- (void)satisfactionView:(NSString *)comment sureEvent:(NSInteger)ratingId;

@end

@interface MASatisfactionView : UIView

+ (instancetype)newSatisfactionView:(id<MASatisfactionViewDelegate>)delegate;

@end
