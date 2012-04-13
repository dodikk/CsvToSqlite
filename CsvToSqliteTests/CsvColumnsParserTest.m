#import "CsvColumnsParserTest.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

@implementation CsvColumnsParserTest

-(void)testColumnsParserForbidsInit
{
   STAssertThrows( [ CsvColumnsParser new ], @"unexpected @init support" );
}

@end
