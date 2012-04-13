#import "CsvToSqlite.h"

#import "CsvColumnsParser.h"
#import "DBTableValidator.h"

#import "CsvSchemaMismatchError.h"
#import "CsvBadTableNameError.h"
#import "CsvInitializationError.h"

#import "CsvMacros.h"
#import "StreamUtils.h"
#include <fstream>

@interface CsvToSqlite()

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;

@property ( nonatomic, strong ) NSDictionary* schema   ;
@property ( nonatomic, strong ) NSSet*        csvSchema;

@property ( nonatomic, strong ) CsvColumnsParser* columnsParser;

@end


@implementation CsvToSqlite

@synthesize databaseName ;
@synthesize dataFileName ;
@synthesize schema       ;
@synthesize csvSchema    ;
@synthesize columnsParser;

-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
{
   self = [ super init ];

   INIT_ASSERT_EMPTY_STRING( databaseName_ );
   self.databaseName = databaseName_;

   INIT_ASSERT_EMPTY_STRING( dataFileName_ );
   self.dataFileName = dataFileName_;
   
   INIT_ASSERT_NIL( schema_ );
   self.schema = schema_;

   return self;
}

-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_
{
   if ( NULL == error_ )
   {
      NSString* errorMessage_ = @"[!!!ERROR!!!] : CsvToSqlite->storeDataInTable - NULL error not allowed";
      
      NSLog( @"%@", errorMessage_ );
      NSAssert( NO, errorMessage_ );
      return 0;
   }
   else if ( nil == tableName_ || @"" == tableName_ )
   {
      *error_ = [ CsvBadTableNameError new ];
      return NO;
   }
   else if ( nil == self.columnsParser )
   {
      *error_ = [ CsvInitializationError new ];
      return NO;
   }
   
   
   std::ifstream stream_;
   [ StreamUtils csvStream: stream_ withFilePath: self.dataFileName ];
   {
      NSOrderedSet* csvSchema_ = [ self.columnsParser parseColumnsFromStream: stream_ ];
      BOOL isValidSchema_ = [ DBTableValidator csvSchema: csvSchema_
                                      matchesTableSchema: self.schema ];
      
      if ( !isValidSchema_ )
      {
         *error_ = [ CsvSchemaMismatchError new ];
         return NO;
      }
      
      
   }
   stream_.close();
   
   return YES;
}

@end
