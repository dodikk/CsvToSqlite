#import "CsvToSqlite.h"

#import "CsvMacros.h"
#import "CsvBadTableNameError.h"

@interface CsvToSqlite()

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;
@property ( nonatomic, strong ) NSDictionary* schema  ;

@end


@implementation CsvToSqlite

@synthesize databaseName;
@synthesize dataFileName;
@synthesize schema      ;

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
   
   
   
   return YES;
}

@end
