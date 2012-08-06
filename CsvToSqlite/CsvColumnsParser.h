#include "LineReader.h"

#import <Foundation/Foundation.h>

#include <CsvToSqlite/CSVParserCallbacks.h>

#include <fstream>

@interface CsvColumnsParser : NSObject
{
@public
    char _separator;
}

-(id)initWithSeparatorChar:( char )separator_
                lineReader:( id<LineReader> )lineReader_;

-(NSOrderedSet*)parseColumnsFromStream:( std::ifstream& )stream_
                              comments:( CSVOnCommentCallback )onCommentCallback_;

@property ( nonatomic, assign, readonly ) char separatorChar;
@property ( nonatomic, strong, readonly ) NSString* separatorString;

@end
