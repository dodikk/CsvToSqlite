#import <Foundation/Foundation.h>

@interface CsvDefaultValues : NSObject

@property ( nonatomic, strong, readonly ) NSOrderedSet* columns ;
@property ( nonatomic, strong, readonly ) NSArray*      defaults;

-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_;

-(NSUInteger)count;
-(void)clear;

@end
