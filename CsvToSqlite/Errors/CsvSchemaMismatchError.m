#import "CsvSchemaMismatchError.h"

@implementation CsvSchemaMismatchError

-(id)init
{
    return [ super initWithErrorCode: CSV_SQL_SCHEMA_MISMATCH ];
}

@end
