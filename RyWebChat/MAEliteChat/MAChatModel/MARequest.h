//
//  MARequest.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MARequest : NSObject

@property (assign, nonatomic) long requestId;

+ (instancetype)initWithRequestId:(long)requestId;

@end
