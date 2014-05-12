//
//  LineParserFunctions.hpp
//  CsvToSqlite
//
//  Created by Oleksandr Dodatko on 25/04/2014.
//
//

#ifndef CsvToSqlite_LineParserFunctions_hpp
#define CsvToSqlite_LineParserFunctions_hpp

#include <string>
#include <vector>
#import <Foundation/Foundation.h>


@class StringsChannel;


OBJC_EXTERN void generalParseAndStoreLine(
  const std::string& line_
, NSString* tableName_
, std::vector< char >& buffer_
, const char* headerFields_
, StringsChannel* queryChannel_
, NSError** errorPtr_ );

#endif

