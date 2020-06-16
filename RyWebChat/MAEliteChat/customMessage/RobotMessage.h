#import <RongIMLib/RongIMLib.h>
//#import <RongIMLib/RCMessageContentView.h>

#define RCLocalMessageTypeIdentifier @"E:RobMsg"



/**
 * 文本消息类定义
 */
@interface RobotMessage : RCMessageContent <NSCoding,RCMessageContentView>

/** 文本消息内容 */
@property(nonatomic, strong) NSString* message;

/**
 * 附加信息
 */
@property(nonatomic, strong) NSString* extra;

/**
 * 根据参数创建文本消息对象
 * @param content 文本消息内容
 */
+(instancetype)messageWithContent:(NSString *)message extra:(NSString *)extra;

@end
