#import <Foundation/Foundation.h>

#include <string>
#include <iostream>

@protocol LineReader  <NSObject>

-(void)readLine:( std::string& )line_
     fromStream:( std::ifstream& )stream_;

@end
