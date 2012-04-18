#import <Foundation/Foundation.h>
#import <CsvToSqlite/DbWrapper.h>

@interface MockDb : NSObject<DbWrapper>

-(NSArray*)queriesLog;

@end
