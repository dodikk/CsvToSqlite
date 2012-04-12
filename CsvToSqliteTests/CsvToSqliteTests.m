#import "CsvToSqliteTests.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

@implementation CsvToSqliteTests

-(void)testConverterRejectsInit
{
   STAssertThrows( [ CsvToSqlite new ], @"init should not be supported" );
}

-(void)testConverterRequiresDatabaseName
{
   CsvToSqlite* converter_ = nil;
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: nil
                                                   dataFileName: @"data file stub" ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: nil ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @""
                                                   dataFileName: @"data file stub" ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"" ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }   
}

-(void)testConverterInitializedCorrectly
{
   CsvToSqlite* converter_ = nil;   
   NSString* dbFile_       = nil;
   NSString* dataFile_     = nil;
   
   
   {
      dbFile_   = @"db stbu"  ;
      dataFile_ = @"data stub";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ ];

      STAssertEquals( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      STAssertEquals( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }

   {
      dbFile_   = @"abra"   ;
      dataFile_ = @"kadabra";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ ];
      
      STAssertEquals( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      STAssertEquals( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }
}

@end
