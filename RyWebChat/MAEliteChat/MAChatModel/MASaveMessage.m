//
//  MASaveMessage.m
//  RyWebChat
//
//  Created by nwk on 2017/2/20.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MASaveMessage.h"
#import "UnSendMessage.h"

@implementation MASaveMessage

+ (void)saveMessageWithText:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId {
    NSDictionary *contentDic = dic[@"content"];
    
//    MASaveMessage *message = [MASaveMessage new];
//    message.objectName = dic[@"objectName"];
//    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:contentDic[@"content"], @"content", nil];
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:contentDic[@"content"], @"content", nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};
    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:conversationType];
    
}

+ (void)saveMessageWithVoice:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId{
    NSDictionary *contentDic = dic[@"content"];
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  contentDic[@"content"], @"content",
                                                  contentDic[@"duration"], @"duration",
                                                  nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};

    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:dic[@"conversationType"]];

}

+ (void)saveMessageWithHQVoice:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId{
    NSDictionary *contentDic = dic[@"content"];
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  contentDic[@"remoteUrl"], @"remoteUrl",
                                                  contentDic[@"name"], @"name",
                                                  contentDic[@"duration"], @"duration",
                                                  nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};

    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:dic[@"conversationType"]];

}

+ (void)saveMessageWithSight:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId {
    NSDictionary *contentDic = dic[@"content"];
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  contentDic[@"content"], @"content",
                                                  contentDic[@"name"], @"name",
                                                  contentDic[@"sightUrl"], @"sightUrl",
                                                  contentDic[@"size"], @"size",
                                                  contentDic[@"duration"], @"duration",
                                                  nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};
    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:dic[@"conversationType"]];
}

+ (void)saveMessageWithImage:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId {
    NSDictionary *contentDic = dic[@"content"];
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 contentDic[@"content"], @"content",
                                                 contentDic[@"imageUri"], @"imageUri",
                                                 nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};
    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:dic[@"conversationType"]];
}

+ (void)saveMessageWithLocation:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId {
    NSDictionary *contentDic = dic[@"content"];
    
//    MASaveMessage *message = [MASaveMessage new];
//    message.objectName = dic[@"objectName"];
//    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                          contentDic[@"content"], @"content",
//                          contentDic[@"latitude"], @"latitude",
//                          contentDic[@"longitude"], @"longitude",
//                          contentDic[@"poi"], @"poi",
//                          imgUri, @"imgUri",
//                          nil];
    NSString *imgUri = contentDic[@"imgUri"];
    if (!imgUri) {
        imgUri = @"";
    }
    NSString *contentStr = [self transDicToNSStr:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  contentDic[@"content"], @"content",
                                                  contentDic[@"latitude"], @"latitude",
                                                  contentDic[@"longitude"], @"longitude",
                                                  contentDic[@"poi"], @"poi",
                                                  imgUri, @"imgUri",
                                                  nil]];
    NSDictionary *infoDict = @{@"target_id": targetId, @"conversation_type": conversationType, @"object_name": dic[@"objectName"], @"content":contentStr};
    [[[UnSendMessage alloc] initWithDict:infoDict] insertMessage:dic[@"conversationType"]];
}

+ (NSString *)transDicToNSStr: (NSDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:0];
    NSString *contentStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return contentStr;
}
@end

@implementation MAUnsendMessageArray

@end
