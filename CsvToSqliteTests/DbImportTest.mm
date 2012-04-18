#import "DbImportTest.h"

#import "MockDb.h"

#import "CsvToSqlite+Test.h"

#import "UnixLineReader.h"
#import "WindowsLineReader.h"


@implementation DbImportTest

-(void)setUp
{
   schema_ = [ NSDictionary dictionaryWithObjectsAndKeys:
                @"DATETIME", @"Date"
              , @"INTEGER" , @"Visits"
              , @"INTEGER" , @"Value"                            
              , @"VARCHAR" , @"FacetId1"
              , @"VARCHAR" , @"FacetId2"
              , @"VARCHAR" , @"FacetId3"                            
              , nil ];


   primaryKey_ = [ NSOrderedSet orderedSetWithObjects: 
                    @"Date"
                  , @"FacetId1"
                  , @"FacetId2"
                  , @"FacetId3"                                
                  , nil ];
}

-(void)testCampaignImportQueries
{
   NSError*  error_    = nil;
   NSString* query_    = nil;
   NSString* expected_ = nil;
   NSRange substringRange_ = { 0u, 0u };
   NSRange emptyRange_ =  { 0u, 0u };
   

 
   NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest" 
                                                                               ofType: @"csv" ];
   
   CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"1.sqlite" 
                                                             dataFileName: csvPath_ 
                                                           databaseSchema: schema_ 
                                                               primaryKey: nil
                                                            separatorChar: ';'
                                                               lineReader: [ UnixLineReader new ] 
                                                           dbWrapperClass: [ MockDb class ] ];
   
   MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
   STAssertNotNil( dbWrapper_, @"DB initialization error ");


   [ converter_  storeDataInTable: @"Campaigns" 
                           error: &error_ ];   
   STAssertNil( error_, @"Unexpected error" );

   NSArray* qLog_ = [ dbWrapper_ queriesLog ]; 
   STAssertTrue( 2 == [ qLog_ count ], @"Queries count mismatch" );

   {
#if 0
{
      expected_ = @"CREATE TABLE [Campaigns]"
                  @" ( [Date] DATE, [Visits] INTEGER, [Value] INTEGER,"
                  @" [FacetId1] VARCHAR, [FacetId2] VARCHAR, [FacetId3] VARCHAR );" ;
}
#endif

      query_    = [ qLog_ objectAtIndex: 0 ];
      
      NSString* prefix_ = @"CREATE TABLE [Campaigns] ( ";
      BOOL prefixOk_ = [ query_ hasPrefix: prefix_ ];
      substringRange_ = [ query_ rangeOfString: prefix_ ];
       

      STAssertTrue( prefixOk_, @"CREATE TABLE bad start" );
      STAssertTrue( [ query_ hasSuffix: @");" ], @"CREATE TABLE bad end" );
      
      substringRange_ = [ query_ rangeOfString: @"[Date] DATE" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );

      substringRange_ = [ query_ rangeOfString: @"[Visits] INTEGER" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );

      substringRange_ = [ query_ rangeOfString: @"[Value] INTEGER" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );

      substringRange_ = [ query_ rangeOfString: @"[FacetId1] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );

      substringRange_ = [ query_ rangeOfString: @"[FacetId2] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );

      substringRange_ = [ query_ rangeOfString: @"[FacetId3] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
   }

   {
      expected_ = @"INSERT INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
                  @"VALUES ( '20081222', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
      query_    = [ qLog_ objectAtIndex: 1 ];
      STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
   }

   NSLog( @"%@", [ qLog_ objectAtIndex: 0 ] );
   NSLog( @"%@", [ qLog_ objectAtIndex: 1 ] );
}

-(void)testCampaignImportRealDbWin
{
   NSError*  error_    = nil;

   
   NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
   NSString* csvPath_ = [ mainBundle_ pathForResource: @"Campaigns-small-win" 
                                               ofType: @"csv" ];
   
   [ [ NSFileManager defaultManager ] removeItemAtPath: @"2.sqlite"
                                                 error: &error_ ];

   CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"2.sqlite" 
                                                             dataFileName: csvPath_ 
                                                           databaseSchema: schema_ 
                                                               primaryKey: nil ];
   
   MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
   STAssertNotNil( dbWrapper_, @"DB initialization error ");
   
   
   [ converter_  storeDataInTable: @"Campaigns" 
                            error: &error_ ];
   STAssertNil( error_, @"Unexpected error" );   
   
   
   
   NSString* expectedDbPath_ = [ mainBundle_ pathForResource: @"2" 
                                                      ofType: @"sqlite" ];
   
   NSData* receivedDb_ = [ NSData dataWithContentsOfFile: @"2.sqlite" ];
   NSData* expectedDb_ = [ NSData dataWithContentsOfFile: expectedDbPath_ ];
   
   STAssertTrue( [ receivedDb_ isEqual: expectedDb_ ], @"database mismatch" );
}

-(void)testCampaignImportQueriesWin
{
   NSError*  error_    = nil;
   NSString* query_    = nil;
   NSString* expected_ = nil;
   NSRange substringRange_ = { 0u, 0u };
   NSRange emptyRange_ =  { 0u, 0u };
   
   
   NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"Campaigns-small-win" 
                                                                               ofType: @"csv" ];
   
   CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"3.sqlite" 
                                                             dataFileName: csvPath_ 
                                                           databaseSchema: schema_ 
                                                               primaryKey: nil
                                                            separatorChar: ';'
                                                               lineReader: [ WindowsLineReader new ] 
                                                           dbWrapperClass: [ MockDb class ] ];
   
   MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
   STAssertNotNil( dbWrapper_, @"DB initialization error ");
   
   
   [ converter_  storeDataInTable: @"Campaigns" 
                            error: &error_ ];   
   STAssertNil( error_, @"Unexpected error" );
   
   NSArray* qLog_ = [ dbWrapper_ queriesLog ]; 
   STAssertTrue( 5 == [ qLog_ count ], @"Queries count mismatch" );
   
   {
#if 0
      {
         expected_ = @"CREATE TABLE [Campaigns]"
         @" ( [Date] DATE, [Visits] INTEGER, [Value] INTEGER,"
         @" [FacetId1] VARCHAR, [FacetId2] VARCHAR, [FacetId3] VARCHAR );" ;
      }
#endif
      
      query_    = [ qLog_ objectAtIndex: 0 ];
      
      NSString* prefix_ = @"CREATE TABLE [Campaigns] ( ";
      BOOL prefixOk_ = [ query_ hasPrefix: prefix_ ];
      substringRange_ = [ query_ rangeOfString: prefix_ ];
      
      
      STAssertTrue( prefixOk_, @"CREATE TABLE bad start" );
      STAssertTrue( [ query_ hasSuffix: @");" ], @"CREATE TABLE bad end" );
      
      substringRange_ = [ query_ rangeOfString: @"[Date] DATE" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
      
      substringRange_ = [ query_ rangeOfString: @"[Visits] INTEGER" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
      
      substringRange_ = [ query_ rangeOfString: @"[Value] INTEGER" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
      
      substringRange_ = [ query_ rangeOfString: @"[FacetId1] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
      
      substringRange_ = [ query_ rangeOfString: @"[FacetId2] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
      
      substringRange_ = [ query_ rangeOfString: @"[FacetId3] VARCHAR" ];
      STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing" );
   }
   
   
   {
      expected_ = @"INSERT INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
      @"VALUES ( '20081222', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
      query_    = [ qLog_ objectAtIndex: 1 ];
      STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
   }
   
   {
      expected_ = @"INSERT INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
      @"VALUES ( '20081223', '32', '200', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
      query_    = [ qLog_ objectAtIndex: 2 ];
      STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
   }
   
   {
      expected_ = @"INSERT INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
      @"VALUES ( '20081224', '14', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
      query_    = [ qLog_ objectAtIndex: 3 ];
      STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
   }

   {
      expected_ = @"INSERT INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
      @"VALUES ( '20081225', '11', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
      query_    = [ qLog_ objectAtIndex: 4 ];
      STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
   }   
   
   
   NSLog( @"%@", [ qLog_ objectAtIndex: 0 ] );
   NSLog( @"%@", [ qLog_ objectAtIndex: 1 ] );
   NSLog( @"%@", [ qLog_ objectAtIndex: 2 ] );   
   NSLog( @"%@", [ qLog_ objectAtIndex: 3 ] );   
   NSLog( @"%@", [ qLog_ objectAtIndex: 4 ] );   
}

-(void)testSameDataImportDoesNotChangeDb
{
   NSError*  error_    = nil;

   
   NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
   NSString* csvPath_ = [ mainBundle_ pathForResource: @"Campaigns-small-win" 
                                               ofType: @"csv" ];

   [ [ NSFileManager defaultManager ] removeItemAtPath: @"4.sqlite"
                                                 error: &error_ ];

   CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"4.sqlite" 
                                                             dataFileName: csvPath_ 
                                                           databaseSchema: schema_ 
                                                               primaryKey: primaryKey_ ];

   MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
   STAssertNotNil( dbWrapper_, @"DB initialization error ");


   [ converter_  storeDataInTable: @"Campaigns" 
                            error: &error_ ];
   STAssertNil( error_, @"Unexpected error" );
   
   
   
   [ converter_  storeDataInTable: @"Campaigns" 
                            error: &error_ ];   
   STAssertNil( error_, @"Unexpected error" );
   
   
   NSString* expectedDbPath_ = [ mainBundle_ pathForResource: @"4" 
                                                      ofType: @"sqlite" ];
   
   NSData* receivedDb_ = [ NSData dataWithContentsOfFile: @"4.sqlite" ];
   NSData* expectedDb_ = [ NSData dataWithContentsOfFile: expectedDbPath_ ];
   STAssertTrue( [ receivedDb_ isEqual: expectedDb_ ], @"database mismatch" );
}

@end
