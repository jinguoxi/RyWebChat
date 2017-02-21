//
//  MARequest.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MARequest.h"

@implementation MARequest


+ (instancetype)initWithRequestId:(long)requestId {
    MARequest *request = [MARequest new];
    request.requestId = requestId;
    
    return request;
}
@end
