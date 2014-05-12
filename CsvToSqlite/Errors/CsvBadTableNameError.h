#import <CsvToSqlite/Errors/CsvImportError.h>


/**
 Table name does not conform to SQL standard.
 
 Note : Current implementation checks only whether table name string is nil or empty.
 You'll get an error from the SQL engine for other cases.
 */
@interface CsvBadTableNameError : CsvImportError
@end
