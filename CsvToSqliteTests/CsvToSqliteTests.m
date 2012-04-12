#import "CsvToSqliteTests.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

@implementation CsvToSqliteTests

@synthesize defaultSchema;

-(void)setUp
{
   self.defaultSchema = [ NSDictionary dictionaryWithObjectsAndKeys:
                         @"DATETIME", @"Date"
                         , nil ];
}

-(void)testConverterRejectsInit
{
   STAssertThrows( [ CsvToSqlite new ], @"init should not be supported" );
}

-(void)testConverterRequiresDatabaseName
{
   CsvToSqlite* converter_ = nil;
   NSDictionary* schema_ = self.defaultSchema;
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: nil
                                                   dataFileName: @"data file stub" 
                                                 databaseSchema: schema_ ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: nil 
                                                 databaseSchema: schema_ ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @""
                                                   dataFileName: @"data file stub" 
                                                 databaseSchema: schema_ ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }
   
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"" 
                                                 databaseSchema: schema_ ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   }   
}

-(void)testConverterInitializedCorrectly
{
   NSDictionary* schema_ = self.defaultSchema;
   
   CsvToSqlite* converter_ = nil;   
   NSString* dbFile_       = nil;
   NSString* dataFile_     = nil;
   
   
   {
      dbFile_   = @"db stbu"  ;
      dataFile_ = @"data stub";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ 
                                                 databaseSchema: schema_ ];
      
      STAssertEquals( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      STAssertEquals( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }
   
   {
      dbFile_   = @"abra"   ;
      dataFile_ = @"kadabra";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ 
                                                 databaseSchema: schema_ ];
      
      STAssertEquals( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      STAssertEquals( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }
}

-(void)testConverterRequiresDbScheme
{
   CsvToSqlite* converter_ = nil;      
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"file stub" 
                                                 databaseSchema: nil ];
      STAssertNil( converter_, @"nil expected - DatabaseName" );
   } 
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"file stub" 
                                                 databaseSchema: self.defaultSchema ];
      STAssertNotNil( converter_, @"nil expected - DatabaseName" );
   }   
}

-(void)testStoreDataCrashesWithNullError
{
   CsvToSqlite* converter_ = nil;

   converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"a"
                                                dataFileName: @"b" 
                                              databaseSchema: self.defaultSchema ];
   
   STAssertThrows( [ converter_ storeDataInTable: @"Values" 
                                           error: NULL ], @"NSAssert expected" );
}

@end
