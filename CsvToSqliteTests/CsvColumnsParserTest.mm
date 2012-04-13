#import "CsvColumnsParserTest.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

#import "CsvColumnsParser.h"
#import "StreamUtils.h"

#include <fstream>

@implementation CsvColumnsParserTest

-(void)testColumnsParserAllowsInit
{
   STAssertThrows( [ CsvColumnsParser new ], @"unexpected @init support" );
}

-(void)testColumnsParserRequiresSeparatorChar
{
   char separator = ';';
   
   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: separator ];
   STAssertNotNil( parser_, @"valid object expected" );
   STAssertTrue( separator == parser_.separatorChar, @"Incorrect initialization" );
}

-(void)testParseColumnsReturnsCorrectValues
{
   std::ifstream stream_;
   [ StreamUtils csvStream: stream_ 
              withFileName: @"Campaigns" ];

   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';' ]; 
   NSSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
   STAssertTrue( [ result_ count ] == 6, @"Headers count mismatch" );
   STAssertTrue( [ result_ containsObject: @"Date"     ], @"Date     mismatch" );
   STAssertTrue( [ result_ containsObject: @"Visits"   ], @"Visits   mismatch" );
   STAssertTrue( [ result_ containsObject: @"Value"    ], @"Value    mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId1" ], @"FacetId1 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId2" ], @"FacetId2 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId3" ], @"FacetId3 mismatch" );
}

@end
