#import <Foundation/Foundation.h>

#include <vector>
#include <string>

@interface CsvDefaultValues : NSObject

@property ( nonatomic, readonly ) NSOrderedSet* columns ;
@property ( nonatomic, readonly ) NSArray*      defaults;

-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_;

-(NSUInteger)count;
-(void)clear;

@end
