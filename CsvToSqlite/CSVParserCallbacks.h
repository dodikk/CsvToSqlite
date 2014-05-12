#ifndef CsvToSqlite_CSVParserCallbacks_h
#define CsvToSqlite_CSVParserCallbacks_h

#import <string>
#import <vector>

/**
 A block that is invoked every time the CSV comment is encountered.
 All comments should be above the CSV schema.
 
 @param line_ An immutable C++ string that holds the comment.
 */
typedef void (^CSVOnCommentCallback)( const std::string& line_ );

#endif
