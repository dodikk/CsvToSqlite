#import <Foundation/Foundation.h>
#import <CsvToSqlite/CsvLineEndings.h>

#include <CsvToSqlite/CSVParserCallbacks.h>
#import <CsvToSqlite/Detail/StringProcessor.h>
@class CsvDefaultValues;

@interface CsvToSqlite : NSObject

@property ( nonatomic, readonly  ) NSString*     databaseName  ;
@property ( nonatomic, readonly  ) NSString*     dataFileName  ;
@property ( nonatomic, readonly  ) NSDictionary* schema        ;
@property ( nonatomic, readonly  ) NSOrderedSet* primaryKey    ;
@property ( nonatomic, readwrite ) NSString*     csvDateFormat ;
@property ( nonatomic, readonly  ) CsvDefaultValues* defaultValues;
@property ( nonatomic, copy      ) CSVOnCommentCallback onCommentCallback;


-(id)dbWrapper;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
          lineEndingStyle:( CsvLineEndings )lineEndingStyle_
      recordSeparatorChar:( char )separatorChar_
        recordCommentChar:( char )commentChar_;


-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_;

@end
