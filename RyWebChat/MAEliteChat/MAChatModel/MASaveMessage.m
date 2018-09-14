//
//  MASaveMessage.m
//  RyWebChat
//
//  Created by nwk on 2017/2/20.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MASaveMessage.h"

@implementation MASaveMessage


+ (instancetype)saveMessageWithText:(NSDictionary *)dic {
    
    NSDictionary *contentDic = dic[@"content"];
    
    MASaveMessage *message = [MASaveMessage new];
    message.objectName = dic[@"objectName"];
    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:contentDic[@"content"], @"content", nil];
    
    return message;
}

+ (instancetype)saveMessageWithVoice:(NSDictionary *)dic {
    NSDictionary *contentDic = dic[@"content"];
    
    MASaveMessage *message = [MASaveMessage new];
    message.objectName = dic[@"objectName"];
    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          contentDic[@"content"], @"content",
                          contentDic[@"duration"], @"duration",
                          nil];
    
    return message;
}

+ (instancetype)saveMessageWithSight:(NSDictionary *)dic {
    NSDictionary *contentDic = dic[@"content"];
    MASaveMessage *message = [MASaveMessage new];
    message.objectName = dic[@"objectName"];
    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          contentDic[@"content"], @"content",
                          contentDic[@"name"], @"name",
                          contentDic[@"sightUrl"], @"sightUrl",
                          contentDic[@"size"], @"size",
                          contentDic[@"duration"], @"duration",
                          nil];
    
    return message;
}

+ (instancetype)saveMessageWithImage:(NSDictionary *)dic {
    NSDictionary *contentDic = dic[@"content"];
    
    MASaveMessage *message = [MASaveMessage new];
    message.objectName = dic[@"objectName"];
    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          contentDic[@"content"], @"content",
                          contentDic[@"imageUri"], @"imageUri",
                          nil];
    
    return message;
}

+ (instancetype)saveMessageWithLocation:(NSDictionary *)dic {
    NSDictionary *contentDic = dic[@"content"];
    
    MASaveMessage *message = [MASaveMessage new];
    message.objectName = dic[@"objectName"];
    NSString *imgUri = contentDic[@"imgUri"];
    if (!imgUri) {
        imgUri = @"";
    }
    message.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          contentDic[@"content"], @"content",
                          contentDic[@"latitude"], @"latitude",
                          contentDic[@"longitude"], @"longitude",
                          contentDic[@"poi"], @"poi",
                          imgUri, @"imgUri",
                          nil];
    
    return message;
}
@end

@implementation MAUnsendMessageArray

@end
