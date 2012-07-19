#import "NSString+Sqlite3Escape.h"

@implementation NSString (Sqlite3Escape)

-(NSString*)sqlite3Escape
{
    const char * cStrResult_ = [ self cStringUsingEncoding: NSUTF8StringEncoding ];
    char* cStrResultSQL_ = sqlite3_mprintf( "%q", cStrResult_ );
    NSString* result_ = [ [ NSString alloc ] initWithCString: cStrResultSQL_
                                                    encoding: NSUTF8StringEncoding ];
    sqlite3_free( cStrResultSQL_ );
    return result_;
}

@end
