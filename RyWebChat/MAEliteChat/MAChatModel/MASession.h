//
//  MASession.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAAgent.h"

@interface MASession : NSObject

@property (strong, nonatomic) MAAgent *currentAgent;
@property (assign, nonatomic) long sessionId;

+ (instancetype)initWithSessionId:(long)sessionId agent:(MAAgent *)currentAgent;

@end
