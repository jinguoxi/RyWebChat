#import <Foundation/Foundation.h>

@interface UnSendMessage : NSObject

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, assign) NSString *conversation_type;
@property (nonatomic, copy) NSString *object_name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) double sent_time;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (void)insertMessage : (NSString *) conversationType;

+ (NSArray *)loadData;
+ (void)deleteData:(NSString *)guid;

@end
