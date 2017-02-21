//
//  MASatisfactionView.m
//  RyWebChat
//
//  Created by nwk on 2017/2/20.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MASatisfactionView.h"

@interface MASatisfactionView()
{
    UIButton *radio1Btn;
    UIButton *radio2Btn;
    UITextView *textView;
    UIImageView *imageView;
    UIButton *sureBtn;
    UIView *contentView;
    UIImageView *bgImageView;
}

@property (assign, nonatomic) id<MASatisfactionViewDelegate> delegate;

@end

@implementation MASatisfactionView


+ (instancetype)newSatisfactionView:(id<MASatisfactionViewDelegate>)delegate {
    MASatisfactionView *satisfactionView = [[MASatisfactionView alloc] init];
    satisfactionView.delegate = delegate;
    CGRect winRect = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(winRect), CGRectGetHeight(winRect));
    satisfactionView.frame = frame;
    satisfactionView.backgroundColor = [UIColor clearColor];
    [satisfactionView setupUI];
    
    return satisfactionView;
}

- (void)setupUI {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    [self addSubview:bgView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame)-20, 200)];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    contentView.layer.cornerRadius = 5;
    contentView.layer.borderWidth = 1;
    contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentView.center = bgView.center;
    contentView.clipsToBounds = YES;
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame))];
    bgImageView.image = [UIImage imageNamed:@"MABg_default"];
    
    [contentView addSubview:bgImageView];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(contentView.frame)-10, 30)];
    title.text = @"满意度评价";
    title.font = [UIFont systemFontOfSize:20];
    [contentView addSubview:title];
    
    radio1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    radio1Btn.frame = CGRectMake(30, CGRectGetMaxY(title.frame)+10, 100, 40);
    [radio1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [radio1Btn setTitle:@"满意" forState:UIControlStateNormal];
    [radio1Btn setImage:[UIImage imageNamed:@"RadioButton-Unselected"] forState:UIControlStateNormal];
    [radio1Btn setImage:[UIImage imageNamed:@"RadioButton-Selected"] forState:UIControlStateSelected];
    [radio1Btn addTarget:self action:@selector(clickRadioButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:radio1Btn];
    
    radio2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    radio2Btn.frame = CGRectMake(CGRectGetMaxX(radio1Btn.frame)+20, CGRectGetMaxY(title.frame)+10, 100, 40);
    [radio2Btn setTitle:@"不满意" forState:UIControlStateNormal];
    [radio2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [radio2Btn setImage:[UIImage imageNamed:@"RadioButton-Unselected"] forState:UIControlStateNormal];
    [radio2Btn setImage:[UIImage imageNamed:@"RadioButton-Selected"] forState:UIControlStateSelected];
    [radio2Btn addTarget:self action:@selector(clickRadioButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:radio2Btn];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(radio2Btn.frame)+10, CGRectGetWidth(contentView.frame)-40, 70)];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.layer.cornerRadius = 5;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1;
    [contentView addSubview:imageView];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(imageView.frame)-10, CGRectGetHeight(imageView.frame))];
    textView.font = [UIFont systemFontOfSize:17];
    textView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    [imageView addSubview:textView];
    
    imageView.hidden = YES;
    
    sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(CGRectGetWidth(contentView.frame)-120, CGRectGetMaxY(imageView.frame)+10, 100, 40);
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    sureBtn.layer.cornerRadius = 5;
    sureBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sureBtn.layer.borderWidth = 1;
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:sureBtn];
    
    
    [self clickRadioButton:radio1Btn];
    
    [self updateUI];
}

- (void)updateUI {
    CGRect rect = sureBtn.frame;
    
    if (imageView.hidden) {
        rect.origin.y = CGRectGetMaxY(radio2Btn.frame)+10;
        sureBtn.frame = rect;
        textView.text = @"";
    } else {
        rect.origin.y = CGRectGetMaxY(imageView.frame)+10;
        sureBtn.frame = rect;
    }
    
    rect = contentView.frame;
    rect.size.height = CGRectGetMaxY(sureBtn.frame)+10;
    contentView.frame = rect;
    
    rect = bgImageView.frame;
    rect.size.height = CGRectGetHeight(contentView.frame);
    bgImageView.frame = rect;
}

- (void)clickRadioButton:(UIButton *)button {
    radio1Btn.selected = NO;
    radio2Btn.selected = NO;
    [textView resignFirstResponder];
    
    radio1Btn == button ? (radio1Btn.selected=!radio1Btn.selected) : (radio2Btn.selected = !radio2Btn.selected);
    
    imageView.hidden = !radio2Btn.selected;
    
    [self updateUI];
}
//不满意0 满意1
- (void)sureBtnPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(satisfactionView:sureEvent:)]) {
        [self.delegate satisfactionView:textView.text sureEvent:radio1Btn.selected?1:0];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [textView resignFirstResponder];
}

@end
