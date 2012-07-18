#import "DbImportTest.h"

#import <CsvToSqlite/Mocks/MockDb.h>

#import <CsvToSqlite/Detail/CsvToSqlite+Test.h>

#import <CsvToSqlite/LineReaders/UnixLineReader.h>
#import <CsvToSqlite/LineReaders/WindowsLineReader.h>


@implementation DbImportTest

-(void)setUp
{
    NSFileManager* fm_ = [ NSFileManager new ];
    {
        [ fm_ removeItemAtPath: @"2.sqlite" 
                         error: NULL ]; 
        
        [ fm_ removeItemAtPath: @"4.sqlite" 
                         error: NULL ]; 
        
        [ fm_ removeItemAtPath: @"Damaged.sqlite" 
                         error: NULL ];  

        
        [ fm_ removeItemAtPath: @"OnlyHeader.sqlite" 
                         error: NULL ];
    }
    
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

-(void)tearDown
{
    NSFileManager* fm_ = [ NSFileManager new ];
    {
        [ fm_ removeItemAtPath: @"2.sqlite" 
                         error: NULL ]; 
        
        [ fm_ removeItemAtPath: @"4.sqlite" 
                         error: NULL ];
        
        [ fm_ removeItemAtPath: @"Damaged.sqlite" 
                         error: NULL ];  
        
        
        [ fm_ removeItemAtPath: @"OnlyHeader.sqlite" 
                         error: NULL ];        
    }
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
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                                lineReader: [ UnixLineReader new ] 
                                                            dbWrapperClass: [ MockDb class ] ];
    
    converter_.csvDateFormat = @"yyyyMMdd";
    
    MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");
    
    
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   
    STAssertNil( error_, @"Unexpected error" );
    
    NSArray* qLog_ = [ dbWrapper_ queriesLog ]; 
    STAssertTrue( 4 == [ qLog_ count ], @"Queries count mismatch" );
    
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
        query_ = [ qLog_ objectAtIndex: 1 ];
        STAssertTrue( [ query_ isEqualToString: @"BEGIN TRANSACTION" ], @"missing 'create transaction'" );
    }
    
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-22', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = [ qLog_ objectAtIndex: 2 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }    
    
    
    {
        query_ = [ qLog_ objectAtIndex: 3 ];
        STAssertTrue( [ query_ isEqualToString: @"COMMIT TRANSACTION" ], @"missing 'commit transaction'" );
    }
    
}

-(void)testCampaignImportRealDbWin
{
    NSError*  error_    = nil;
    
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"Campaigns-small-win" 
                                                ofType: @"csv" ];
    
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"2.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: nil ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
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
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                                lineReader: [ WindowsLineReader new ] 
                                                            dbWrapperClass: [ MockDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
    
    MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");
    
    
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   
    STAssertNil( error_, @"Unexpected error" );
    
    NSArray* qLog_ = [ dbWrapper_ queriesLog ]; 
    STAssertTrue( 7 == [ qLog_ count ], @"Queries count mismatch" );
    
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
        expected_ = @"BEGIN TRANSACTION";
        query_    = [ qLog_ objectAtIndex: 1 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );        
    }
    
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-22', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = [ qLog_ objectAtIndex: 2 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-23', '32', '200', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = [ qLog_ objectAtIndex: 3 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-24', '14', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = [ qLog_ objectAtIndex: 4 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-25', '11', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = [ qLog_ objectAtIndex: 5 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch - %@", query_ );
    }   
    
    {
        expected_ = @"COMMIT TRANSACTION";
        query_    = [ qLog_ objectAtIndex: 6 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );        
    }
}

-(void)testPrimaryKeyQueries
{
    NSError*  error_    = nil;
    NSString* query_    = nil;
    NSRange substringRange_ = { 0u, 0u };
    NSRange emptyRange_ =  { 0u, 0u };
    
    
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"Campaigns-small-win" 
                                                                                ofType: @"csv" ];
    
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"3.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                                lineReader: [ WindowsLineReader new ] 
                                                            dbWrapperClass: [ MockDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
    MockDb* dbWrapper_ = ( MockDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");
    
    
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   
    STAssertNil( error_, @"Unexpected error" );
    
    NSArray* qLog_ = [ dbWrapper_ queriesLog ]; 
    STAssertTrue( 7 == [ qLog_ count ], @"Queries count mismatch" );
    
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
        STAssertTrue( [ query_ hasSuffix: @", CONSTRAINT pkey PRIMARY KEY ( Date, FacetId1, FacetId2, FacetId3 ) );" ], @"CREATE TABLE bad end" );
        
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
        STAssertFalse( NSEqualRanges( substringRange_, emptyRange_ ) , @"date missing - %@", query_ );
    }
}

-(void)testSameDataImportDoesNotChangeDb
{
    NSError*  error_    = nil;
    
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"Campaigns-small-win" 
                                                ofType: @"csv" ];
    
    
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"4.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_ ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
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

-(void)testHeaderOnlyCsvImportedCorrectly
{
    NSError*  error_    = nil;
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"OnlyHeader" 
                                                ofType: @"csv" ];
    
    
    
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"OnlyHeader.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_UNIX
                                                       recordSeparatorChar: ';' ];    
    converter_.csvDateFormat = @"yyyyMMdd";
    
    STAssertNotNil( converter_, @"DB initialization error" );
    
    BOOL result_ = [ converter_ storeDataInTable: @"Campaigns"
                                           error: &error_ ];
    
    STAssertTrue( result_, @"Unexpected import error" );
    STAssertNil ( error_ , @"Unexpected import error" );
}

-(void)testDamagedCsvPartiallyImportedWithError
{
    //line11 is damaged
    NSError*  error_    = nil;
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"Damaged" 
                                                ofType: @"csv" ];
    
    
    
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"Damaged.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_UNIX
                                                       recordSeparatorChar: ';' ];    
    converter_.csvDateFormat = @"yyyyMMdd";
    
    STAssertNotNil( converter_, @"DB initialization error" );
    
    BOOL result_ = [ converter_ storeDataInTable: @"Campaigns"
                                           error: &error_ ];
    
    STAssertFalse ( result_, @"Import error expected" );
    STAssertNotNil( error_ , @"Import error expected" );
    
    
    
    STAssertTrue( [ error_.domain isEqualToString: @"org.EmbeddedSources.CSV.import" ], @"error domain mismatch" );
    STAssertTrue( error_.code == 2, @"error code mismatch" );
}

@end
