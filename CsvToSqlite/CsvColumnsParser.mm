#import "CsvColumnsParser.h"

#include <string>

static BOOL isValidStream( const std::ifstream& stream_ )
{
    return stream_.is_open() && stream_.good() && !stream_.eof();
}

@interface CsvColumnsParser() 

@property ( nonatomic ) id<LineReader> lineReader;

@end

@implementation CsvColumnsParser

@dynamic separatorString;

-(id)initWithSeparatorChar:( char )separator_
                   comment:( char )comment_
                lineReader:( id<LineReader> )lineReader_
{
    self = [ super init ];

    if ( self )
    {
        self->_separator = separator_;
        self->_comment   = comment_;
        self.lineReader  = lineReader_;
    }

    return self;
}

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(NSOrderedSet*)parseColumnsFromStream:( std::ifstream& )stream_
{
    if ( !isValidStream( stream_ ) )
    {
        NSLog( @"[!!!ERROR!!!] : CsvColumnsParser->parseColumnsFromStream - bad stream" );
        return nil;
    }

    std::string row_;  
    [ self.lineReader readLine: row_ 
                    fromStream: stream_ ];

    while ( row_[ 0 ] == self->_comment && isValidStream( stream_ ) )
    {
        if ( self->_onCommentCallback )
            self->_onCommentCallback( row_ );
        [ self.lineReader readLine: row_
                        fromStream: stream_ ];
    }

    @autoreleasepool
    {
        if ( row_.empty() )
        {
            return nil;
        }
        
        NSRange separatorRange_ = { static_cast<NSUInteger>( self->_separator ),  1 };
        NSCharacterSet* separators_ = [ NSCharacterSet characterSetWithRange: separatorRange_ ];
        NSArray* tokens_ = [ @( row_.c_str() ) componentsSeparatedByCharactersInSet: separators_ ];

        return [ [ NSOrderedSet alloc ] initWithArray: tokens_ ];
    }
}

-(NSString*)separatorString
{
    return [ [ NSString alloc ] initWithBytesNoCopy: &(self->_separator)
                                             length: sizeof( self->_separator )
                                           encoding: NSUTF8StringEncoding
                                       freeWhenDone: NO ];
}

@end
