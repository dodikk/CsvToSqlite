#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvSchemaMismatchError.h"

#import "CsvColumnsParser.h"
#import "SqliteTypes.h"
#import "CsvDefaultValues.h"

#import "CsvMacros.h"

#import "NSString+Sqlite3Escape.h"

#import "StringsChannel.h"

#include <vector>
#include <string>
#include <sstream>

typedef std::string (^DateStringConverter)( const std::string &date_ );

static BOOL generalParseAndStoreLine( const std::string& line_
                                     , NSString* tableName_
                                     , DateStringConverter dateConverter_
                                     , char* buffer_
                                     , const char* headerFields_
                                     , NSUInteger requeredNumOfColumns_
                                     , CsvDefaultValues* defaultValues_
                                     , NSOrderedSet* csvSchema_
                                     , NSDictionary* schema_
                                     , char separator_
                                     , StringsChannel* stringChannel_
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
   
    NSString* query_ = [ NSString stringWithFormat: createFormat_, tableName_, columnsClause_ ];
   

   
    return [ db_ createTable: query_ 
                       error: errorPtr_ ];
}


-(BOOL)sqlSchemaHasDates
{
    __block BOOL result_ = NO;
    [ self.schema.allValues enumerateObjectsUsingBlock: ^(NSString* schemaType_, NSUInteger idx_, BOOL *stop_) 
    {
        if ( isSqlDateType( schemaType_ ) )
        {
            result_ = YES;
            *stop_  = YES;
        }
    } ];

    return result_;
}

-(BOOL)storeLineAsIs:( const std::string& )line_ 
             inTable:(NSString *)tableName_ 
               error:(NSError *__autoreleasing *)errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

    NSArray* headers_ = [ self.csvSchema.array arrayByAddingObjectsFromArray: self.defaultValues.columns.array ];   
    NSString* headerFields_ = [ headers_ componentsJoinedByString: @", " ];

    NSString* defaultValues_ = [ self.defaultValues.defaults componentsJoinedByString: @"', '" ];

    NSString* lineStr_ = [ @( line_.c_str() ) sqlite3Escape ];

    NSString* lineValues_ = [ lineStr_ stringByReplacingOccurrencesOfString: self.columnsParser.separatorString
                                                              withString: @"', '" ];
    NSString* values_ = [ lineValues_ stringByAppendingString: defaultValues_ ?: @"" ];

    NSString* query_;
    {
        static NSString* const insertFormat_ = @"INSERT INTO '%@' ( %@ ) VALUES ( '%@' );";
        query_ = [ NSString stringWithFormat: insertFormat_
                  , tableName_
                  , headerFields_
                  , values_ ];
    }

    return [ [ self castedWrapper ] insert: query_
                                     error: errorPtr_ ];
}

-(BOOL)storeLine:( const std::string& )line_
         inTable:( NSString* )tableName_
          buffer:( char* )buffer_
    headerFields:( NSString* )headerFields_
requeredNumOfColumns:( NSUInteger )requeredNumOfColumns_
   stringChannel:( StringsChannel* )stringChannel_
           error:( NSError** )errorPtr_
{
    NSAssert( errorPtr_, @"CsvToSqlite->nil error forbidden" );  

    BOOL isCsvHasAnsiFormat_ = [ self.csvDateFormat isEqualToString: @"yyyy-MM-dd" ];
    if ( !isCsvHasAnsiFormat_ && [ self sqlSchemaHasDates ] )
    {
        DateStringConverter dateConverter_ = ^std::string( const std::string & dateStr_ )
        {
            NSString* lineStr_ = @( dateStr_.c_str() );
            NSDate* date_ = [ self.csvFormatter dateFromString: lineStr_ ];
            NSString* result_ = [ self.ansiFormatter stringFromDate: date_ ];
            return std::string( [ result_ cStringUsingEncoding: NSUTF8StringEncoding ] );
        };
        return generalParseAndStoreLine( line_ 
                                        , tableName_
                                        , dateConverter_
                                        , buffer_
                                        , [ headerFields_ cStringUsingEncoding: NSUTF8StringEncoding ]
                                        , requeredNumOfColumns_
                                        , self.defaultValues
                                        , self.csvSchema
                                        , self.schema
                                        , self.columnsParser->_separator
                                        , stringChannel_
                                        , errorPtr_ );
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

BOOL fastStoreLine1( const std::string& line_
                    , NSString* tableName_
                    , char* buffer_
                    , const char* headerFields_
                    , NSUInteger requeredNumOfColumns_
                    , CsvDefaultValues* defaultValues_
                    , NSOrderedSet* csvSchema_
                    , NSDictionary* schema_
                    , char separator_
                    , StringsChannel* stringChannel_
                    , NSError** errorPtr_ )
{
    DateStringConverter dateConverter_ = ^std::string( const std::string & dateStr_ )
    {
        auto year_  = dateStr_.substr( 0, 4 );
        auto month_ = dateStr_.substr( 4, 2 );
        auto day_   = dateStr_.substr( 6, 2 );
        return year_ + "-" + month_ + "-" + day_;
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
                                    , stringChannel_
                                    , errorPtr_ );
}

static BOOL generalParseAndStoreLine( const std::string& line_
                                     , NSString* tableName_
                                     , DateStringConverter dateConverter_
                                     , char* buffer_
                                     , const char* headerFields_
                                     , NSUInteger requeredNumOfColumns_
                                     , CsvDefaultValues* defaultValues_
                                     , NSOrderedSet* csvSchema_
                                     , NSDictionary* schema_
                                     , char separator_
                                     , StringsChannel* stringChannel_
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

    for ( std::vector< std::string >::iterator it_ = lineRecords_.begin(); 
         it_ != lineRecords_.end();
         ++it_ )
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
            wrappedLineRecord_ = dateConverter_( *it_ );
        }
        else
        {
            wrappedLineRecord_ = *it_;
        }

        char* cStrResultSQL_ = sqlite3_mprintf( "%q", wrappedLineRecord_.c_str() );
        wrappedLine_.push_back( std::string( "'" ) + cStrResultSQL_ + "'" );
        sqlite3_free( cStrResultSQL_ );

        ++i_;
    }

    std::string values_;
    {
        std::stringstream ss;
        for( size_t i = 0; i < wrappedLine_.size(); ++i )
        {
            if( i != 0 )
                ss << ", ";
            ss << wrappedLine_[i];
        }
        values_ = ss.str();
    }

    sprintf ( buffer_, "INSERT OR IGNORE INTO '%s' ( %s ) VALUES ( %s );"
             , [ tableName_ cStringUsingEncoding: NSUTF8StringEncoding ]
             , headerFields_
             , values_.c_str() );

    [ stringChannel_ putString: buffer_ ];

    return YES;
}
