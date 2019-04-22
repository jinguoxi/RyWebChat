//
//  MAClient.m
//  SocketDemo
//
//  Created by nwk on 2016/12/16.
//  Copyright © 2016年 nwkcom.sh.n22. All rights reserved.
//

#import "MAClient.h"

@interface MAClient()

@property (strong, nonatomic, readwrite) NSString *serverAddr;
@property (strong, nonatomic, readwrite) NSString *ngsAddr;
@property (strong, nonatomic, readwrite) NSString *userId;
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *portraitUri;
@property (strong, nonatomic, readwrite) NSString *tokenStr;
@property (strong, nonatomic, readwrite) NSArray *tracks;

@end

@implementation MAClient

+ (instancetype)initWithServerAddr:(NSString *)serverAddr ngsAddr:(NSString *)ngsAddr name:(NSString *)name userId:(NSString *)userId portraitUri:(NSString *)portraitUri tracks:(NSArray *)tracks{
    MAClient *client = [[MAClient alloc] init];
    
    client.serverAddr = serverAddr;
    client.ngsAddr = ngsAddr;
    client.name = name;
    client.userId = userId;
    client.portraitUri = portraitUri;
    client.tracks = tracks;
    return client;
}
@end
