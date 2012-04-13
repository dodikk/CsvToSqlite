#include "LineReader.h"

#import <Foundation/Foundation.h>
#include <fstream>


@interface CsvColumnsParser : NSObject

-(id)initWithSeparatorChar:( char )separator_
                lineReader:( id<LineReader> )lineReader_;

-(NSSet*)parseColumnsFromStream:( std::ifstream& )stream_;

@property ( nonatomic, assign, readonly ) char separatorChar;

@end
