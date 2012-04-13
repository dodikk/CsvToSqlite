#import "CsvColumnsParser.h"

#include <string>


@implementation CsvColumnsParser
{
@private
   char separator;
}

@synthesize separatorChar = separator;

-(id)initWithSeparatorChar:( char )separator_
{
   self = [ super init ];
   
   self->separator = separator_;
   
   return self;
}

-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(NSSet*)parseColumnsFromStream:( std::ifstream& )stream_
{
   if ( !stream_.good() )
   {
      NSLog( @"[!!!ERROR!!!] : CsvColumnsParser->parseColumnsFromStream - bad stream" );
      return nil;
   }

   std::string row_;
   std::getline( stream_, row_ );
   
   @autoreleasepool 
   {
      NSString* rowString_ = [ NSString stringWithCString: row_.c_str()
                                                 encoding: NSUTF8StringEncoding ];
      rowString_ = [ rowString_ stringByTrimmingCharactersInSet: [ NSCharacterSet newlineCharacterSet ] ];
      
      NSRange separatorRange_ = NSMakeRange( static_cast<NSUInteger>( self->separator ),  1 );
      NSCharacterSet* separators_ = [ NSCharacterSet characterSetWithRange: separatorRange_ ];
      NSArray* tokens_ = [ rowString_ componentsSeparatedByCharactersInSet: separators_ ];
      
      return [ NSSet setWithArray: tokens_ ];
   }
}

@end
