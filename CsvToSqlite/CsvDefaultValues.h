#import <Foundation/Foundation.h>

#include <vector>
#include <string>

@interface CsvDefaultValues : NSObject
{
@public
    std::vector<std::string> _defaults;
}

@property ( nonatomic, strong, readonly ) NSOrderedSet* columns ;
@property ( nonatomic, strong, readonly ) NSArray*      defaults;

-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_;

-(NSUInteger)count;
-(void)clear;

@end
