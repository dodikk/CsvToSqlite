#import "CsvColumnsParser.h"

#include <string>


@interface CsvColumnsParser() 

@property ( nonatomic, strong ) id<LineReader> lineReader;

@end

@implementation CsvColumnsParser
{
@private
   char separator;
}

@synthesize separatorChar = separator;
@synthesize lineReader;

-(id)initWithSeparatorChar:( char )separator_
                lineReader:( id<LineReader> )lineReader_
{
   self = [ super init ];
   
   self->separator = separator_;
   self.lineReader = lineReader_;
   
   return self;
}

-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}



-(NSSet*)parseColumnsFromStream:( std::ifstream& )stream_
{
   if ( !stream_.is_open() || !stream_.good() )
   {
      NSLog( @"[!!!ERROR!!!] : CsvColumnsParser->parseColumnsFromStream - bad stream" );
      return nil;
   }


   std::string row_;  
   [ self.lineReader readLine: row_ 
                   fromStream: stream_ ];

   @autoreleasepool 
   {
      NSString* rowString_ = [ NSString stringWithCString: row_.c_str()
                                                 encoding: NSUTF8StringEncoding ];

      NSRange separatorRange_ = NSMakeRange( static_cast<NSUInteger>( self->separator ),  1 );
      NSCharacterSet* separators_ = [ NSCharacterSet characterSetWithRange: separatorRange_ ];
      NSArray* tokens_ = [ rowString_ componentsSeparatedByCharactersInSet: separators_ ];
      
      return [ NSSet setWithArray: tokens_ ];
   }
}

@end
