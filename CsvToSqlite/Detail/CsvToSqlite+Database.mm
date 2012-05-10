#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvSchemaMismatchError.h"

#import "CsvColumnsParser.h"
#import "SqliteTypes.h"

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


-(BOOL)sqlSchemaHasDates
{
    __block BOOL result_ = NO;
    [ self.schema.allValues enumerateObjectsUsingBlock: ^(NSString* schemaType_, NSUInteger idx_, BOOL *stop_) 
    {
        if ( [ SqliteTypes isSqlDateType: schemaType_ ] )
        {
            result_ = YES;
            *stop_  = YES;
        }
    } ];

    return result_;
}


-(BOOL)parseAndStoreLine:( NSString* )line_
                 inTable:( NSString* )tableName_
                   error:( NSError** )errorPtr_
{
    NSParameterAssert( errorPtr_ != NULL );
    NSAssert( self.csvDateFormat, @"Csv date format not set" );
    
    
    NSOrderedSet* csvSchema_ = self.csvSchema;
    NSArray* lineRecords_ = [ line_ componentsSeparatedByString: self.columnsParser.separatorString ];
    if ( [ lineRecords_ count ] != [ csvSchema_ count ] )
    {
        *errorPtr_ = [ CsvSchemaMismatchError new ];
        return NO;
    }

    NSDate* date_ = nil;
    NSString* wrappedLineRecord_ = nil;
    
    NSDateFormatter* csvFormatter_ = [ ESLocaleFactory posixDateFormatter ];
    csvFormatter_.dateFormat = self.csvDateFormat;
    
    NSDateFormatter* sqlFormatter_ = [ ESLocaleFactory posixDateFormatter ];
    sqlFormatter_.dateFormat = @"yyyy-MM-dd";
    
    NSMutableArray* wrappedLine_ = [ NSMutableArray new ];

    
    NSUInteger i_ = 0;
    for ( NSString* lineRecord_ in lineRecords_ )
    {
        NSString* sqlType_ = [ self.schema objectForKey: [ csvSchema_ objectAtIndex: i_ ] ];
        if ( [ SqliteTypes isSqlDateType: sqlType_ ] )
        {
            date_ = [ csvFormatter_ dateFromString: lineRecord_ ];
            wrappedLineRecord_ = [ sqlFormatter_ stringFromDate: date_ ];
        }
        else
        {
            wrappedLineRecord_ = lineRecord_;
        }
        
        [ wrappedLine_ addObject: [ NSString stringWithFormat: @"'%@'", wrappedLineRecord_ ] ];

        ++i_;
    }

    
    
    NSString* insertFormat_ = @"INSERT INTO '%@' ( %@ ) VALUES ( %@ );";
    NSString* headerFields_ = [ self.csvSchema.array componentsJoinedByString: @", " ];
    NSString* values_ = [ wrappedLine_ componentsJoinedByString: @", " ];

    NSString* query_ = [ NSString stringWithFormat: insertFormat_, tableName_, headerFields_, values_ ];
    
    return [ [ self castedWrapper ] insert: query_
                                     error: errorPtr_ ];
}

-(BOOL)storeLineAsIs:(NSString *)line_ 
             inTable:(NSString *)tableName_ 
               error:(NSError *__autoreleasing *)errorPtr_
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

-(BOOL)storeLine:( NSString* )line_
         inTable:( NSString* )tableName_
           error:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  
    
    if ( [ self sqlSchemaHasDates ] )
    {
        return [ self parseAndStoreLine: line_ 
                                inTable: tableName_ 
                                  error: errorPtr_ ];
    }
    else 
    {
        return [ self storeLineAsIs: line_ 
                            inTable: tableName_ 
                              error: errorPtr_ ];
    }
}

-(void)closeDatabase
{
    [ [ self castedWrapper ] close ];
}

@end
