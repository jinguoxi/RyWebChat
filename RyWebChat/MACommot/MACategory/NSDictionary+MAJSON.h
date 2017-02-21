//
//  NSDictionary+MAJSON.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MAJSON)
- (NSString *)getString:(NSString *)key;

- (int)getInt:(NSString *)key;

- (long)getLong:(NSString *)key;

- (NSDictionary *)getObject:(NSString *)key;
@end
