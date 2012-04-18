#import <Foundation/Foundation.h>
#import <CsvToSqlite/CsvLineEndings.h>

@interface CsvToSqlite : NSObject

@property ( nonatomic, strong, readonly ) NSString* databaseName  ;
@property ( nonatomic, strong, readonly ) NSString* dataFileName  ;
@property ( nonatomic, strong, readonly ) NSDictionary* schema    ;
@property ( nonatomic, strong, readonly ) NSOrderedSet* primaryKey;

-(id)dbWrapper;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
          lineEndingStyle:( CsvLineEndings )lineEndingStyle_
      recordSeparatorChar:( char )separatorChar_;


-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_;

@end
