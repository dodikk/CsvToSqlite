#import <Foundation/Foundation.h>


/**
 Error codes for CsvImportError
 */
typedef NS_ENUM( NSInteger, CsvImportErrors)
{
    /**
     Import successfull.
     */
    CSV_NO_ERROR = 0,

    /**
     Table name string is nil or empty.
     */
    CSV_SQL_BAD_TABLE_NAME,

    /**
     Actual CSV schema does not match the expected one for SQL.
     */
    CSV_SQL_SCHEMA_MISMATCH,
    
    /**
     A parser for CSV columns has not been initialized properly.
     */
    CSV_PARSER_INITIALIZATION_ERROR,
};



/**
 A base class for CSV conversion errors :
 
 * CsvBadTableNameError
 * CsvInitializationError
 * CsvSchemaMismatchError

 */
@interface CsvImportError : NSError


/**
 A preferred initializer. Initializes an NSError object with one of the CsvImportErrors values.
 
 
 @param errorCode_ One of the constants defined in CsvImportErrors enum.
 Warning : Undefined behaviour for other values.
 
 @return A properly initialized object.
 */
-(id)initWithErrorCode:( NSInteger )errorCode_;

@end
