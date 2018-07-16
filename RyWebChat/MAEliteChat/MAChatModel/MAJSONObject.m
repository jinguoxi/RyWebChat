//
//  MAJSONObject.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAJSONObject.h"
#import "MJExtension.h"

@interface MAJSONObject()

@property (strong, nonatomic) NSDictionary *jsonDic;

@end

@implementation MAJSONObject


+ (instancetype)initJSONObject:(NSString *)jsonStr {
    MAJSONObject *object = [MAJSONObject new];
    object.jsonDic = [jsonStr mj_JSONObject];
    return object;
}

- (NSString *)getString:(NSString *)key {
    return [self.jsonDic getString:key];
}

- (int)getInt:(NSString *)key {
    return [self.jsonDic getInt:key];
}

- (long)getLong:(NSString *)key {
    return [self.jsonDic getLong:key];
}

- (id)getObject:(NSString *)key {
    return [self.jsonDic getObject:key];
}

- (BOOL)objectForKey:(NSString *)key{
    return [[self.jsonDic objectForKey:key] boolValue];
}

@end
