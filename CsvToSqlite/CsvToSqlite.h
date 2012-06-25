#import <Foundation/Foundation.h>
#import <CsvToSqlite/CsvLineEndings.h>

@class CsvDefaultValues;

@interface CsvToSqlite : NSObject

@property ( nonatomic, strong, readonly  ) NSString*     databaseName  ;
@property ( nonatomic, strong, readonly  ) NSString*     dataFileName  ;
@property ( nonatomic, strong, readonly  ) NSDictionary* schema        ;
@property ( nonatomic, strong, readonly  ) NSOrderedSet* primaryKey    ;
@property ( nonatomic, strong, readwrite ) NSString*     csvDateFormat ;
@property ( nonatomic, strong, readonly  ) CsvDefaultValues* defaultValues;


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
      recordSeparatorChar:( char )separatorChar_;


-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_;

@end
