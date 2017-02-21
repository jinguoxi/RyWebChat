//
//  NSDictionary+MAJSON.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "NSDictionary+MAJSON.h"

@implementation NSDictionary (MAJSON)

- (NSString *)getString:(NSString *)key {
    return self[key];
}

- (int)getInt:(NSString *)key {
    return [self[key] intValue];
}

- (long)getLong:(NSString *)key {
    return [self[key] longValue];
}

- (NSDictionary *)getObject:(NSString *)key {
    return self[key];
}

@end
