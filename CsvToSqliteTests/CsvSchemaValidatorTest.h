#import <XCTest/XCTest.h>

@interface CsvSchemaValidatorTest : XCTestCase
{
@private
    NSDictionary* schema_    ;
    NSOrderedSet* primaryKey_;
}

@end
