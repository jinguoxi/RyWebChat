//
//  MAChat.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAChat.h"
#import <RongIMKit/RongIMKit.h>
#import "MJExtension.h"

@interface MAChat()
@property (strong, nonatomic) MAClient *client;
@property (strong, nonatomic) MARequest *request;
@property (strong, nonatomic) MASession *session;
@property (strong, nonatomic, readwrite) NSString *tokenStr;
@end

@implementation MAChat

static MAChat *chat;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chat = [[MAChat alloc] init];
    });
    
    return chat;
}

- (void)setClient:(MAClient *)client {
    _client = client;
}

- (void)setRequest:(MARequest *)request {
    _request = request;
}

- (void)setTokenStr:(NSString *)tokenStr {
    _tokenStr = tokenStr;
}

- (void)setSession:(MASession *)session {
    _session = session;
}

- (long)getRequestId {
    if (self.request) {
        return self.request.requestId;
    }
    
    return 0;
}

- (long)getSessionId {
    if (self.session) {
        return self.session.sessionId;
    }
    
    return 0;
}

- (MAClient *)getClient {
    return self.client;
}

- (MASession *)getSession {
    return self.session;
}

- (void)updateSession:(MAAgent *)currentAgent {
    self.session.currentAgent = currentAgent;
}

- (void)addUnsendMessage:(MASaveMessage *)message {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [MAUnsendMessageArray mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"messages":@"MASaveMessage"};
    }];
    
    MAUnsendMessageArray *unsendMsg = [MAUnsendMessageArray mj_objectWithKeyValues:[userDefault objectForKey:@"unsendMsg"]];
    
    if (unsendMsg.messages) {
        [unsendMsg.messages addObject:message];
    } else {
        unsendMsg = [MAUnsendMessageArray new];
        unsendMsg.messages = [NSMutableArray arrayWithObject:message];
    }
    
    [userDefault setObject:[unsendMsg mj_JSONString] forKey:@"unsendMsg"];
}

- (NSMutableArray *)getUnsendMessage {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [MAUnsendMessageArray mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"messages":@"MASaveMessage"};
    }];
    MAUnsendMessageArray *msg = [MAUnsendMessageArray mj_objectWithKeyValues:[userDefault objectForKey:@"unsendMsg"]];
    
    return msg.messages;
}

- (void)updateUnsendMessage:(NSArray *)array {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (!array) [userDefault removeObjectForKey:@"unsendMsg"];
    MAUnsendMessageArray *unsendMsg = [MAUnsendMessageArray new];
    
    unsendMsg.messages = [NSMutableArray arrayWithArray:array];
    
    [userDefault setObject:[unsendMsg mj_JSONString] forKey:@"unsendMsg"];
}

+ (void)clearRequestAndSession {
    if (chat.request) {
        chat.request = nil;
    }
    
    if (chat.session) {
        chat.session = nil;
    }
}
@end
