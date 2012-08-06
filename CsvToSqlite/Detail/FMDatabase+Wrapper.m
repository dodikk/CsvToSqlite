#import "FMDatabase+Wrapper.h"

@implementation FMDatabase (Wrapper)

-(BOOL)insert:( NSString* )sql_
        error:( NSError** )error_
{
    return [ self update: sql_ withErrorAndBindings: error_ ];
}

-(BOOL)createTable:( NSString* )sql_
             error:( NSError** )error_
{
    return [ self update: sql_ withErrorAndBindings: error_ ];
}

@end
