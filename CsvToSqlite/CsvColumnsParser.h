#import <Foundation/Foundation.h>
#include <fstream>


@interface CsvColumnsParser : NSObject

-(id)initWithSeparatorChar:( char )separator_;
-(NSSet*)parseColumnsFromStream:( std::ifstream& )stream_;

@property ( nonatomic, assign, readonly ) char separatorChar;

@end
