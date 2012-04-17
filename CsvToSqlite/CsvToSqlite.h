#import <Foundation/Foundation.h>

@interface CsvToSqlite : NSObject

@property ( nonatomic, strong, readonly ) NSString* databaseName;
@property ( nonatomic, strong, readonly ) NSString* dataFileName;
@property ( nonatomic, strong, readonly ) NSDictionary* schema  ;


-(id)dbWrapper;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_;


-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_;

@end
