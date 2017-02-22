//
//  UIPlaceHolderTextView.h
//  RyWebChat
//
//  Created by nwk on 2017/2/22.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView
{
    
    NSString *placeholder;
    
    UIColor *placeholderColor;
    
@private
    
    UILabel *placeHolderLabel;
    
}

@property(nonatomic, strong) NSString *placeholder;

@property(nonatomic, strong) UIColor *placeholderColor;

@end
