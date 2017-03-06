//
//  MAEliteChat.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAEliteChat.h"
#import <RongIMKit/RongIMKit.h>
#import "MAMessageUtils.h"
#import "MAChat.h"
#import "MAHttpService.h"

@interface MAEliteChat()<RCIMUserInfoDataSource>

@property (assign, nonatomic) int queueId;//排队号;
@property (assign, nonatomic) BOOL initialized;
@property (assign, nonatomic) BOOL startChatReady;

@end

@implementation MAEliteChat

static MAEliteChat *eliteChat=nil;

+ (instancetype)shareEliteChat {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eliteChat = [[MAEliteChat alloc] init];
    });
    
    return eliteChat;
}

- (void)startRyWithAppKey:(NSString *)key {
    [[RCIM sharedRCIM] initWithAppKey:key];
    
    [[RCIM sharedRCIM] registerMessageType:[EliteMessage class]];
    //开启用户信息和群组信息的持久化
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
}

- (void)initAndStart:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId complete:(void (^)(BOOL result))complete {
    
    [self initAndStart:serverAddr userId:userId name:name portraitUri:portraitUri queueId:queueId ngsAddr:nil eliteMessages:nil complete:complete];
    
}

- (void)initAndStart:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId ngsAddr:(NSString *)ngsAddr eliteMessages:(NSMutableArray *) eliteMessages complete:(void (^)(BOOL result))complete {
    
    [self initElite:serverAddr userId:userId name:name portraitUri:portraitUri queueId:queueId ngsAddr:ngsAddr];
    
    [self startChat:complete];
    
}

- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId {
    
    [self initElite:serverAddr userId:userId name:name portraitUri:portraitUri queueId:queueId ngsAddr:nil];
}

- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId ngsAddr:(NSString *)ngsAddr {
    
    if (isEliteEmpty(ngsAddr)) {
        NSString *lastPath = [serverAddr lastPathComponent];
        NSRange range = [serverAddr rangeOfString:lastPath];
        NSString *ipStr = [serverAddr substringToIndex:range.location-1];
        ngsAddr = [ipStr stringByAppendingPathComponent:@"ngs"];
    }
    
    serverAddr = [serverAddr stringByAppendingPathComponent:@"rcs"];
    
    MAClient *client = [MAClient initWithServerAddr:serverAddr ngsAddr:ngsAddr name:name userId:userId portraitUri:portraitUri];
    
    [[MAChat getInstance] setClient:client];
    
    self.queueId = queueId;
    
    self.initialized = YES;
}

- (void)startChat:(void (^)(BOOL result))complete {
    
    MAClient *client = [[MAChat getInstance] getClient];
    
    if (!client) {
        NSLog(@"初始化失败");
        complete(NO);
    }
    
    [self contentRyTokenService:client.serverAddr userId:client.userId nickName:client.name protrait:client.portraitUri complete:^(NSString *token) {
        
        if (isEliteEmpty(token)) {
            complete(NO);
        } else {
            [[MAChat getInstance] setTokenStr:token];
            
            self.startChatReady = YES;
            
            complete(YES);
        }
    }];
}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    
    NSLog(@"----%@",userId);
    
    MAAgent *agent = [[MAChat getInstance] getSession].currentAgent;
    
    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:agent.userId name:agent.name portrait:agent.portraitUri];
    
    completion(user);
}

- (void)contentRyTokenService:(NSString *)serverAddr userId:(NSString *)userId nickName:(NSString *)nickName protrait:(NSString *)portraitUri complete:(void (^)(NSString *token))complete  {
    
    if (isEliteEmpty(serverAddr)) return complete(nil);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"action"] = @"login";
    dic[@"userId"] = userId;
    dic[@"name"] = nickName;
    dic[@"portraitUri"] = portraitUri;
    
    [MAHttpService getRyToken:serverAddr paramer:dic success:^(NSString *token) {
        
        if (isEliteEmpty(token)) return complete(nil);
        
        [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
            NSLog(@"---%@",userId);
            
            [self loginSuccess:nickName userId:userId portrait:portraitUri token:token];
            
            complete(token);
            
        } error:^(RCConnectErrorCode status) {
            //TODO 获取token失败
            
            NSLog(@"---%zd",status);
            complete(nil);
            
        } tokenIncorrect:^{
            [self contentRyTokenService:serverAddr userId:userId nickName:nickName protrait:portraitUri complete:complete];
        }];
        
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
        complete(nil);
    }];
}
/**
 *  发出聊天排队请求
 *
 *  @param queueId 队列号
 */
- (void)sendQueueRequest {
    if (self.startChatReady) {
        [MAMessageUtils sendChatRequest:self.queueId from:@"APP"];
    } else {
        NSLog(@"未启动sdk");
    }
}

- (void)setDeviceToken:(NSString *)token {
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
            portrait:(NSString *)portraitUri
               token:(NSString *)token {
    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId
                                                     name:userName
                                                 portrait:portraitUri];
    
    [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
    [RCIM sharedRCIM].currentUserInfo = user;
}

BOOL isEliteEmpty(id object){
    if ([object isKindOfClass:[NSString class]]) {
        if (!object || [object isEqualToString:@""]) {
            return YES;
        }
    } else {
        if (!object) return YES;
    }
    
    return NO;
}

@end
