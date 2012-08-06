#import "CsvColumnsParser.h"

#include <string>


@interface CsvColumnsParser() 

@property ( nonatomic, strong ) id<LineReader> lineReader;

@end

@implementation CsvColumnsParser

@dynamic separatorString;

-(id)initWithSeparatorChar:( char )separator_
                lineReader:( id<LineReader> )lineReader_
{
    self = [ super init ];

    if ( self )
    {
        self->_separator = separator_;
        self.lineReader = lineReader_;
    }

    return self;
}

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(NSOrderedSet*)parseColumnsFromStream:( std::ifstream& )stream_
                              comments:( CSVOnCommentCallback )onCommentCallback_
{
    if ( !stream_.is_open() || !stream_.good() || stream_.eof() )
    {
        NSLog( @"[!!!ERROR!!!] : CsvColumnsParser->parseColumnsFromStream - bad stream" );
        return nil;
    }

    std::string row_;  
    [ self.lineReader readLine: row_ 
                    fromStream: stream_ ];

    while ( row_[ 0 ] == '#' && stream_.is_open() && stream_.good() && !stream_.eof() )
    {
        if ( onCommentCallback_ )
            onCommentCallback_( row_ );
        [ self.lineReader readLine: row_
                        fromStream: stream_ ];
    }

    if ( !stream_.is_open() || !stream_.good() || stream_.eof() )
    {
        NSLog( @"[!!!ERROR!!!] : CsvColumnsParser->parseColumnsFromStream - bad stream" );
        return nil;
    }

    @autoreleasepool
    {
        NSRange separatorRange_ = { static_cast<NSUInteger>( self->_separator ),  1 };
        NSCharacterSet* separators_ = [ NSCharacterSet characterSetWithRange: separatorRange_ ];
        NSArray* tokens_ = [ @( row_.c_str() ) componentsSeparatedByCharactersInSet: separators_ ];

        return [ NSOrderedSet orderedSetWithArray: tokens_ ];
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
