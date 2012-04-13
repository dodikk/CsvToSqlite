#import <Foundation/Foundation.h>

@interface DBTableValidator : NSObject

+(BOOL)csvSchema:( NSOrderedSet* )csvSchema_
matchesTableSchema:( NSDictionary* )tableSchema_;

@end
