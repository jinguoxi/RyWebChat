#import <RongIMLib/RongIMLib.h>
//#import <RongIMLib/RCMessageContentView.h>

#define RCLocalMessageTypeIdentifier @"E:CardMsg"



/**
 * 文本消息类定义
 */
@interface CardMessage : RCMessageContent <NSCoding,RCMessageContentView>

/** 卡片消息的标题 */
@property(nonatomic, strong) NSString* title;

/** 卡片消息的商品p图片 */
@property(nonatomic, strong) NSString* imageUri;

/** 卡片消息的链接的URL */
@property(nonatomic, strong) NSString* url;

/** 卡片消息的商品价格 */
@property(nonatomic, strong) NSString* price;

/** 卡片消息的来源 */
@property(nonatomic, strong) NSString* from;

/**
 * 附加信息
 */
@property(nonatomic, strong) NSString* extra;

/**
 * 根据参数创建消息对象
 * @param content 卡片消息内容
 */
+(instancetype)messageWithContent:(NSString *)title imageUri:(NSString *)imageUri url:(NSString *)url price:(NSString *)price from:(NSString *)from extra:(NSString *)extra;

@end
