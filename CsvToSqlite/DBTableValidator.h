#import <Foundation/Foundation.h>

@class CsvDefaultValues;

@interface DBTableValidator : NSObject

+(BOOL)csvSchema:( NSOrderedSet* )csvSchema_
    withDefaults:( CsvDefaultValues* )defaults_
matchesTableSchema:( NSDictionary* )tableSchema_;

@end
