#import "CsvBadTableNameError.h"

@implementation CsvBadTableNameError

-(id)init
{
    return [ super initWithErrorCode: CSV_SQL_BAD_TABLE_NAME ];
}

@end
