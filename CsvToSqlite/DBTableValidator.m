#import "DBTableValidator.h"

#import "SqliteTypes.h"
#import "CsvDefaultValues.h"

@implementation DBTableValidator

+(BOOL)csvSchema:( NSOrderedSet* )csvSchema_
    withDefaults:( CsvDefaultValues* )defaults_
matchesTableSchema:( NSDictionary* )tableSchema_
{
    if ( ( nil == csvSchema_ ) || ( nil == tableSchema_ ) )
    {
        return NO;
    }
    else if ( csvSchema_.count + defaults_.count != tableSchema_.count )
    {
        return NO;
    }

    for ( NSString* column_ in csvSchema_ )
    {
        NSString* type_ = [ tableSchema_ objectForKey: column_ ];
        if ( nil == type_ )
        {
            return NO;
        }
        else if ( ![ [ SqliteTypes typesSet ] containsObject: type_ ] )
        {
            return NO;
        }
    }

    return YES;
}

@end
