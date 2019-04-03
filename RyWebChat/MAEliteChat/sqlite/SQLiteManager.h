#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject

+ (instancetype)shareInstance;

- (BOOL)openDB;

- (BOOL)execSQL:(NSString *)sql;

- (NSArray *)querySQL:(NSString *)querySQL;

@end
