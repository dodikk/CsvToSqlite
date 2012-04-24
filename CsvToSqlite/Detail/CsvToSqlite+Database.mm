#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvColumnsParser.h"

#import "CsvMacros.h"


@implementation CsvToSqlite (Database)

-(id<DbWrapper>)castedWrapper
{
    return (id<DbWrapper>)[ self dbWrapper ];
}

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );

    id<DbWrapper> db_ = [ self castedWrapper ];
    BOOL result_ = [ db_ open ];

    if ( !result_ )
    {
        *errorPtr_ = [ [ db_ lastError ] copy ];
        return NO;
    }
    
    return YES;
}


-(NSString*)primaryKeyConstraint
{
    NSString* primaryKeyFormat_ = @", CONSTRAINT pkey PRIMARY KEY ( %@ )";
    NSString* pkeyColumns_ = [ self.primaryKey.array componentsJoinedByString: @", " ];

    NSString* result_ = [ NSString stringWithFormat: primaryKeyFormat_, pkeyColumns_ ];

    return result_;
}

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

    id<DbWrapper> db_ = [ self castedWrapper ];
    if ( [ db_ tableExists: tableName_ ] )
    {
        return YES;
    }

    NSString* createFormat_ = @"CREATE TABLE [%@] ( %@ );";
    NSString* columnFormat_ = @"[%@] %@";

    NSMutableString* columns_ = [ NSMutableString new ];

   __block BOOL processingFirstItem_ = YES;

    [ self.schema enumerateKeysAndObjectsUsingBlock: ^( NSString* columnName_, NSString* columnType_, BOOL* stop_ )
    {
        if ( processingFirstItem_ )
        {
            processingFirstItem_ = NO;
        }
        else 
        {
            [ columns_ appendString: @", " ];
        }

        [ columns_ appendFormat: columnFormat_, columnName_, columnType_ ];
        *stop_ = NO;
    } ];

    NSString* columnsClause_ = [ [ NSString alloc ] initWithString: columns_  ];
    if ( nil != self.primaryKey )
    {
        NSString* pkeyClause_ = [ self primaryKeyConstraint ];
        columnsClause_ = [ columnsClause_ stringByAppendingString: pkeyClause_ ];
    }
   
    NSString* query_ = [ NSString stringWithFormat: createFormat_, tableName_, columnsClause_ ];
   

   
    return [ db_ createTable: query_ 
                       error: errorPtr_ ];
}

-(BOOL)storeLine:( NSString* )line_
         inTable:( NSString* )tableName_
           error:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

   
    NSString* insertFormat_ = @"INSERT INTO '%@' ( %@ ) VALUES ( '%@' );";


    NSString* headerFields_ = [ self.csvSchema.array componentsJoinedByString: @", " ];
    NSString* values_ = [ line_ stringByReplacingOccurrencesOfString: self.columnsParser.separatorString
                                                          withString: @"', '" ];


    NSString* query_ = [ NSString stringWithFormat: insertFormat_, tableName_, headerFields_, values_ ];

    return [ [ self castedWrapper ] insert: query_
                                     error: errorPtr_ ];
}

-(void)closeDatabase
{
    [ [ self castedWrapper ] close ];
}

@end
