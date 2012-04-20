#import <SenTestingKit/SenTestingKit.h>

@interface CsvSchemaValidatorTest : SenTestCase
{
@private
    NSDictionary* schema_    ;
    NSOrderedSet* primaryKey_;
}

@end
