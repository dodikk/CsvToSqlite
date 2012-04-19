#import "WindowsLineReader.h"

#include <fstream>
#include <string>

@implementation WindowsLineReader

-(void)readLine:( std::string& )line_
     fromStream:( std::ifstream& )stream_
{
    std::string dummy_;
   
    std::getline( stream_, line_ , '\r' );
    std::getline( stream_, dummy_, '\n' );
}

@end
