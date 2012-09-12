#import <CsvToSqlite/CsvToSqlite.h>

@class CsvDefaultValues;
@class CsvColumnsParser;
@protocol ESWritableDbWrapper;
@protocol LineReader;

@interface CsvToSqlite (Test)

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
            separatorChar:( char )separator_
              commentChar:( char )comment_
               lineReader:( id<LineReader> )reader_
           dbWrapperClass:( Class )dbWrapperClass_;

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;

@property ( nonatomic, strong ) NSDictionary* schema    ;
@property ( nonatomic, strong ) NSOrderedSet* primaryKey;

@property ( nonatomic, strong ) NSOrderedSet* csvSchema;
@property ( nonatomic, strong ) CsvDefaultValues* defaultValues;


@property ( nonatomic, strong ) CsvColumnsParser* columnsParser;
@property ( nonatomic, strong ) id<LineReader>    lineReader   ;
@property ( nonatomic, strong ) id<ESWritableDbWrapper>     dbWrapper    ;

@property ( nonatomic, strong ) NSDateFormatter* csvFormatter;
@property ( nonatomic, strong ) NSDateFormatter* ansiFormatter;



@end
