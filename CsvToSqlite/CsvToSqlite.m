#import "CsvToSqlite.h"

#import "CsvMacros.h"

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

@end
