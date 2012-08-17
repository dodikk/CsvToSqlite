#import "CsvToSqlite.h"
#import "DbWrapper.h"

#include <string>
#include <vector>

@class StringsChannel;

@interface CsvToSqlite (Database)

-(id<DbWrapper>)castedWrapper;

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_;

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_;

-(void)beginTransaction;
-(void)commitTransaction;
-(void)rollbackTransaction;

-(void)closeDatabase;

@end

//use for format @"yyyyMMdd"
BOOL fastQueryLinesProducer1( const std::string& line_
                             , NSString* tableName_
                             , std::vector< char >& buffer_
                             , const char* headerFields_
                             , NSUInteger requeredNumOfColumns_
                             , CsvDefaultValues* defaultValues_
                             , NSOrderedSet* csvSchema_
                             , NSDictionary* schema_
                             , char separator_
                             , StringsChannel* queryChannel_
                             , NSError** errorPtr_ );

//use for format yyyy-MM-dd
BOOL queryLinesProducer2( CsvToSqlite* csvToSqlite_
                         , const std::string& line_
                         , NSString* tableName_
                         , StringsChannel* queryChannel_
                         , NSError** errorPtr_ );

BOOL generalQueryLinesProducer( CsvToSqlite* csvToSqlite_
                               , const std::string& line_
                               , NSString* tableName_
                               , std::vector< char >& buffer_
                               , StringsChannel* queryChannel_
                               , NSString* headerFields_
                               , NSUInteger requeredNumOfColumns_
                               , NSError** errorPtr_ );
