#import <Foundation/Foundation.h>


@class CsvToSqlite;

@interface StringProcessor : NSObject

@end

std::string fastConvertToSqlParams( CsvToSqlite* csvToSqlite_,
                                   const std::string &sourceString,
                                   NSUInteger requeredNumOfColumns_,
                                   NSError** errorPtr_ );

