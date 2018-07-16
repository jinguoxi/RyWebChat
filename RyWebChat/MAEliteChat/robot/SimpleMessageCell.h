#import <RongIMKit/RongIMKit.h>
#import "SimpleMessage.h"
//#import "MARyChatViewController.h"


/**
 * 文本消息Cell
 */
@interface SimpleMessageCell : RCMessageCell <RCMessageCellDelegate>

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
