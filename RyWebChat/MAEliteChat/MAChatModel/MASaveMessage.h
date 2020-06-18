//
//  MASaveMessage.h
//  RyWebChat
//
//  Created by nwk on 2017/2/20.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASaveMessage : NSObject

@property (strong, nonatomic) NSString *objectName;

@property (strong, nonatomic) NSDictionary *contentDic;

+ (void)saveMessageWithText:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;
+ (void)saveMessageWithVoice:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;
+ (void)saveMessageWithImage:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;
+ (void)saveMessageWithLocation:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;
+ (void)saveMessageWithSight:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;
+ (void)saveMessageWithHQVoice:(NSDictionary *)dic :(NSString *) conversationType :(NSString *)targetId;

@end


@interface MAUnsendMessageArray : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@end
