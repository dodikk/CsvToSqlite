#import "CsvFailedImportTest.h"

#import <ESDatabaseWrapper/ESDatabaseWrapper.h>

#import "CsvToSqlite+Test.h"

#import "UnixLineReader.h"
#import "WindowsLineReader.h"

@implementation CsvFailedImportTest

-(void)testUnexpectedDbHeaders
{
    NSError*  error_    = nil;

    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest" 
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{ @"karamba" : @"amba" };

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"5.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ UnixLineReader new ] 
                                                            dbWrapperClass: [ MockWriteableDb class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";    
    
    MockWriteableDb* dbWrapper_ = ( MockWriteableDb* )converter_.dbWrapper ;
    XCTAssertNotNil( dbWrapper_, @"DB initialization error ");

    BOOL result_ = [ converter_  storeDataInTable: @"Campaigns" 
                                            error: &error_ ];   
    XCTAssertFalse( result_, @"Unexpected success" );

    XCTAssertNotNil( error_, @"Unexpected error" );

    XCTAssertTrue( [ error_.domain isEqualToString: @"org.EmbeddedSources.CSV.import" ], @"error domain mismatch" );
    XCTAssertTrue( error_.code == 2, @"error code mismatch" );

    XCTAssertTrue( [ [ dbWrapper_ queriesLog ] count ] == 0, @"Unexpected query occured" );
}

-(void)testMacLineEndingsNotSupported
{   
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest" 
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{ @"karamba" : @"amba" };

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"6.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: nil
                                                             defaultValues: nil
                                                           lineEndingStyle: CSV_LE_MAC_LEGACY 
                                                       recordSeparatorChar: ';'
                                                         recordCommentChar: '#'
                               ];
    converter_.csvDateFormat = @"yyyyMMdd";    

    XCTAssertNil( converter_, @"Not supported line endings : nil expected" );
}

@end
