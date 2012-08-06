#import "CsvToSqlite.h"
#import "DbWrapper.h"

#include <string>

@class StringsChannel;

typedef void (^StoreLineFunction)( const std::string& line_
                                  , NSString* tableName_
                                  , char* buffer_
                                  , const char* headerFieldsStr_
                                  , NSError** errorPtr_ );

@interface CsvToSqlite (Database)

-(id<DbWrapper>)castedWrapper;

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_;

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_;

-(BOOL)storeLine:( const std::string& )line_
         inTable:( NSString* )tableName_
          buffer:( char* )buffer_
    headerFields:( NSString* )headerFields_
requeredNumOfColumns:( NSUInteger )requeredNumOfColumns_
   stringChannel:( StringsChannel* )stringChannel_
           error:( NSError** )errorPtr_;

-(void)beginTransaction;
-(void)commitTransaction;
-(void)rollbackTransaction;

-(void)closeDatabase;

@end

//use for format @"yyyyMMdd"
BOOL fastStoreLine1( const std::string& line_
                    , NSString* tableName_
                    , char* buffer_
                    , const char* headerFields_
                    , NSUInteger requeredNumOfColumns_
                    , CsvDefaultValues* defaultValues_
                    , NSOrderedSet* csvSchema_
                    , NSDictionary* schema_
                    , char separator_
                    , StringsChannel* stringChannel_
                    , NSError** errorPtr_ );
