#import "NSString+Category.h"

@implementation NSString (Category)

- (NSArray *)splitStringWithSymbol:(NSString *)symbol {
    
    if (!self || [self isEqualToString:@""] || !symbol || [self isEqualToString:@""]) {
        NSException *e = [NSException exceptionWithName:@"NullPointerException" reason:@"self and symbol can't be nil or @\"\"" userInfo:nil];
        @throw e;
    }
    
    NSMutableArray *mutableArr = [NSMutableArray new];
    NSInteger length = symbol.length;
    NSString *tempStr = nil;
    
    for (int startIndex = 0, endIndex = 0; endIndex <= self.length - length; endIndex++) {
        
        tempStr = [self substringWithRange:NSMakeRange(endIndex, length)];
        if ([tempStr isEqualToString:symbol]) {
            NSString *splitedString = [self substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
            if (splitedString && ![splitedString isEqualToString:@""]) {
                [mutableArr addObject:splitedString];
            }
            startIndex = endIndex + (int)length;
        } else if (endIndex == self.length - length){
            NSString *splitedString = [self substringWithRange:NSMakeRange(startIndex, endIndex - startIndex + length)];
            if (splitedString && ![splitedString isEqualToString:@""]) {
                [mutableArr addObject:splitedString];
            }
        }
        
    }
    
    return [mutableArr copy];
}
@end
