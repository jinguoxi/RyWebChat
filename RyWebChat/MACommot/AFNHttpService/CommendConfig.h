//
//  CommendConfig.h
//  IosProject
//
//  Created by nwk on 16/8/10.
//  Copyright © 2016年 ZZ. All rights reserved.
//  接口ID

#ifndef CommendConfig_h
#define CommendConfig_h

#import "MAFNetworkingTool.h"

#define SAVEDEFUAIL(obj,key) [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key]
#define GETDEFUAIL(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define REQUESTTIMEOUT 30 //超时

#endif
