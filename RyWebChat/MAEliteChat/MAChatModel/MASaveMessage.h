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

+ (instancetype)saveMessageWithText:(NSDictionary *)dic;
+ (instancetype)saveMessageWithVoice:(NSDictionary *)dic;
+ (instancetype)saveMessageWithImage:(NSDictionary *)dic;
+ (instancetype)saveMessageWithLocation:(NSDictionary *)dic;
@end


@interface MAUnsendMessageArray : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@end
