#import <Foundation/Foundation.h>

@interface CsvToSqlite : NSObject

@property ( nonatomic, strong, readonly ) NSString* databaseName;
@property ( nonatomic, strong, readonly ) NSString* dataFileName;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_;

@end
