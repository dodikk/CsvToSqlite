#import <Foundation/Foundation.h>
#include <fstream>

@interface StreamUtils : NSObject

+(void)csvStream:( std::ifstream& )stream_
    withFilePath:( NSString* )filePath_;

+(void)csvStream:( std::ifstream& )stream_
    withFileName:( NSString* )fileName_;

@end
