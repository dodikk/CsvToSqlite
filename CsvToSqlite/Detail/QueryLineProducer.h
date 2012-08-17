#ifndef CsvToSqlite_QueryLineProducer_h
#define CsvToSqlite_QueryLineProducer_h

#import <Foundation/Foundation.h>

#include <string>
#include <vector>

typedef BOOL (^QueryLineProducer)( const std::string& line_
, NSString* tableName_
, std::vector< char >& buffer_
, NSError** errorPtr_ );

#endif
