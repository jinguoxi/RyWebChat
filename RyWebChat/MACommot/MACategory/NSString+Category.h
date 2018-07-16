#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 *  根据分隔符,分隔字符串
 *
 *  @param symbol 分隔符
 *
 *  @return 由被分隔完的字串组成的数组
 */
- (NSArray *)splitStringWithSymbol:(NSString *)symbol;

@end
