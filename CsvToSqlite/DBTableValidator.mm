#import "DBTableValidator.h"

#import "SqliteTypes.h"
#import "CsvDefaultValues.h"

@implementation DBTableValidator

+(BOOL)columns:( id<NSFastEnumeration> )columns_
matchesTableSchema:( NSDictionary* )tableSchema_
{
    for ( NSString* column_ in columns_ )
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

+(BOOL)csvSchema:( NSOrderedSet* )csvSchema_
    withDefaults:( CsvDefaultValues* )defaults_
matchesTableSchema:( NSDictionary* )tableSchema_
{
    NSMutableSet* csvSchemaWithoutDefaults_ = [ NSMutableSet setWithSet: [ csvSchema_ set ] ];
    [ csvSchemaWithoutDefaults_ minusSet: [ NSSet setWithArray: [ defaults_ defaults ] ] ];

    if ( ( nil == csvSchema_ ) || ( nil == tableSchema_ ) )
    {
        return NO;
    }
    else if ( [ csvSchemaWithoutDefaults_ count ] != [ tableSchema_ count ] )
    {
        return NO;
    }

    BOOL csvSchemaOk_ = [ self columns: csvSchema_
                    matchesTableSchema: tableSchema_ ];

    BOOL defaultsOk_ = [ self columns: defaults_.columns
                   matchesTableSchema: tableSchema_ ];

    return csvSchemaOk_ && defaultsOk_;
}

@end
