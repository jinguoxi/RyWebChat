//
//  MAAgent.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAAgent.h"

@implementation MAAgent


+ (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri {
    MAAgent *agent = [MAAgent new];
    agent.userId = userId;
    agent.name = name;
    agent.portraitUri = portraitUri;
    
    return agent;
}
@end
