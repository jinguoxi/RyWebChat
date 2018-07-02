//
//  NSString+MD5.m
//  RyWebChat
//
//  Created by EliteCRM on 21/08/2017.
//  Copyright © 2017 nwkcom.sh.n22. All rights reserved.
//

#import "NSString+MD5.h"

@implementation NSString (MD5)

+ (NSString *) md5Hex : (NSString *) str;{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
