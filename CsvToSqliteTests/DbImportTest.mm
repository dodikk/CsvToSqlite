#import "DbImportTest.h"

#import "MockDb.h"

#import "CsvToSqlite+Test.h"
#import "UnixLineReader.h"



@implementation DbImportTest

-(void)testCampaignImportQueries
{
   NSError*  error_    = nil;
   NSString* query_    = nil;
   NSString* expected_ = nil;
   NSRange substringRange_ = { 0u, 0u };
   NSRange emptyRange_ =  { 0u, 0u };
   
   NSDictionary* schema_ = [ NSDictionary dictionaryWithObjectsAndKeys:
                                @"DATETIME", @"Date"
                              , @"INTEGER" , @"Visits"
                              , @"INTEGER" , @"Value"                            
                              , @"VARCHAR" , @"FacetId1"
                              , @"VARCHAR" , @"FacetId2"
                              , @"VARCHAR" , @"FacetId3"                            
                              , nil ];
 
   NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest" 
                                                                               ofType: @"csv" ];
   
   CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"1.sqlite" 
                                                             dataFileName: csvPath_ 
                                                           databaseSchema: schema_ 
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

@end
