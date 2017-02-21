//
//  MAClient.h
//  SocketDemo
//
//  Created by nwk on 2016/12/16.
//  Copyright © 2016年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MAClient : NSObject

@property (strong, nonatomic, readonly) NSString *serverAddr;
@property (strong, nonatomic, readonly) NSString *userId;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *portraitUri;
@property (strong, nonatomic, readonly) NSString *tokenStr;

+ (instancetype)initWithServerAddr:(NSString *)serverAddr name:(NSString *)name userId:(NSString *)userId portraitUri:(NSString *)portraitUri;

@end
