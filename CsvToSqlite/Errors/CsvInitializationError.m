#import "CsvInitializationError.h"

@implementation CsvInitializationError

-(id)init
{
   return [ super initWithErrorCode: CSV_PARSER_INITIALIZATION_ERROR ];
}

@end


