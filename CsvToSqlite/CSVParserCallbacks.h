#ifndef CsvToSqlite_CSVParserCallbacks_h
#define CsvToSqlite_CSVParserCallbacks_h

#import <string>
#import <vector>

typedef void (^CSVOnCommentCallback)( const std::string& line_ );

#endif
