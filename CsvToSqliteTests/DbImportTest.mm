#import "DbImportTest.h"

#import <ESDatabaseWrapper/ESDatabaseWrapper.h>

#import <CsvToSqlite/Detail/CsvToSqlite+Test.h>

#import <CsvToSqlite/LineReaders/UnixLineReader.h>
#import <CsvToSqlite/LineReaders/WindowsLineReader.h>

#import "CsvDefaultValues.h"
#import "FMDatabase.h"

@interface NSArray (DbImportTest)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@implementation DbImportTest
{
@private
    NSDictionary* _schema    ;
    NSOrderedSet* _primaryKey;
    NSString* _documents;
}

-(void)cleanupFS
{
    NSFileManager* fm_ = [ NSFileManager new ];
    {
        [ fm_ removeItemAtPath: @"/tmp/2.sqlite"
                         error: NULL ];
        
        [ fm_ removeItemAtPath: @"/tmp/4.sqlite"
                         error: NULL ];
        
        [ fm_ removeItemAtPath: @"/tmp/Damaged.sqlite"
                         error: NULL ];
        
        
        [ fm_ removeItemAtPath: @"/tmp/OnlyHeader.sqlite"
                         error: NULL ];
    }
    
}

-(void)setUp
{
    NSArray* pathItems_ = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    self->_documents = [ pathItems_ lastObject ];

    
    [ self cleanupFS ];
    
    self->_schema = @{
    @"Date"       : @"DATETIME"
    , @"Visits"   : @"INTEGER"
    , @"Value"    : @"INTEGER"
    , @"FacetId1" : @"VARCHAR"
    , @"FacetId2" : @"VARCHAR"
    , @"FacetId3" : @"VARCHAR"
    };

    self->_primaryKey = [ NSOrderedSet orderedSetWithObjects:
                   @"Date"
                   , @"FacetId1"
                   , @"FacetId2"
                   , @"FacetId3"                                
                   , nil ];
}

-(void)tearDown
{
    [ self cleanupFS ];
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
                                                            databaseSchema: _schema 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ UnixLineReader new ] 
                                                            dbWrapperClass: [ MockWriteableDb class ] ];
    
    converter_.csvDateFormat = @"yyyyMMdd";
    
    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
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

        query_ = qLog_[ 0 ];

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
        query_ = qLog_[ 1 ];
        STAssertTrue( [ query_ isEqualToString: @"BEGIN TRANSACTION;" ], @"missing 'create transaction'" );
    }
    
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-22', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = qLog_[ 2 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }    

    {
        query_ = qLog_[ 3 ];
        STAssertTrue( [ query_ isEqualToString: @"COMMIT TRANSACTION;" ], @"missing 'commit transaction'" );
    }
}

-(void)testImportWithInvalidDefauls
{
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest3" 
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{
    @"Date"    : @"DATETIME",
    @"Integer" : @"INTEGER",
    @"Name"    : @"VARCHAR",
    @"Id"      : @"VARCHAR",
    @"TypeId"  : @"INTEGER"
    };

    NSOrderedSet* primaryKey_ = [ NSOrderedSet orderedSetWithObjects: @"Date", @"Id", @"TypeId", nil ];

    CsvDefaultValues* defaults_ = [ CsvDefaultValues new ];

    [ defaults_ addDefaultValue: @""
                      forColumn: @"Name" ];
    [ defaults_ addDefaultValue: @"10"
                      forColumn: @"TypeId" ];

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"1.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_
                                                             defaultValues: defaults_
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ UnixLineReader new ]
                                                            dbWrapperClass: [ MockWriteableDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";

    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");
    
    NSError* error_;
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   
    
    STAssertNotNil( error_, @"Unexpected error" );
}

-(void)testCampaignImportRealDbWin
{
    NSError*  error_    = nil;
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"Campaigns-small-win" 
                                                ofType: @"csv" ];
    
    
    NSString* dbPath_ = @"/tmp/2.sqlite";
    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbPath_ 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: _schema 
                                                                primaryKey: nil ];
    converter_.csvDateFormat = @"yyyyMMdd";
    STAssertNotNil( converter_.dbWrapper, @"DB initialization error ");
    
    
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];
    STAssertNil( error_, @"Unexpected error" );   
    
    
    id<ESReadOnlyDbWrapper> dbWrapper_ = (id<ESReadOnlyDbWrapper>)converter_.dbWrapper;
    [ dbWrapper_ open ];
    NSInteger itemsCount_ = [ dbWrapper_ selectIntScalar: @"SELECT COUNT(*) FROM Campaigns" ];
    [ dbWrapper_ close ];
    
    STAssertTrue( 4 == itemsCount_, @"database mismatch" );
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
                                                            databaseSchema: _schema 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ WindowsLineReader new ] 
                                                            dbWrapperClass: [ MockWriteableDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
    
    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
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
        
        query_ = qLog_[ 0 ];
        
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
        expected_ = @"BEGIN TRANSACTION;";
        query_    = qLog_[ 1 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );        
    }

    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-22', '24', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = qLog_[ 2 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }

    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-23', '32', '200', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = qLog_[ 3 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }
    
    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-24', '14', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = qLog_[ 4 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch" );
    }

    {
        expected_ = @"INSERT OR IGNORE INTO 'Campaigns' ( Date, Visits, Value, FacetId1, FacetId2, FacetId3 ) "
        @"VALUES ( '2008-12-25', '11', '0', '10000000-0000-0000-0000-000000000000', '16000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000' );";
        query_    = qLog_[ 5 ];
        STAssertTrue( [ query_ isEqualToString: expected_ ], @"INSERT INTO mismatch - %@", query_ );
    }   

    {
        expected_ = @"COMMIT TRANSACTION;";
        query_    = qLog_[ 6 ];
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
                                                            databaseSchema: _schema 
                                                                primaryKey: _primaryKey
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ WindowsLineReader new ] 
                                                            dbWrapperClass: [ MockWriteableDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
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

        query_ = qLog_[ 0 ];

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

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"/tmp/4.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: _schema 
                                                                primaryKey: _primaryKey ];
    converter_.csvDateFormat = @"yyyyMMdd";
    STAssertNotNil( converter_.dbWrapper, @"DB initialization error ");

    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];
    STAssertNil( error_, @"Unexpected error" );

    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   
    STAssertNil( error_, @"Unexpected error" );

    
    [ converter_.dbWrapper open  ];
    
    id<ESReadOnlyDbWrapper> wrapper_ = (id<ESReadOnlyDbWrapper>)converter_.dbWrapper;
    NSInteger count_ = [ wrapper_ selectIntScalar: @"SELECT COUNT(*) FROM Campaigns;" ];
    [ converter_.dbWrapper close ];
    
    STAssertTrue( 4 == count_, @"count mismatch" );
}

-(void)testHeaderOnlyCsvImportedCorrectly
{
    NSError*  error_    = nil;
    
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"OnlyHeader" 
                                                ofType: @"csv" ];

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"/tmp/OnlyHeader.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: _schema 
                                                                primaryKey: _primaryKey
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_UNIX
                                                       recordSeparatorChar: ';'
                                                         recordCommentChar: '#'
                               ];
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
    NSError* error_;

    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* csvPath_ = [ mainBundle_ pathForResource: @"Damaged" 
                                                ofType: @"csv" ];

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"/tmp/Damaged.sqlite"
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: _schema 
                                                                primaryKey: _primaryKey
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_UNIX
                                                       recordSeparatorChar: ';'
                                                         recordCommentChar: '#'
                               ];
    converter_.csvDateFormat = @"yyyyMMdd";

    STAssertNotNil( converter_, @"DB initialization error" );

    BOOL result_ = [ converter_ storeDataInTable: @"Campaigns"
                                           error: &error_ ];

    STAssertFalse ( result_, @"Import error expected" );
    STAssertNotNil( error_ , @"Import error expected" );

    STAssertTrue( [ error_.domain isEqualToString: @"org.EmbeddedSources.CSV.import" ], @"error domain mismatch" );
    STAssertTrue( error_.code == 2, @"error code mismatch" );
}

-(void)testImportDataWithScpecialSymbols
{
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"InvalidSymbols" 
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{
    @"Date"    : @"DATETIME",
    @"Visits"  : @"INTEGER",
    @"Value"   : @"INTEGER",
    @"FacetId" : @"INTEGER"
    };

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"/tmp/1.sqlite"
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_WIN
                                                       recordSeparatorChar: ';'
                                                         recordCommentChar: '#'
                               ];
    converter_.csvDateFormat = @"yyyyMMdd";

    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");

    NSError* error_;
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   

    STAssertNil( error_, @"Unexpected error" );
    
    {
        FMDatabase* db_ = [ FMDatabase databaseWithPath: @"/tmp/1.sqlite" ];
        [ db_ open ];
        FMResultSet* rs_ = [ db_ executeQuery: @"SELECT FacetId FROM Campaigns;" ];
        [ rs_ next ];
        NSString* facetId_ = [ rs_ stringForColumn: @"FacetId" ];
        STAssertEqualObjects( facetId_, @"gartner\'s market scope for web content management", @"facetIdMismatch" );

        STAssertTrue( [ rs_ next ], @"should go to next" );

        facetId_ = [ rs_ stringForColumn: @"FacetId" ];
        STAssertEqualObjects( facetId_, @"\"predictive personalization\"", @"facetIdMismatch" );

        [ db_ close ];
    }
}

-(void)testImportDataWithScpecialSymbolsAsIs
{
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"InvalidSymbolsAsIs"
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{
    @"Date"    : @"DATETIME",
    @"Visits"  : @"INTEGER",
    @"Value"   : @"INTEGER",
    @"FacetId" : @"INTEGER"
    };

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"/tmp/1.sqlite"
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_WIN
                                                       recordSeparatorChar: ';'
                                                         recordCommentChar: '#'
                               ];
    converter_.csvDateFormat = @"yyyy-MM-dd";

    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
    STAssertNotNil( dbWrapper_, @"DB initialization error ");

    NSError* error_;
    [ converter_  storeDataInTable: @"Campaigns" 
                             error: &error_ ];   

    STAssertNil( error_, @"Unexpected error" );

    {
        FMDatabase* db_ = [ FMDatabase databaseWithPath: @"/tmp/1.sqlite" ];
        [ db_ open ];
        FMResultSet* rs_ = [ db_ executeQuery: @"SELECT FacetId FROM Campaigns;" ];
        [ rs_ next ];
        NSString* facetId_ = [ rs_ stringForColumn: @"FacetId" ];
        STAssertEqualObjects( facetId_, @"gartner\'s market scope for web content management", @"facetIdMismatch" );

        STAssertTrue( [ rs_ next ], @"should go to next" );

        facetId_ = [ rs_ stringForColumn: @"FacetId" ];
        STAssertEqualObjects( facetId_, @"\"predictive personalization\"", @"facetIdMismatch" );

        [ db_ close ];
    }
}

@end
