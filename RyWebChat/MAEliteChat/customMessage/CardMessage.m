#import <RongIMLib/RCUtilities.h>
#import "CardMessage.h"
@implementation CardMessage

+(instancetype)messageWithContent:(NSString *)title imageUri:(NSString *)imageUri url:(NSString *)url price:(NSString *)price from:(NSString *)from extra:(NSString *)extra;{
    CardMessage *msg = [[CardMessage alloc] init];
    if (msg) {
        msg.title = title;
        msg.imageUri = imageUri;
        msg.url = url;
        msg.price = price;
        msg.from = from;
        msg.extra = extra;
    }
    
    return msg;
}

+(RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark – NSCoding protocol methods
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.imageUri = [aDecoder decodeObjectForKey:@"imageUri"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.from = [aDecoder decodeObjectForKey:@"from"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"]; }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.imageUri forKey:@"imageUri"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    
}

#pragma mark – RCMessageCoding delegate methods

-(NSData *)encode {
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:self.title forKey:@"title"];
    [dataDict setObject:self.imageUri forKey:@"imageUri"];
    [dataDict setObject:self.url forKey:@"url"];
    [dataDict setObject:self.price forKey:@"price"];
    [dataDict setObject:self.from forKey:@"from"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    
    if (self.senderUserInfo) {
        NSMutableDictionary *__dic=[[NSMutableDictionary alloc]init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:__dic forKey:@"user"];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

-(void)decodeWithData:(NSData *)data {
    __autoreleasing NSError* __error = nil;
    if (!data) {
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&__error];
    
    if (json) {
        self.title = json[@"title"];
        self.imageUri = json[@"imageUri"];
        self.url = json[@"url"];
        self.price = json[@"price"];
        self.from = json[@"from"];
        self.extra = json[@"extra"];
        NSObject *__object = [json objectForKey:@"user"];
        NSDictionary *userinfoDic = nil;
        if (__object &&[__object isMemberOfClass:[NSDictionary class]]) {
            userinfoDic =__object;
        }
        if (userinfoDic) {
            RCUserInfo *userinfo =[RCUserInfo new];
            userinfo.userId = [userinfoDic objectForKey:@"id"];
            userinfo.name =[userinfoDic objectForKey:@"name"];
            userinfo.portraitUri =[userinfoDic objectForKey:@"icon"];
            self.senderUserInfo = userinfo;
        }
        
    }
}
- (NSString *)conversationDigest
{
    return @"卡片消息要显示的内容";
}
+(NSString *)getObjectName {
    return RCLocalMessageTypeIdentifier;
}
#if ! __has_feature(objc_arc)
-(void)dealloc
{
    [super dealloc];
}
#endif//__has_feature(objc_arc)
@end
