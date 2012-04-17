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
#import "FMDatabase.h"

#include <fstream>
#include <ObjcScopedGuard/ObjcScopedGuard.h>

using namespace ::Utils;

@interface CsvToSqlite()

@property ( nonatomic, strong ) NSString* databaseName;
@property ( nonatomic, strong ) NSString* dataFileName;

@property ( nonatomic, strong ) NSDictionary* schema   ;
@property ( nonatomic, strong ) NSSet*        csvSchema;

@property ( nonatomic, strong ) CsvColumnsParser* columnsParser;
@property ( nonatomic, strong ) id<LineReader>    lineReader   ;
@property ( nonatomic, strong ) id<DbWrapper>     dbWrapper    ;

@end


@implementation CsvToSqlite

@synthesize databaseName ;
@synthesize dataFileName ;
@synthesize schema       ;
@synthesize csvSchema    ;

@synthesize columnsParser;
@synthesize lineReader   ;

@synthesize dbWrapper;

-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}


// TODO : fix hard code
-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
{
   return [ self initWithDatabaseName: databaseName_
                         dataFileName: dataFileName_ 
                       databaseSchema: schema_
                        separatorChar: ';'
                           lineReader: [ WindowsLineReader new ]
                       dbWrapperClass: [ FMDatabase class ] ];
}


-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_
{
   if ( NULL == error_ )
   {
      NSString* errorMessage_ = @"[!!!ERROR!!!] : CsvToSqlite->storeDataInTable - NULL error not allowed";
      
      NSLog( @"%@", errorMessage_ );
      NSAssert( NO, errorMessage_ );
      return 0;
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


   @autoreleasepool 
   {
      NSOrderedSet* csvSchema_ = [ self.columnsParser parseColumnsFromStream: stream_ ];
      BOOL isValidSchema_ = [ DBTableValidator csvSchema: csvSchema_
                                      matchesTableSchema: self.schema ];

      if ( !isValidSchema_ )
      {
         *error_ = [ CsvSchemaMismatchError new ];
         return NO;
      }



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
         [ self.lineReader readLine: line_ 
                         fromStream: stream_ ];
         
         
         
         size_t lineSize_ = line_.size();
         void* lineBegPtr_ = reinterpret_cast<void*>( const_cast<char*>( line_.c_str() ) );
         lineStr_ = [ [ NSString alloc ] initWithBytesNoCopy: lineBegPtr_
                                                      length: lineSize_
                                                    encoding: NSUTF8StringEncoding
                                                freeWhenDone: NO ];
         
         [ self storeLine: lineStr_ 
                  inTable: tableName_
                    error: error_];
         
         CHECK_ERROR__RET_BOOL( error_ );
      }
   }

   return YES;
}

@end
