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
#import "SimpleMessage.h"

@interface MAEliteChat()<RCIMUserInfoDataSource>

@property (assign, nonatomic) int queueId;//排队号;
@property (assign, nonatomic) BOOL initialized;
@property (assign, nonatomic) BOOL startChatReady;
@property (strong, nonatomic) NSString* oldClientId;

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
    [[RCIMClient sharedRCIMClient]registerMessageType:SimpleMessage.class];  //注册自定义显示消息   2017-07-04
    //开启用户信息和群组信息的持久化
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
}

- (void)startChat:(NSString *)serverAddr token:(NSString *) token userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSString *)tracks complete:(void (^)(BOOL result))complete {
    MAChat *maChat = [MAChat getInstance];
    [maChat setChatTargetId:chatTargetId];
    if(maChat != nil && [maChat isSessionAvailable]){
        if(maChat.tokenStr != nil){
            if(queueId != [maChat getQueueId]){//如果队列改变了，则直接结束之前会话，并开启新的会话
                [self closeSessionService:serverAddr token:token userId:userId name:name portraitUri:portraitUri chatTargetId:chatTargetId queueId:queueId ngsAddr:ngsAddr tracks:tracks complete:complete];
            }else {
                // 如果队列没变化，则去检查token是否还合法，如果合法则可以直接继续聊天。如果不合法则需要重新登录
                [self checkTokenService:serverAddr token:token userId:userId name:name portraitUri:portraitUri chatTargetId:chatTargetId queueId:queueId ngsAddr:ngsAddr tracks:tracks complete:^(NSString *result) {
                    if([@"1" isEqualToString:result] ){
                        complete(YES);
                    }else {
                         [maChat clearRequestAndSession];
                         [self initAndStart:(NSString *) serverAddr userId:userId name:name portraitUri:portraitUri chatTargetId:chatTargetId queueId:queueId ngsAddr:ngsAddr tracks:tracks complete:complete];
                    }
                }];
            }
        }
    }else {
        [self initAndStart:(NSString *) serverAddr userId:userId name:name portraitUri:portraitUri chatTargetId:chatTargetId queueId:queueId ngsAddr:ngsAddr tracks:tracks complete:complete];
    }
    
}

- (void)initAndStart:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSString *)tracks complete:(void (^)(BOOL result))complete {
    [[MAChat getInstance] setChatTargetId:chatTargetId];
    [MAChat getInstance].queueId = &(queueId);
    [self initElite:serverAddr userId:userId name:name portraitUri:portraitUri queueId:queueId ngsAddr:ngsAddr tracks: tracks];
    
    [self startChat:complete];
    
}

- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId {
    
    [self initElite:serverAddr userId:userId name:name portraitUri:portraitUri queueId:queueId ngsAddr:nil];
}

- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId ngsAddr:(NSString *)ngsAddr  tracks:(NSString *)tracks {
    
    if (isEliteEmpty(ngsAddr)) {
        NSString *lastPath = [serverAddr lastPathComponent];
        NSRange range = [serverAddr rangeOfString:lastPath];
        NSString *ipStr = [serverAddr substringToIndex:range.location-1];
        ngsAddr = [ipStr stringByAppendingPathComponent:@"ngs"];
    }
    
    serverAddr = [serverAddr stringByAppendingPathComponent:@"rcs"];
    
    MAClient *client = [MAClient initWithServerAddr:serverAddr ngsAddr:ngsAddr name:name userId:userId portraitUri:portraitUri tracks:tracks] ;
    
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
    
    if(self.oldClientId != nil && [self.oldClientId isEqualToString:client.userId]){
        RCConnectionStatus status = [[RCIM sharedRCIM] getConnectionStatus];
        if (status == ConnectionStatus_Connected) {//当前已连接上 无需再次登录
            
            self.startChatReady = YES;
            
            complete(YES);
            
            return;
        }
    }
    
    [self contentRyTokenService:client.serverAddr userId:client.userId nickName:client.name protrait:client.portraitUri complete:^(NSString *token) {
        NSLog(@"token:%@", token);
        if(token != nil){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (isEliteEmpty(token)) {
                    complete(NO);
                } else {
                    [[MAChat getInstance] setTokenStr:token];
                    self.oldClientId = client.userId;
                    self.startChatReady = YES;
                    [[MAChat getInstance] clearRequestAndSession];
                    complete(YES);
                }
            });
        }else {
            if (isEliteEmpty(token)) {
                complete(NO);
            } else {
                [[MAChat getInstance] setTokenStr:token];
                self.oldClientId = client.userId;
                self.startChatReady = YES;
                [[MAChat getInstance] clearRequestAndSession];
                complete(YES);
            }
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
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    dic[@"targetId"] = chatTargetId;
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
            //[self contentRyTokenService:serverAddr userId:userId nickName:nickName protrait:portraitUri complete:complete];
            
        } tokenIncorrect:^{
            [self contentRyTokenService:serverAddr userId:userId nickName:nickName protrait:portraitUri complete:complete];
        }];
        
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
        complete(nil);
    }];
}

- (void)checkTokenService:(NSString *)serverAddr token:(NSString *) token userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSString *)tracks complete:(void (^)(NSString *result))complete  {
    if (isEliteEmpty(serverAddr)) return complete(nil);
     serverAddr = [serverAddr stringByAppendingPathComponent:@"rcs"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"action"] = @"check";
    dic[@"token"] = token;
    [MAHttpService checkToken:serverAddr paramer:dic success:^(NSString *result) {
        complete(result);
        
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
         complete(nil);
    }];
}

- (void)closeSessionService:(NSString *)serverAddr token:(NSString *) token userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSString *)tracks complete:(void (^)(BOOL result))complete {
    if (isEliteEmpty(serverAddr)) return;
    serverAddr = [serverAddr stringByAppendingPathComponent:@"rcs"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"action"] = @"closeSession";
   long sessionId = [[MAChat getInstance] getSessionId];
    NSNumber *longlongNumber = [NSNumber numberWithLongLong:sessionId];
    NSString *longlongStr = [longlongNumber stringValue];
    dic[@"sessionId"] = longlongStr;
    dic[@"token"] = token;
    [MAHttpService closeSession:serverAddr paramer:dic success:^(NSString *result) {
        if([@"1" isEqualToString:result] ){
            [[MAChat getInstance] clearRequestAndSession];
            [self initAndStart:serverAddr userId:userId name:name portraitUri:portraitUri chatTargetId:chatTargetId queueId:queueId ngsAddr:ngsAddr tracks:tracks complete:complete];
        }
        
        
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
       // complete(nil);
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
