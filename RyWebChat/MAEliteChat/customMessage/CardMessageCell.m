#import "CardMessageCell.h"
#import "CardMessage.h"
#import "RobotMessage.h"
#import "EliteMessage.h"
#import "MAChat.h"
#import "MAJSONObject.h"
#import "MARequest.h"
#import "MASession.h"
#import "MAEliteChat.h"
#import "MAMessageUtils.h"
#import "MAConfig.h"
#import "MJExtension.h"

@interface CardMessageCell ()<RCAttributedLabelDelegate>
#define Test_Message_Font_Size 16



- (void)initialize;

@end

@implementation CardMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CardMessage *message = (CardMessage *)model.content;
    CGSize size = [CardMessageCell getBubbleBackgroundViewSize:message ];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
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

- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.imageUri = [[UIImageView alloc] initWithFrame:CGRectZero];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:(@selector(attributedLink))];
    [self.imageUri addGestureRecognizer:tapGesture];
    self.imageUri.userInteractionEnabled = YES;
    
    self.title = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.title.delegate = self;
    [self.title setFont:[UIFont systemFontOfSize:16]];
    self.title.lineBreakMode = 0;
    self.title.numberOfLines = 0;
    [self.title setLineBreakMode:NSLineBreakByWordWrapping];
    [self.title setTextAlignment:NSTextAlignmentLeft];
    self.title.userInteractionEnabled = YES;
    
    self.price = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.price.delegate = self;
    [self.price setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];
    self.price.numberOfLines = 0;
    [self.price setLineBreakMode:NSLineBreakByWordWrapping];
    [self.price setTextAlignment:NSTextAlignmentLeft];
    self.price.userInteractionEnabled = YES;
    [self.price setTextColor:[UIColor redColor]];
    
    self.from = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.from.delegate = self;
    [self.from setFont:[UIFont systemFontOfSize:12]];
    self.from.numberOfLines = 0;
    [self.from setLineBreakMode:NSLineBreakByWordWrapping];
    [self.from setTextAlignment:NSTextAlignmentLeft];
    self.from.userInteractionEnabled = YES;
    [self.from setTextColor:[UIColor grayColor]];
    
    self.url = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.url.delegate = self;
    
    [self.messageContentView addSubview:self.imageUri];
    [self.messageContentView addSubview:self.title];
    [self.messageContentView addSubview:self.price];
    [self.messageContentView addSubview:self.from];
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}
- (void)setAutoLayout {
    CardMessage *cardMessage = (CardMessage *)self.model.content;
    if (cardMessage) {
        self.title.text = cardMessage.title;
        self.imageUri.image=[UIImage imageNamed: cardMessage.imageUri];
        NSURL *imageUri = [NSURL URLWithString:cardMessage.imageUri];
        UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUri]];
        self.imageUri.image = images;
        self.imageUri.layer.masksToBounds=YES;
        self.url.text = cardMessage.url;
        self.price.text = cardMessage.price;
        self.from.text = cardMessage.from;
    }
    // ios 7及以上
    CGSize __titleSize = [cardMessage.title boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                     (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 40,
                                     MAXFLOAT)
     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
     NSStringDrawingUsesFontLeading
     attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]} context:nil]
    .size;
    __titleSize = CGSizeMake(ceilf(__titleSize.width) + 5, ceilf(__titleSize.height) + 5);
    
    CGSize __fromSize = [cardMessage.from boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                     (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 40,
                                     MAXFLOAT)
     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
     NSStringDrawingUsesFontLeading
     attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]} context:nil]
    .size;
    __fromSize = CGSizeMake(ceilf(__fromSize.width) + 5, ceilf(__fromSize.height) + 5);

    CGRect messageContentViewRect = self.messageContentView.frame;
    messageContentViewRect.size.width = ceilf([UIScreen mainScreen].bounds.size.width * 0.7);
    messageContentViewRect.size.height = ceilf([UIScreen mainScreen].bounds.size.height * 0.25 + __titleSize.height + __fromSize.height * 2 + 5);
    self.messageContentView.frame = messageContentViewRect;
    self.price.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height * 0.25, messageContentViewRect.size.width - 12, __fromSize.height);
    self.title.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height * 0.25 + __fromSize.height, messageContentViewRect.size.width - 30, __titleSize.height);
    self.from.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height * 0.25 + __titleSize.height + __fromSize.height, messageContentViewRect.size.width - 12, __fromSize.height);
    self.bubbleBackgroundView.image = [self imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
    UIImage *image = self.bubbleBackgroundView.image;
    self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                                    image.size.height * 0.2, image.size.width * 0.2)];
    self.bubbleBackgroundView.frame = CGRectMake(0, 0, messageContentViewRect.size.width, messageContentViewRect.size.height);;
    self.imageUri.frame = CGRectMake(self.bubbleBackgroundView.frame.origin.x + 8, self.bubbleBackgroundView.frame.origin.y, self.bubbleBackgroundView.frame.size.width - 10 , [UIScreen mainScreen].bounds.size.height * 0.25);
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

+ (CGSize)getTextLabelSize:(CardMessage *)message {
    if ([message.title length] > 0) {
        float maxWidth =
        [UIScreen mainScreen].bounds.size.width -
        (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 -
        35;
        CGRect textRect = [message.title
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine |
                                    NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName :
                                            [UIFont systemFontOfSize:Test_Message_Font_Size]
                                        }
                           context:nil];
        CGRect from = [message.from
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
        from.size.height = ceilf(from.size.height);
        from.size.width = ceilf(from.size.width);
        return CGSizeMake(textRect.size.width + 5, [UIScreen mainScreen].bounds.size.height * 0.25 + textRect.size.height + 2 * from.size.height + 5);
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

+ (CGSize)getBubbleBackgroundViewSize:(CardMessage *)message {
    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    return [[self class] getBubbleSize:textLabelSize];
}
/**
 * 点击图片的回调
 */
- (void)attributedLink{
    NSString *urlText = self.url.text;
    NSLog(@"attributedLink %@", urlText);
    NSURL *url=[NSURL URLWithString: self.url.text];
    [[UIApplication sharedApplication] openURL:url];
    
}

/*
 * 点击文本标签的回调
 */
- (void)attributedLabel:(RCAttributedLabel *)label didTapLabel:(NSString *)content {
    [self attributedLink];
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
