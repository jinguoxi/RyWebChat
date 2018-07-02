//
//  NSString+MD5.h
//  RyWebChat
//
//  Created by EliteCRM on 21/08/2017.
//  Copyright © 2017 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)
+ (NSString *) md5Hex : (NSString *) str;
@end
