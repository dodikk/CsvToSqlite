#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvSchemaMismatchError.h"

#import "CsvColumnsParser.h"
#import "CsvDefaultValues.h"

#import "CsvMacros.h"
#import "StringsChannel.h"

#include <vector>
#include <string>
#include <sstream>

using namespace ::Utils;

static const std::string STL_QUOTE( "'" );

typedef void (^DateStringConverter)( const std::string &date_, std::string& result_ );

static BOOL generalParseAndStoreLine( const std::string& line_
                                     , NSString* tableName_
                                     , DateStringConverter dateConverter_
                                     , std::vector< char >& buffer_
                                     , const char* headerFields_
                                     , NSUInteger requeredNumOfColumns_
                                     , CsvDefaultValues* defaultValues_
                                     , NSOrderedSet* csvSchema_
                                     , NSDictionary* schema_
                                     , char separator_
                                     , StringsChannel* queryChannel_
                                     , NSError** errorPtr_ );

static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems) {
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

static std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
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

BOOL fastQueryLinesProducer1( const std::string& line_
                             , NSString* tableName_
                             , std::vector< char >& buffer_
                             , const char* headerFields_
                             , NSUInteger requeredNumOfColumns_
                             , CsvDefaultValues* defaultValues_
                             , NSOrderedSet* csvSchema_
                             , NSDictionary* schema_
                             , char separator_
                             , StringsChannel* queryChannel_
                             , NSError** errorPtr_ )
{
    DateStringConverter dateConverter_ = ^void( const std::string& dateStr_, std::string& result_ )
    {
        // Performance optimization.
        // Twice faster than commented code below

        result_.resize( 10, '-' );
        
        result_[0] = dateStr_[0];
        result_[1] = dateStr_[1];
        result_[2] = dateStr_[2];
        result_[3] = dateStr_[3];
        
        
        result_[5] = dateStr_[4];
        result_[6] = dateStr_[5];
        
        result_[8] = dateStr_[6];
        result_[9] = dateStr_[7];

//        auto year_  = dateStr_.substr( 0, 4 );
//        auto month_ = dateStr_.substr( 4, 2 );
//        auto day_   = dateStr_.substr( 6, 2 );
//
//        result_ = year_ + "-" + month_ + "-" + day_;
    };

    return generalParseAndStoreLine( line_ 
                                    , tableName_
                                    , dateConverter_
                                    , buffer_
                                    , headerFields_
                                    , requeredNumOfColumns_
                                    , defaultValues_
                                    , csvSchema_
                                    , schema_
                                    , separator_
                                    , queryChannel_
                                    , errorPtr_ );
}

static BOOL generalParseAndStoreLine( const std::string& line_
                                     , NSString* tableName_
                                     , DateStringConverter dateConverter_
                                     , std::vector< char >& buffer_
                                     , const char* headerFields_
                                     , NSUInteger requeredNumOfColumns_
                                     , CsvDefaultValues* defaultValues_
                                     , NSOrderedSet* csvSchema_
                                     , NSDictionary* schema_
                                     , char separator_
                                     , StringsChannel* queryChannel_
                                     , NSError** errorPtr_ )
{
    assert( errorPtr_ != NULL );

    NSOrderedSet* defaultColumns_ = defaultValues_.columns;

    std::vector<std::string> lineRecords_ = split( line_, separator_ );

    if ( lineRecords_.size() != requeredNumOfColumns_ )
    {
        *errorPtr_ = [ CsvSchemaMismatchError new ];
        return NO;
    }

    std::string wrappedLineRecord_;
    std::vector<std::string> wrappedLine_;

    NSUInteger i_        = 0;
    NSString* tmpHeader_ = nil;
    NSString* sqlType_   = nil;
    NSUInteger csvCount_ = [ csvSchema_ count ];

    for ( auto it_ = lineRecords_.begin(); it_ != lineRecords_.end(); ++it_ )
    {
        if ( i_ < csvCount_ )
        {
            tmpHeader_ = [ csvSchema_ objectAtIndex: i_ ];
        }
        else
        {
            tmpHeader_ = [ defaultColumns_ objectAtIndex: i_ - csvCount_ ];
        }
        sqlType_ = [ schema_ objectForKey: tmpHeader_ ];

        if ( isSqlDateType( sqlType_ ) )
        {
            dateConverter_( *it_, wrappedLineRecord_ );
        }
        else
        {
            wrappedLineRecord_ = *it_;
        }

        char* cStrResultSQL_ = sqlite3_mprintf( "%q", wrappedLineRecord_.c_str() );
        ObjcScopedGuard sqlitePrintfGuard_
        (
           ^void(){ sqlite3_free( cStrResultSQL_ ); }
        );
        wrappedLine_.push_back( STL_QUOTE + cStrResultSQL_ + STL_QUOTE );
        sqlite3_free( cStrResultSQL_ );
        sqlitePrintfGuard_.Release();
        
        ++i_;
    }

    std::string values_;
    {
        std::stringstream ss;
        for( size_t i = 0; i < wrappedLine_.size(); ++i )
        {
            if( i != 0 )
            {
                ss << ", ";
            }
            ss << wrappedLine_[i];
        }
        values_ = ss.str();
    }

    static const char* insertFormat_ = "INSERT OR IGNORE INTO '%s' ( %s ) VALUES ( %s );";
    const char* tableNameCStr_ = [ tableName_ cStringUsingEncoding: NSUTF8StringEncoding ];

    int requiredBufferSize_ = snprintf ( NULL, 0, insertFormat_
                                       , tableNameCStr_
                                       , headerFields_
                                       , values_.c_str() );

    if ( requiredBufferSize_ + 1 > buffer_.size() )
    {
        buffer_.resize( (size_t)requiredBufferSize_ + 1 );
    }

    sprintf ( &buffer_[ 0 ], insertFormat_
             , tableNameCStr_
             , headerFields_
             , values_.c_str() );

    [ queryChannel_ putString: &buffer_[ 0 ] ];

    return YES;
}

BOOL queryLinesProducer2( CsvToSqlite* csvToSqlite_
                         , const std::string& line_
                         , NSString* tableName_
                         , StringsChannel* queryChannel_
                         , NSError** errorPtr_ )
{
    return [ csvToSqlite_ storeLineAsIs: line_
                                inTable: tableName_
                          stringChannel: queryChannel_
                                  error: errorPtr_ ];
}

BOOL generalQueryLinesProducer( CsvToSqlite* csvToSqlite_
                               , const std::string& line_
                               , NSString* tableName_
                               , std::vector< char >& buffer_
                               , StringsChannel* queryChannel_
                               , NSString* headerFields_
                               , NSUInteger requeredNumOfColumns_
                               , NSError** errorPtr_ )
{
    DateStringConverter dateConverter_ = ^void( const std::string & dateStr_, std::string& result_ )
    {
        NSString* lineStr_ = @( dateStr_.c_str() );
        NSDate* date_ = [ csvToSqlite_.csvFormatter dateFromString: lineStr_ ];
        NSString* resultStr_ = [ csvToSqlite_.ansiFormatter stringFromDate: date_ ];

        result_ = [ resultStr_ cStringUsingEncoding: NSUTF8StringEncoding ];
    };
    return generalParseAndStoreLine( line_
                                    , tableName_
                                    , dateConverter_
                                    , buffer_
                                    , [ headerFields_ cStringUsingEncoding: NSUTF8StringEncoding ]
                                    , requeredNumOfColumns_
                                    , csvToSqlite_.defaultValues
                                    , csvToSqlite_.csvSchema
                                    , csvToSqlite_.schema
                                    , csvToSqlite_.columnsParser->_separator
                                    , queryChannel_
                                    , errorPtr_ );
}
