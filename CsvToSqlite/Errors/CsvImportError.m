#import "CsvImportError.h"

static NSString* const ERROR_DOMAIN = @"org.EmbeddedSources.CSV.import";

@implementation CsvImportError

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(id)initWithErrorCode:( NSInteger )errorCode_
{
   return [ super initWithDomain: ERROR_DOMAIN 
                            code: errorCode_
                        userInfo: nil ];
}

@end
