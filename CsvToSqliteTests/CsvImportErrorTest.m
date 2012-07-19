#import "CsvImportErrorTest.h"

#import "CsvImportError.h"
#import "CsvBadTableNameError.h"
#import "CsvSchemaMismatchError.h"
#import "CsvInitializationError.h"

@implementation CsvImportErrorTest

-(void)testNoThrowDescriptionOfCsvImportError
{
    NSError* error_ = [ [ CsvImportError alloc ] initWithErrorCode: 10 ];
    STAssertNoThrow( [ error_ description ], @"CsvImportError description throw exception" );
}

-(void)testThrowExceptionWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    STAssertThrows( [ [ CsvImportError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvBadTableNameErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    STAssertNoThrow( [ [ CsvBadTableNameError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvSchemaMismatchErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    STAssertNoThrow( [ [ CsvSchemaMismatchError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

-(void)testCsvInitializationErrorNoThrowWhenInitWithoutCode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    STAssertNoThrow( [ [ CsvInitializationError alloc ] init ], @"CsvImportError description throw exception" );
#pragma clang diagnostic pop
}

@end
