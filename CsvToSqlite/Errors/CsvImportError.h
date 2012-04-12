#import <Foundation/Foundation.h>

enum CsvImportErrorsEnum
{
   CSV_NO_ERROR = 0,
   CSV_SQL_BAD_TABLE_NAME
};
typedef NSInteger CsvImportErrors;

@interface CsvImportError : NSError

-(id)initWithErrorCode:( NSInteger )errorCode_;

@end
