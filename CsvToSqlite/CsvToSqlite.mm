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

#include <map>
#include <fstream>
#include <ObjcScopedGuard/ObjcScopedGuard.h>

using namespace ::Utils;

@interface CsvToSqlite()

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
@property ( nonatomic ) id<DbWrapper>     dbWrapper    ;

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
{
    static std::map< CsvLineEndings, Class > lineEndingsMap_;
    if ( lineEndingsMap_.empty() )
    {
        lineEndingsMap_[ CSV_LE_WIN  ] = [ WindowsLineReader class ];
        lineEndingsMap_[ CSV_LE_UNIX ] = [ UnixLineReader    class ];
    }

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
                                    recordSeparatorChar: ';' ];
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

-(void)finishAndWaitCondition:( NSCondition* )finishCondition_
                stringChannel:( StringsChannel* )stringChannel_
{
    [ stringChannel_ putNoBlockString: "" ];

    [ finishCondition_ lock ];
    [ finishCondition_ wait ];
    [ finishCondition_ unlock ];
}

-(BOOL)executeSqliteQueries:( StringsChannel* )stringChannel_
                  tableName:( NSString* )tableName_
                      error:( NSError** )error_
{
    NSParameterAssert( error_ != NULL );

    [ self openDatabaseWithError: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );

    GuardCallbackBlock closeDbBlock_ = ^
    {
        [ self closeDatabase ];
    };
    ObjcScopedGuard dbGuard_( closeDbBlock_ );
    
    id<DbWrapper> castedWrapper_ = [ self castedWrapper ];

    [ self createTableNamed: tableName_
                      error: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );
    
    [ self beginTransaction ];
    
    std::string&& queryStr_ = [ stringChannel_ getString ];
    
    while ( queryStr_.length() != 0 )
    {
        @autoreleasepool
        {
            NSString* query_ = [ [ NSString alloc ] initWithBytesNoCopy: (void*)queryStr_.c_str()
                                                                 length: (NSUInteger)queryStr_.length()
                                                               encoding: NSUTF8StringEncoding
                                                           freeWhenDone: NO ];

            [ castedWrapper_ insert: query_
                              error: error_ ];

            if ( *error_ )
                break;

            queryStr_ = [ stringChannel_ getString ];
        }
    }

    if ( *error_ )
    {
        [ self rollbackTransaction ];
        return NO;
    }
    else
    {
        [ self commitTransaction ];
        return YES;
    }
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
    else if ( nil == tableName_ || @"" == tableName_ )
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

    NSOrderedSet* csvSchema_ = [ self.columnsParser parseColumnsFromStream: stream_
                                                                  comments: self.onCommentCallback ];
    BOOL isValidSchema_ = [ DBTableValidator csvSchema: csvSchema_
                                          withDefaults: self.defaultValues
                                    matchesTableSchema: self.schema ];
    if ( !isValidSchema_ )
    {
        *error_ = [ CsvSchemaMismatchError new ];
        return NO;
    }
    self.csvSchema = csvSchema_;

    StoreLineFunction storeLine_;

    //be carefull, length can be bigger
    char buffer_[ 1024*4 ] = { 0 };

    NSOrderedSet* defaultColumns_ = self.defaultValues.columns;
    NSMutableOrderedSet* schemaColumns_ = [ NSMutableOrderedSet orderedSetWithArray: self.csvSchema.array ];
    [ schemaColumns_ unionOrderedSet: defaultColumns_ ];
    NSArray* headers_ = [ schemaColumns_ array ];
    NSString* headerFields_ = [ headers_ componentsJoinedByString: @", " ];

    NSUInteger requeredNumOfColumns_ = [ headers_ count ];

    const char* headerFieldsStr_ = [ headerFields_ cStringUsingEncoding: NSUTF8StringEncoding ];

    StringsChannel* stringChannel_ = [ StringsChannel newStringsChannelWithSize: 100 ];

    NSCondition* finishCondition_ = [ NSCondition new ];

    if ( [ @"yyyyMMdd" isEqualToString: self.csvDateFormat ] )
    {
        char separator_ = self.columnsParser->_separator;
        CsvDefaultValues* defaultValues_ = self.defaultValues;
        NSOrderedSet* csvSchema_     = self.csvSchema;
        NSDictionary* schema_        = self.schema;

        storeLine_ = ^( const std::string& line_
                       , NSString* tableName_
                       , char* buffer_
                       , const char* headerFieldsStr_
                       , NSError** errorPtr_ )
        {
            fastStoreLine1( line_ 
                           , tableName_
                           , buffer_
                           , headerFieldsStr_
                           , requeredNumOfColumns_
                           , defaultValues_
                           , csvSchema_
                           , schema_
                           , separator_
                           , stringChannel_
                           , error_ );
        };
    }
    else
    {
        storeLine_ = ^( const std::string& line_
                       , NSString* tableName_
                       , char* buffer_
                       , const char* headerFieldsStr_
                       , NSError** errorPtr_ )
        {
            [ self storeLine: line_ 
                     inTable: tableName_
                      buffer: buffer_
                headerFields: headerFields_
        requeredNumOfColumns: requeredNumOfColumns_
               stringChannel: stringChannel_
                       error: error_ ];
        };
    }

    std::string line_;

    __block NSError* errorHolder_;

    dispatch_queue_t queue_ = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( queue_, ^
    {
        @autoreleasepool
        {
            NSError* localError_;
            [ self executeSqliteQueries: stringChannel_
                              tableName: tableName_
                                  error: &localError_ ];

            if ( localError_ )
                *error_ = localError_;
        }

        [ finishCondition_ lock ];
        [ finishCondition_ signal ];
        [ finishCondition_ unlock ];
    } );

    while ( !stream_.eof() )
    {
        @autoreleasepool
        {
            [ self.lineReader readLine: line_ 
                            fromStream: stream_ ];

            size_t lineSize_ = line_.size();
            if ( 0 == lineSize_ )
            {
                break;
            }

            if ( line_[ 0 ] == '#' )
            {
                if ( self->_onCommentCallback )
                    self->_onCommentCallback( line_ );
            }
            else
            {
                storeLine_( line_
                           , tableName_
                           , buffer_
                           , headerFieldsStr_
                           , error_ );
            }

            if ( errorHolder_ || nil != *error_ )
            {
                [ self finishAndWaitCondition: finishCondition_
                                stringChannel: stringChannel_ ];

                *error_ = *error_ ?: errorHolder_;
                NSLog( @"%@", *error_ );
                return NO;
            }
        }
    }

    [ self finishAndWaitCondition: finishCondition_
                    stringChannel: stringChannel_ ];

    *error_ = errorHolder_;
    if ( *error_ )
        NSLog( @"%@", *error_ );

    return errorHolder_ == nil;
}

-(void)setCsvDateFormat:(NSString *)csvDateFormat_
{
    self->_csvDateFormat = csvDateFormat_;
    self.csvFormatter.dateFormat = csvDateFormat_;
}

@end
