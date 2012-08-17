#include "LineReader.h"

#import <Foundation/Foundation.h>

#include <CsvToSqlite/CSVParserCallbacks.h>

#include <fstream>

@interface CsvColumnsParser : NSObject
{
@public
    char _separator;
    char _comment;
}

@property ( nonatomic, copy ) CSVOnCommentCallback onCommentCallback;

-(id)initWithSeparatorChar:( char )separator_
                   comment:( char )comment_
                lineReader:( id<LineReader> )lineReader_;

-(NSOrderedSet*)parseColumnsFromStream:( std::ifstream& )stream_;

@property ( nonatomic, readonly ) NSString* separatorString;

@end
