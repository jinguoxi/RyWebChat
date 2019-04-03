#import "UnSendMessage.h"
#import "SQLiteManager.h"
#import "MaChat.h"

@implementation UnSendMessage

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(double)getDateTimeTOMilliSeconds
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    NSLog(@"转换的时间戳=%f",interval);
    return  interval*1000;
}

- (void)insertMessage:(NSString *) conversationType
{
    double currentDateLong = [self getDateTimeTOMilliSeconds];
    NSLog(@"%@   %f", conversationType, currentDateLong);
    // 1.通过属性拼接出来,插入语句
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO MaSaveMessage (target_id, conversation_type, object_name,content, sent_time) VALUES ('%@', '%@', '%@','%@', %f );", chatTargetId, conversationType, self.object_name, self.content, currentDateLong];
    // 2.执行该sql语句
    if ([[SQLiteManager shareInstance] execSQL:insertSQL]) {
        NSLog(@"插入数据成功");
    }
}

+ (NSArray *)loadData
{
    // 1.封装查询语句
//     order by sent_time desc;
    NSString *querySQL = @"SELECT guid, target_id, conversation_type, object_name,content, sent_time FROM MaSaveMessage order by guid;";
    return [self loadDataWithQuerySQL:querySQL];
}

+ (NSArray *)loadDataWithQuerySQL:(NSString *)querySQL
{
    // 2.执行查询语句
    NSArray *dictArray = [[SQLiteManager shareInstance] querySQL:querySQL];
    
    // 3.将数组中的字典转成模型对象
    NSMutableArray *stus = [NSMutableArray array];
    for (NSDictionary *dict in dictArray) {
        [stus addObject:[[UnSendMessage alloc] initWithDict:dict]];
    }
    return stus;
}
+ (void)deleteData: (NSString *) guid{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM MaSaveMessage where guid = '%@'", guid];
    if ([[SQLiteManager shareInstance] execSQL:deleteSql]) {
        NSLog(@"删除数据成功");
    }
}

@end
