#import "UnixLineReader.h"

#include <fstream>
#include <string>

@implementation UnixLineReader

-(void)readLine:( std::string& )line_
     fromStream:( std::ifstream& )stream_
{
    std::getline( stream_, line_, '\n' );
}

@end
