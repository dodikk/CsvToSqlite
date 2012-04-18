#import "CsvToSqlite.h"

@class CsvColumnsParser;
@protocol DbWrapper;
@protocol LineReader;

@interface CsvToSqlite (Test)

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            separatorChar:( char )separator_
               lineReader:( id<LineReader> )reader_
           dbWrapperClass:( Class )dbWrapperClass_;

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;

@property ( nonatomic, strong ) NSDictionary* schema    ;
@property ( nonatomic, strong ) NSOrderedSet* primaryKey;

@property ( nonatomic, strong ) NSOrderedSet* csvSchema;

@property ( nonatomic, strong ) CsvColumnsParser* columnsParser;
@property ( nonatomic, strong ) id<LineReader>    lineReader   ;
@property ( nonatomic, strong ) id<DbWrapper>     dbWrapper    ;

@end
