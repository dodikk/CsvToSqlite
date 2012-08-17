#import <Foundation/Foundation.h>

#include <string>

@interface StringsChannel : NSObject

+(id)newStringsChannelWithSize:( NSUInteger )size_;

-(void)putString:( const std::string& )str_;
-(void)putUnboundedString:( const std::string& )str_;

-(std::string)popString;

@end
