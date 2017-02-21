//
//  MAJSONObject.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+MAJSON.h"

@interface MAJSONObject : NSObject

+ (instancetype)initJSONObject:(NSString *)jsonStr;

- (NSString *)getString:(NSString *)key;

- (int)getInt:(NSString *)key;

- (long)getLong:(NSString *)key;

- (id)getObject:(NSString *)key;

@end
