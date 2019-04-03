#import "SQLiteManager.h"
#import <sqlite3.h>

@interface SQLiteManager ()

@property (nonatomic, assign) sqlite3 *db;

@end

@implementation SQLiteManager

static id _instance;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}



-(BOOL)openDB{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * destinationPath = [NSString stringWithFormat:@"%@/message.sql",path];
    if(sqlite3_open([destinationPath UTF8String], &_db) != SQLITE_OK){
        NSLog(@"打开数据库失败");
    }//; //通过UTF8String转化，返回const char类型 //&dbPoint是地址，指向sqlite的指针
    return [self createTable];
}

- (BOOL)createTable {
    // 1.定义创建表的SQL语句
    NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS 'MASaveMessage' ('guid' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 'target_id', TEXT, conversation_type TEXT, 'object_name' TEXT,'content' TEXT, sent_time double);";
    // 2.执行SQL语句
    return [self execSQL:createTableSQL];
}

- (BOOL)execSQL:(NSString *)sql
{
    // 执行sql语句
    // 1> 参数一:数据库sqlite3对象
    // 2> 参数二:执行的sql语句
    return sqlite3_exec(self.db, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
}

#pragma mark - 查询数据
- (NSArray *)querySQL:(NSString *)querySQL
{
    // 定义游标对象
    sqlite3_stmt *stmt = nil;
    
    // 准备工作(获取查询的游标对象)
    // 1> 参数三:查询语句的长度, -1自动计算
    // 2> 参数四:查询的游标对象地址
    if (sqlite3_prepare_v2(self.db, querySQL.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
        NSLog(@"没有准备成功");
        return nil;
    }
    
    // 取出某一个行数的数据
    NSMutableArray *tempArray = [NSMutableArray array];
    // 获取字段的个数
    int count = sqlite3_column_count(stmt);
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int i = 0; i < count; i++) {
            // 1.取出当前字段的名称(key)
            NSString *key = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
            
            // 2.取出当前字段对应的值(value)
            const char *cValue = (const char *)sqlite3_column_text(stmt, i);
            NSString *value = [NSString stringWithUTF8String:cValue];
            
            // 3.将键值对放入字典中
            [dict setObject:value forKey:key];
        }
        
        [tempArray addObject:dict];
    }
    
    // 不再使用游标时,需要释放对象
    sqlite3_finalize(stmt);
    
    return tempArray;
}

@end
