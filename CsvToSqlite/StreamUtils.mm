#import "StreamUtils.h"

@implementation StreamUtils

+(void)csvStream:( std::ifstream& )stream_
    withFilePath:( NSString* )filePath_
{
   const char* rawFilePath_ = [ filePath_ cStringUsingEncoding: NSUTF8StringEncoding ];
   stream_.open( rawFilePath_, std::ifstream::in );
}

+(void)csvStream:( std::ifstream& )stream_
    withFileName:( NSString* )fileName_
{
   NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
   NSString* filePath_ = [  mainBundle_ pathForResource: fileName_ 
                                                 ofType: @"csv" ];

   [ self csvStream: stream_ 
       withFilePath: filePath_ ];
}

@end
