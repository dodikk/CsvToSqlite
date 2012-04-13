#import <Foundation/Foundation.h>

enum CsvImportErrorsEnum
{
   CSV_NO_ERROR = 0,
   CSV_SQL_BAD_TABLE_NAME,
   CSV_SQL_SCHEMA_MISMATCH,
   CSV_PARSER_INITIALIZATION_ERROR,
};
typedef NSInteger CsvImportErrors;

@interface CsvImportError : NSError

-(id)initWithErrorCode:( NSInteger )errorCode_;

@end
