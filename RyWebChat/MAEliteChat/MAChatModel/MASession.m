//
//  MASession.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MASession.h"

@implementation MASession

+ (instancetype)initWithSessionId:(long)sessionId agent:(MAAgent *)currentAgent robotMode:(BOOL)robotMode{
    MASession *session = [MASession new];
    session.sessionId = sessionId;
    session.currentAgent = currentAgent;
    session.robotMode = robotMode;
    return session;
}
@end
