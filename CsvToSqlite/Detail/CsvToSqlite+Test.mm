#import "CsvToSqlite+Test.h"

#import "CsvMacros.h"

#import "DbWrapper.h"
#import "LineReader.h"
#import "CsvColumnsParser.h"


@implementation CsvToSqlite (Test)

@dynamic databaseName;
@dynamic dataFileName;

@dynamic schema    ;
@dynamic primaryKey;

@dynamic csvSchema    ;
@dynamic defaultValues;

@dynamic columnsParser;
@dynamic lineReader   ;
@dynamic dbWrapper    ;

@dynamic csvFormatter ;
@dynamic ansiFormatter;

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
            separatorChar:( char )separator_
              commentChar:( char )comment_
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

    self.defaultValues = defaults_;
    self.primaryKey = primaryKey_;
    self.lineReader = reader_;
    self.dbWrapper  = [ [ dbWrapperClass_ alloc ] initWithPath: databaseName_ ];
    self.columnsParser = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: separator_
                                                                    comment: comment_
                                                                 lineReader: reader_ ];

    self.ansiFormatter = [ ESLocaleFactory ansiDateFormatter  ];
    self.csvFormatter  = [ ESLocaleFactory posixDateFormatter ];
    
    return self;
}

@end
