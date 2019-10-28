#import "SimpleMessageCell.h"
#import "EliteMessage.h"
#import "MAChat.h"
#import "MAJSONObject.h"
#import "MARequest.h"
#import "MASession.h"
#import "MAEliteChat.h"
#import "MAMessageUtils.h"
#import "MAConfig.h"
#import "MJExtension.h"

@interface SimpleMessageCell ()<RCAttributedLabelDelegate>
#define Test_Message_Font_Size 16



- (void)initialize;

@end

@implementation SimpleMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    SimpleMessage *message = (SimpleMessage *)model.content;
    CGSize size = [SimpleMessageCell getBubbleBackgroundViewSize:message ];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
//    RCTextMessageCell
}

- (NSDictionary *)attributeDictionary {
    if (self.messageDirection == MessageDirection_SEND) {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    } else {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    }
    return nil;
}

- (NSDictionary *)highlightedAttributeDictionary {
    return [self attributeDictionary];
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)test: (NSString *)aa{
    NSLog(@"fsdgdf");
}


- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.textLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.textLabel.delegate = self;
//    self.textLabel.attributeDictionary = [self attributeDictionary];
//    self.textLabel.highlightedAttributeDictionary = [self highlightedAttributeDictionary];
    [self.textLabel setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];
    
    self.textLabel.numberOfLines = 0;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textLabel setTextColor:[UIColor blackColor]];
    //[self.textLabel setBackgroundColor:[UIColor yellowColor]];
    
    [self.bubbleBackgroundView addSubview:self.textLabel];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    self.textLabel.userInteractionEnabled = YES;
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}
//- (void)didTapMessageCell:(RCMessageModel *)model{
//    NSLog(@"didTapMessageCell");
//}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    [self setAutoLayout];
}
- (void)setAutoLayout {
    SimpleMessage *robotMessage = (SimpleMessage *)self.model.content;
    if (robotMessage) {
        self.textLabel.text = robotMessage.message;
    }
    // ios 7
    CGSize __textSize =
    [robotMessage.message
     boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                     (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 40,
                                     MAXFLOAT)
     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
     NSStringDrawingUsesFontLeading
     attributes:@{
                  NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]
                  } context:nil]
    .size;
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 5);
    
    CGFloat __bubbleWidth = __labelSize.width + 15 + 20 < 50 ? 50 : (__labelSize.width + 15 + 20);
    CGFloat __bubbleHeight = __labelSize.height + 5 + 5 < 35 ? 35 : (__labelSize.height + 5 + 5);
    
    CGSize __bubbleSize = CGSizeMake(__bubbleWidth, __bubbleHeight);
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.origin.x = 50;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        
        self.textLabel.frame = CGRectMake(20, 5, __labelSize.width, __labelSize.height);
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                                        image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        
        self.textLabel.frame = CGRectMake(15, 5, __labelSize.width, __labelSize.height);
        
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                                        image.size.height * 0.2, image.size.width * 0.8)];
    }
}
- (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return image;
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        //DebugLog(@”long press end”);
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

+ (CGSize)getTextLabelSize:(SimpleMessage *)message {
    if ([message.message length] > 0) {
        float maxWidth =
        [UIScreen mainScreen].bounds.size.width -
        (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 -
        35;
        CGRect textRect = [message.message
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine |
                                    NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName :
                                            [UIFont systemFontOfSize:Test_Message_Font_Size]
                                        }
                           context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}


+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);
    
    if (bubbleSize.width + 12 + 20 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 20;
    } else {
        bubbleSize.width = 50;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }
    
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(SimpleMessage *)message {
    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    return [[self class] getBubbleSize:textLabelSize];
}


//@interface SimpleMessageCell () <RCAttributedLabelDelegate>
//self.textLabel.delegate = self;

- (void)attributedLabel:(RCAttributedLabel *)label didTapLabel:(NSString *)content {
    NSLog(@"didTapLabe");
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

-(BOOL) sendTransferMessage{
    BOOL robotMode = [[MAChat getInstance] getSession].robotMode;
    if(robotMode){
        NSString *content = @"转接";
        EliteMessage *messageContent = [EliteMessage messageWithContent:content];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
        extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
        extra[@"type"] = @(ROBOT_TRANSFER_MESSAGE);
        extra[@"messageType"] = @(MATEXT);
        messageContent.extra = [extra mj_JSONString];
        
        NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
        [[RCIM sharedRCIM] sendMessage:ConversationType_SYSTEM targetId:chatTargetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
        } error:nil];
    }else {
        [self addTipsMessage:@"您已经在人工聊天中噢😯"];
    }
    
    return true;
}

/*!
 点击URL的回调
 
 @param label 当前Label
 @param url   点击的URL
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
      NSLog(@"didSelectLinkWithURL");
    NSString * content = [url absoluteString];
    NSString *decodedString = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    if([decodedString hasPrefix:@"http://"] || [decodedString hasPrefix:@"https://"]){
        return;
    }
    if([@"【转人工】" isEqualToString:decodedString]){
        [self sendTransferMessage];
    }else {
        NSRange range = [decodedString rangeOfString:@"\n"];//匹配得到的下标
        if(range.location > 0 && range.length == 1){
            range.length = decodedString.length - range.location - 1;
            range.location = range.location + 1;
            
            decodedString = [decodedString substringWithRange:range];//截取范围类的字符串
        }
        RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:decodedString];
        NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
        extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
        rcTextMessage.extra = [extra mj_JSONString];
        [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:rcTextMessage pushContent:nil pushData:nil success:^(long messageId) {
        } error:nil];
    }
   
}

//小灰色提示条
- (void)addTipsMessage:(NSString *)msg {
    RCInformationNotificationMessage *warningMsg = [RCInformationNotificationMessage
                                                    notificationWithMessage:msg extra:nil];
    
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:warningMsg pushContent:nil pushData:nil success:^(long messageId) {
    } error:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
