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

#include <map>
#include <fstream>
#include <ObjcScopedGuard/ObjcScopedGuard.h>

using namespace ::Utils;

@interface CsvToSqlite()

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;

@property ( nonatomic, strong ) NSDictionary* schema    ;
@property ( nonatomic, strong ) NSOrderedSet* primaryKey;

@property ( nonatomic, strong ) NSOrderedSet* csvSchema;

@property ( nonatomic, strong ) NSDateFormatter* csvFormatter ;
@property ( nonatomic, strong ) NSDateFormatter* ansiFormatter;

@property ( nonatomic, strong ) CsvColumnsParser* columnsParser;
@property ( nonatomic, strong ) id<LineReader>    lineReader   ;
@property ( nonatomic, strong ) id<DbWrapper>     dbWrapper    ;

@end


@implementation CsvToSqlite

@synthesize databaseName ;
@synthesize dataFileName ;
@synthesize schema       ;
@synthesize primaryKey   ;
@synthesize csvSchema    ;
@synthesize csvDateFormat;

@synthesize columnsParser;
@synthesize lineReader   ;

@synthesize dbWrapper;

@synthesize csvFormatter ;
@synthesize ansiFormatter;


-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}


-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
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
                         separatorChar: separatorChar_
                            lineReader: [ readerClass_ new ]
                        dbWrapperClass: [ FMDatabase class ] ];
}


-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
{
    CsvToSqlite* result_ =  [ self initWithDatabaseName: databaseName_
                                           dataFileName: dataFileName_
                                         databaseSchema: schema_
                                             primaryKey: primaryKey_
                                        lineEndingStyle: CSV_LE_WIN
                                    recordSeparatorChar: ';' ];
    result_.csvDateFormat = @"yyyyMMdd";
    
    return result_;
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


    NSOrderedSet* csvSchema_ = [ self.columnsParser parseColumnsFromStream: stream_ ];
    BOOL isValidSchema_ = [ DBTableValidator csvSchema: csvSchema_
                                    matchesTableSchema: self.schema ];
    if ( !isValidSchema_ )
    {
        *error_ = [ CsvSchemaMismatchError new ];
        return NO;
    }
    self.csvSchema = csvSchema_;



    [ self openDatabaseWithError: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );
    GuardCallbackBlock closeDbBlock_ = ^
    {
        [ self closeDatabase ];
    };
    ObjcScopedGuard dbGuard_( closeDbBlock_ );

  
  
  
    [ self createTableNamed: tableName_
                      error: error_ ];
    CHECK_ERROR__RET_BOOL( error_ );


  
  
    std::string line_;
    NSString* lineStr_ = nil;
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

            void* lineBegPtr_ = reinterpret_cast<void*>( const_cast<char*>( line_.c_str() ) );
            lineStr_ = [ [ NSString alloc ] initWithBytesNoCopy: lineBegPtr_
                                                         length: lineSize_
                                                       encoding: NSUTF8StringEncoding
                                                   freeWhenDone: NO ];
        }

        [ self storeLine: lineStr_ 
                 inTable: tableName_
                   error: error_];

        CHECK_ERROR__RET_BOOL( error_ );
    }

    return YES;
}


-(void)setCsvDateFormat:(NSString *)csvDateFormat_
{
    self->csvDateFormat = csvDateFormat_;
    self.csvFormatter.dateFormat = csvDateFormat_;
}



@end
