#import "CsvImportErrorTest.h"

#import "CsvImportError.h"
#import "CsvBadTableNameError.h"
#import "CsvSchemaMismatchError.h"
#import "CsvInitializationError.h"

@implementation CsvImportErrorTest

-(void)testNoThrowDescriptionOfCsvImportError
{
    NSError* error_ = [ [ CsvImportError alloc ] initWithErrorCode: 10 ];
    XCTAssertNoThrow( [ error_ description ], @"CsvImportError description throw exception" );
}

-(void)testThrowExceptionWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    XCTAssertThrows( [ [ CsvImportError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvBadTableNameErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    XCTAssertNoThrow( [ [ CsvBadTableNameError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvSchemaMismatchErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    XCTAssertNoThrow( [ [ CsvSchemaMismatchError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvInitializationErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    XCTAssertNoThrow( [ [ CsvInitializationError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

@end
