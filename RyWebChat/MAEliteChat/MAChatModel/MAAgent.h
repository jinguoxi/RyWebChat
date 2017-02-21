//
//  MAAgent.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAAgent : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *portraitUri;

+ (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri;

@end
