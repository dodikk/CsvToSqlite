#import <Foundation/Foundation.h>

@interface CsvDefaultValues : NSObject

@property ( nonatomic, readonly ) NSOrderedSet* columns ;
@property ( nonatomic, readonly ) NSArray*      defaults;

-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_;

-(NSUInteger)count;

@end
