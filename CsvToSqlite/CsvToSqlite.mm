#import "CsvToSqlite.h"
#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvColumnsParser.h"
#import "DBTableValidator.h"

#import "CsvSchemaMismatchError.h"
#import "CsvBadTableNameError.h"
#import "CsvInitializationError.h"

#import "CsvMacros.h"
#import "StreamUtils.h"

#import "WindowsLineReader.h"
#import "UnixLineReader.h"
#import "FMDatabase.h"
#import "CsvDefaultValues.h"
#import "StringsChannel.h"

#import "CsvToSqlite+QueryLinesProducerFactory.h"

#include <map>
#include <fstream>
#include <ObjcScopedGuard/ObjcScopedGuard.h>

using namespace ::Utils;

@interface CsvToSqlite()
{
    NSError* _outErrorHolderCrashWorkaround;
}

@property ( nonatomic ) NSString* databaseName;
@property ( nonatomic ) NSString* dataFileName;

@property ( nonatomic ) NSDictionary* schema    ;
@property ( nonatomic ) NSOrderedSet* primaryKey;

@property ( nonatomic ) NSOrderedSet* csvSchema;
@property ( nonatomic ) CsvDefaultValues* defaultValues;

@property ( nonatomic ) NSDateFormatter* csvFormatter ;
@property ( nonatomic ) NSDateFormatter* ansiFormatter;

@property ( nonatomic ) CsvColumnsParser* columnsParser;
@property ( nonatomic ) id<LineReader>    lineReader   ;
@property ( nonatomic ) id<ESWritableDbWrapper>     dbWrapper    ;

@property ( nonatomic ) NSString* headerFieldsForInsert;
@property ( nonatomic ) NSString* defaultValuesForInsert;

@end

@implementation CsvToSqlite

-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
          lineEndingStyle:( CsvLineEndings )lineEndingStyle_
      recordSeparatorChar:( char )separatorChar_
        recordCommentChar:( char )commentChar_
{
    static dispatch_once_t onceToken_;
    static std::map< CsvLineEndings, Class > lineEndingsMap_;
    
    dispatch_once( &onceToken_, ^
    {
    
        if ( lineEndingsMap_.empty() )
        {
            lineEndingsMap_[ CSV_LE_WIN  ] = [ WindowsLineReader class ];
            lineEndingsMap_[ CSV_LE_UNIX ] = [ UnixLineReader    class ];
        }
  
    });
                  
    Class readerClass_ = lineEndingsMap_[ lineEndingStyle_ ];
    if ( nil == readerClass_ )
    {
        NSLog( @"Unsupported line endings style : %d", lineEndingStyle_ );
        return nil;
    }

    return [ self initWithDatabaseName: databaseName_
                          dataFileName: dataFileName_ 
                        databaseSchema: schema_
                            primaryKey: primaryKey_
                         defaultValues: defaults_
                         separatorChar: separatorChar_
                           commentChar: commentChar_
                            lineReader: [ readerClass_ new ]
                        dbWrapperClass: [ FMDatabase class ] ];
}


-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
{
    CsvToSqlite* result_ =  [ self initWithDatabaseName: databaseName_
                                           dataFileName: dataFileName_
                                         databaseSchema: schema_
                                             primaryKey: primaryKey_
                                          defaultValues: defaults_
                                        lineEndingStyle: CSV_LE_WIN
                                    recordSeparatorChar: ';'
                                      recordCommentChar: '#' ];
    result_.csvDateFormat = @"yyyyMMdd";

    return result_;
}

-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
{
    return [ self initWithDatabaseName: databaseName_
                          dataFileName: dataFileName_
                        databaseSchema: schema_
                            primaryKey: primaryKey_
                         defaultValues: nil ];
}

-(BOOL)executeSqliteQueries:( StringsChannel* )queryChannel_
                  tableName:( NSString* )tableName_
                      error:( NSError** )error_
{
    NSParameterAssert( error_ != NULL );

    [ self openDatabaseWithError: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );

    __weak CsvToSqlite* weakSelf_ = self;
    GuardCallbackBlock closeDbBlock_ = ^
    {
        [ weakSelf_ closeDatabase ];
    };
    ObjcScopedGuard dbGuard_( closeDbBlock_ );
    

    id<ESWritableDbWrapper> castedWrapper_ = [ self castedWrapper ];

    [ self createTableNamed: tableName_
                      error: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );

    

    GuardCallbackBlock rollbackTransactionBlock_ = ^
    {
        [ weakSelf_ rollbackTransaction ];
    };
    ObjcScopedGuard transactionGuard_( rollbackTransactionBlock_ );
    [ self beginTransaction ];
    
    
    std::string queryStr_ = [ queryChannel_ popString ];
    while ( !queryStr_.empty() )
    {
        @autoreleasepool
        {
            char* rawQueryStr_ = const_cast<char*>( queryStr_.c_str() );
            void* vpQueryStr_  = reinterpret_cast<void*>( rawQueryStr_ );
            NSUInteger castedLength_ = static_cast<NSUInteger>( queryStr_.length() );

            NSString* query_ = [ [ NSString alloc ] initWithBytesNoCopy: vpQueryStr_
                                                                 length: castedLength_
                                                               encoding: NSUTF8StringEncoding
                                                           freeWhenDone: NO ];

            [ castedWrapper_ insert: query_
                              error: error_ ];

            if ( *error_ )
            {
                return NO;
            }

            queryStr_ = [ queryChannel_ popString ];
        }
    }


    [ self commitTransaction ];
    transactionGuard_.Release();

    return YES;
}

-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_
{
    if ( NULL == error_ )
    {
        NSString* errorMessage_ = @"[!!!ERROR!!!] : CsvToSqlite->storeDataInTable - NULL error not allowed";

        NSLog( @"%@", errorMessage_ );
        NSAssert( NO, errorMessage_ );
        return NO;
    }
    else if ( nil == tableName_ || [ @"" isEqualToString: tableName_ ] )
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
    std::ifstream* pStream_ = &stream_;
    GuardCallbackBlock streamGuardBlock_ = ^
    {
        pStream_->close();
    };
    ObjcScopedGuard streamGuard_( streamGuardBlock_ );

    [ StreamUtils csvStream: stream_ withFilePath: self.dataFileName ];

    self.columnsParser.onCommentCallback = self->_onCommentCallback;
    NSOrderedSet* csvSchema_ = [ self.columnsParser parseColumnsFromStream: stream_ ];

    BOOL isEmptySchema_ = ( 0 == [ csvSchema_ count ] );
    if ( isEmptySchema_ )
    {
        // @adk - Empty tables have no schema and are considered as successful import
        return YES;
    }
    
    BOOL isValidSchema_ = [ DBTableValidator csvSchema: csvSchema_
                                          withDefaults: self.defaultValues
                                    matchesTableSchema: self.schema ];
    if ( !isValidSchema_ )
    {
        *error_ = [ CsvSchemaMismatchError new ];
        return NO;
    }
    self.csvSchema = csvSchema_;

    std::vector< char > buffer_( 1024*4, 0 );

    StringsChannel* queryChannel_ = [ StringsChannel newStringsChannelWithSize: 100 ];

    QueryLineProducer storeLine_ = [ self queryLinesProducerWithQueryChannel: queryChannel_ ];

    dispatch_group_t group_ = dispatch_group_create();
    dispatch_queue_t queue_ = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_group_async( group_, queue_, ^
    {
        NSError* localError_;
        @autoreleasepool
        {
            [ self executeSqliteQueries: queryChannel_
                              tableName: tableName_
                                  error: &localError_ ];

            if ( localError_ )
            {
                *error_ = localError_;
                self->_outErrorHolderCrashWorkaround = *error_;                
            }
        }
    } );

    GuardCallbackBlock relleaseGroupGuardBlock_ = ^
    {
        dispatch_release( group_ );
    };
    ObjcScopedGuard relleaseGroup_( relleaseGroupGuardBlock_ );

    std::string line_;

    while ( !stream_.eof() )
    {
        @autoreleasepool
        {
            BOOL isLineComment_ = ( line_[ 0 ] == self.columnsParser->_comment );

            [ self.lineReader readLine: line_ 
                            fromStream: stream_ ];

            if ( line_.empty() )
            {
                // TODO : maybe we should skip empty lines and use CONTINUE
                // At the moment we suppose CSV is not sparse for faster error reporting
                break;
            }

            if ( isLineComment_ )
            {
                if ( self->_onCommentCallback )
                    self->_onCommentCallback( line_ );
            }
            else
            {
                storeLine_( line_
                           , tableName_
                           , buffer_
                           , error_ );
            }

            if ( nil != *error_ )
            {
                self->_outErrorHolderCrashWorkaround = *error_;
                NSLog( @"CsvToSqlite::storeDataInTable error: %@", *error_ );

                [ queryChannel_ putUnboundedString: "" ];
                dispatch_group_wait( group_, DISPATCH_TIME_FOREVER );

                return NO;
            }
        }
    }

    [ queryChannel_ putUnboundedString: "" ];
    dispatch_group_wait( group_, DISPATCH_TIME_FOREVER );

    if ( nil != *error_ )
    {
        NSLog( @"CsvToSqlite::storeDataInTable error: %@", *error_ );
        return NO;
    }

    return YES;
}

-(void)setCsvDateFormat:(NSString *)csvDateFormat_
{
    self->_csvDateFormat = csvDateFormat_;
    self.csvFormatter.dateFormat = csvDateFormat_;
}

-(NSString*)defaultValuesForInsert
{
    if ( nil == self->_defaultValuesForInsert )
    {
        self->_defaultValuesForInsert = [ self computeDefaultValuesForInsert ];
    }
    
    return self->_defaultValuesForInsert;
}

-(NSString*)headerFieldsForInsert
{
    if ( nil == self->_headerFieldsForInsert )
    {
        self->_headerFieldsForInsert = [ self computeHeaderFieldsForInsert ];
    }
    
    return self->_headerFieldsForInsert;
}

-(void)setSchema:(NSDictionary *)schema_
{
    self->_schema = schema_;
    self->_headerFieldsForInsert = nil;
}

-(void)setDefaultValues:(CsvDefaultValues *)defaultValues_
{
    self->_defaultValues = defaultValues_;

    self->_headerFieldsForInsert = nil;
    self->_defaultValuesForInsert = nil;
}

@end
