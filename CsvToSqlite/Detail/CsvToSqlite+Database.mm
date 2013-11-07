#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvSchemaMismatchError.h"

#import "CsvColumnsParser.h"
#import "CsvDefaultValues.h"

#import "CsvMacros.h"
#import "StringsChannel.h"

typedef std::vector<std::string> string_vt;

using namespace ::Utils;

static const std::string STL_QUOTE( "'" );

typedef void (^DateStringConverter)( const std::string &date_, std::string& result_ );

static string_vt &split(const std::string &s, char delim, string_vt &elems) {
    std::stringstream ss(s);
    std::string item;
    while(std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
    if ( s[ s.size() - 1 ] == delim )
    {
        elems.push_back("");
    }
    return elems;
}

static string_vt split(const std::string &s, char delim) {
    string_vt elems;
    return split(s, delim, elems);
}

@implementation CsvToSqlite (Database)

@dynamic headerFieldsForInsert;
@dynamic defaultValuesForInsert;


-(id<ESWritableDbWrapper>)castedWrapper
{
    return (id<ESWritableDbWrapper>)[ self dbWrapper ];
}

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );

    id<ESWritableDbWrapper> db_ = [ self castedWrapper ];
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

    NSString* result_ = [ [ NSString alloc ] initWithFormat: primaryKeyFormat_, pkeyColumns_ ];

    return result_;
}

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

    id<ESWritableDbWrapper> db_ = [ self castedWrapper ];
    if ( [ db_ tableExists: tableName_ ] )
    {
        return YES;
    }

    static NSString* const createFormat_ = @"CREATE TABLE [%@] ( %@ );";
    static NSString* const columnFormat_ = @"[%@] %@";

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

    NSString* query_ = [ [ NSString alloc ] initWithFormat: createFormat_, tableName_, columnsClause_ ];

    return [ db_ createTable: query_ 
                       error: errorPtr_ ];
}

-(NSString*)computeHeaderFieldsForInsert
{
    NSArray* headers_ = [ self.csvSchema.array arrayByAddingObjectsFromArray: self.defaultValues.columns.array ];
    NSString* headerFields_ = [ headers_ componentsJoinedByString: @", " ];
    
    return headerFields_;
}

-(NSString*)computeDefaultValuesForInsert
{
    NSString* defaultValues_ = [ self.defaultValues.defaults componentsJoinedByString: @"', '" ];
    return defaultValues_;
}

-(BOOL)storeLineAsIs:( const std::string& )line_
             inTable:(NSString *)tableName_
       stringChannel:( StringsChannel* )queryChannel_
               error:(NSError *__autoreleasing *)errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

    NSString* headerFields_ = self.headerFieldsForInsert;
    NSString* defaultValues_ = self.defaultValuesForInsert;

    
    NSString* lineStr_ = [ NSString sqlite3EscapeString: @( line_.c_str() ) ];

    NSString* lineValues_ = [ lineStr_ stringByReplacingOccurrencesOfString: self.columnsParser.separatorString
                                                              withString: @"', '" ];
    NSString* values_ = [ lineValues_ stringByAppendingString: defaultValues_ ?: @"" ];

    NSString* query_;
    {
        static NSString* const insertFormat_ = @"INSERT INTO '%@' ( %@ ) VALUES ( '%@' );";
        query_ = [ [ NSString alloc ] initWithFormat: insertFormat_
                  , tableName_
                  , headerFields_
                  , values_ ];
    }

    [ queryChannel_ putString: [ query_ cStringUsingEncoding: NSUTF8StringEncoding ] ];

    return YES;
}

-(void)closeDatabase
{
    [ [ self castedWrapper ] close ];
}


#pragma mark -
#pragma mark Transactions

-(void)beginTransaction
{
    [ [ self castedWrapper ] insert: @"BEGIN TRANSACTION;" 
                              error: NULL ];
}

-(void)commitTransaction
{
    [ [ self castedWrapper ] insert: @"COMMIT TRANSACTION;"
                              error: NULL ];
}

-(void)rollbackTransaction
{
    [ [ self castedWrapper ] insert: @"ROLLBACK TRANSACTION;"
                              error: NULL ];    
}

@end


void generalParseAndStoreLine( const std::string& line_
                                     , NSString* tableName_
                                     , std::vector< char >& buffer_
                                     , const char* headerFields_
                                     , StringsChannel* queryChannel_
                                     , NSError** errorPtr_ )
{
    static const char* insertFormat_ = "INSERT INTO '%s' ( %s ) %s;";
    const char* tableNameCStr_ = [ tableName_ cStringUsingEncoding: NSUTF8StringEncoding ];
    
    int requiredBufferSize_ = ::snprintf ( NULL, 0, insertFormat_
                                          , tableNameCStr_
                                          , headerFields_
                                          , line_.c_str() );
    
    if ( requiredBufferSize_ + 1 > buffer_.size() )
    {
        buffer_.resize( (size_t)requiredBufferSize_ + 1 );
    }
    
    ::sprintf ( &buffer_[ 0 ], insertFormat_
               , tableNameCStr_
               , headerFields_
               , line_.c_str() );
    
    [ queryChannel_ putString: &buffer_[ 0 ] ];
}
