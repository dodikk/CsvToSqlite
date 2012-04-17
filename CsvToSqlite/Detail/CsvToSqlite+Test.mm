#import "CsvToSqlite+Test.h"

#import "CsvMacros.h"

#import "DbWrapper.h"
#import "LineReader.h"
#import "CsvColumnsParser.h"


@implementation CsvToSqlite (Test)

@dynamic databaseName;
@dynamic dataFileName;

@dynamic schema   ;
@dynamic csvSchema;

@dynamic columnsParser;
@dynamic lineReader   ;
@dynamic dbWrapper    ;


-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
            separatorChar:( char )separator_
               lineReader:( id<LineReader> )reader_
           dbWrapperClass:( Class )dbWrapperClass_
{
   self = [ super init ];
   
   INIT_ASSERT_EMPTY_STRING( databaseName_ );
   self.databaseName = databaseName_;
   
   INIT_ASSERT_EMPTY_STRING( dataFileName_ );
   self.dataFileName = dataFileName_;
   
   INIT_ASSERT_NIL( schema_ );
   self.schema = schema_;
   
   self.lineReader = reader_;
   self.dbWrapper  = [ [ dbWrapperClass_ alloc ] initWithPath: databaseName_ ];
   self.columnsParser = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: separator_
                                                                lineReader: reader_ ];

   return self;
}


@end