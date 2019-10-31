#import <RongIMKit/RongIMKit.h>

/**
 * 文本消息Cell
 */
@interface CardMessageCell : RCMessageCell <RCMessageCellDelegate>

/**
 * 消息显示标题
 */
@property(strong, nonatomic) RCAttributedLabel *title;

/**
 * 消息显示商品图片地址
 */
@property(strong, nonatomic) UIImageView *imageUri;

/**
 * 消息显示URL
 */
@property(strong, nonatomic) RCAttributedLabel *url;

/**
 * 消息显示价格
 */
@property(strong, nonatomic) RCAttributedLabel *price;

/**
 * 消息显示来源
 */
@property(strong, nonatomic) RCAttributedLabel *from;


/**
 * 消息背景
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/**
 * 设置消息数据模型
 *
 * @param model 消息数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;
@end
