#import <RongIMKit/RongIMKit.h>


/**
 * 文本消息Cell
 */
@interface RobotMessageCell : RCMessageCell <RCMessageCellDelegate>

/**
 * 消息显示Label
 */
@property(strong, nonatomic) RCAttributedLabel *textLabel;

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
