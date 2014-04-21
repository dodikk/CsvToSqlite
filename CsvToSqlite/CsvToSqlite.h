#import <Foundation/Foundation.h>
#import <CsvToSqlite/CsvLineEndings.h>

#include <CsvToSqlite/CSVParserCallbacks.h>

@class CsvDefaultValues;


/**
 A class that imports a downloaded CSV file to a new table of the SQLite database.
 Main Features :
 
 * SQL schema validation
 * Both Windows (CR,LF) and Unix (LF) line endings supported
 * Custom date formats support
 * Optimized for ANSI formatted dates
 * Optional columns support
 
 All methods are performed synchronously. Make sure to not invoke them on the main thread.
 */
@interface CsvToSqlite : NSObject

/**
 A value from the initializer.
 Full path to the SQLite database for writing.
 */
@property ( nonatomic, readonly  ) NSString*     databaseName  ;


/**
 A value from the initializer.
 Full path to the CSV file to import from.
 */
@property ( nonatomic, readonly  ) NSString*     dataFileName  ;

/**
 A value from the initializer.
 A dictionary of column names and their types. Column names must match those in the CSV file.
 */
@property ( nonatomic, readonly  ) NSDictionary* schema        ;

/**
 A value from the initializer.
 An ordered set of columns for the SQL primary key constraint.
 */
@property ( nonatomic, readonly  ) NSOrderedSet* primaryKey    ;

/**
 A value from the initializer.
 
 Default values for gaps in the CSV content.
 */
@property ( nonatomic, readonly  ) CsvDefaultValues* defaultValues;



/**
 Date format for CSV columns. 
 
 Warning : It must be set before importing. Otherwise you'll get a crash
 */
@property ( nonatomic, readwrite ) NSString*     csvDateFormat ;


/**
 A block for handling non-standard CSV comments.
 */
@property ( nonatomic, copy      ) CSVOnCommentCallback onCommentCallback;





/**
 Actual database engine capable of executing raw SQL queries.
 Used mostly for unit testing.
 */
-(id)dbWrapper;


/**
 A legacy initializer.
 
 @param databaseName_ Full path to the SQLite database for writing. For example,
 ```
 NSString* databaseName_ = @"/tmp/1.sqlite";
 ```
 
 @param dataFileName_ Full path to the CSV file to import from. For example, 
 ```
 NSString* dataFileName_ = [ [ NSBundle mainBundle ] pathForResource: @"1" ofType: @"csv" ];
 ```
 
 @param schema_ A dictionary of column names and their types. Column names must match those in the CSV file.
 ```
 NSDictionary* schema_ = @{
 @"Date"    : @"DATETIME",
 @"Integer" : @"INTEGER",
 @"Name"    : @"VARCHAR",
 @"Id"      : @"VARCHAR",
 @"TypeId"  : @"INTEGER"
 };
 ```
 
 @param primaryKey_ An ordered set of columns for the SQL primary key constraint.
 ```
 NSOrderedSet* primaryKey_ = [ NSOrderedSet orderedSetWithObjects: @"Date", @"Id", @"TypeId", nil ];
 ```
 
 @return A properly initialized CsvToSqlite instance.
 */
-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_;

/**
 A legacy initializer.
 
 @param databaseName_ Full path to the SQLite database for writing. For example,
 ```
 NSString* databaseName_ = @"/tmp/1.sqlite";
 ```
 
 @param dataFileName_ Full path to the CSV file to import from. For example,
 ```
 NSString* dataFileName_ = [ [ NSBundle mainBundle ] pathForResource: @"1" ofType: @"csv" ];
 ```
 
 @param schema_ A dictionary of column names and their types. Column names must match those in the CSV file.
 ```
 NSDictionary* schema_ = @{
 @"Date"    : @"DATETIME",
 @"Integer" : @"INTEGER",
 @"Name"    : @"VARCHAR",
 @"Id"      : @"VARCHAR",
 @"TypeId"  : @"INTEGER"
 };
 ```
 
 @param primaryKey_ An ordered set of columns for the SQL primary key constraint.
 ```
 NSOrderedSet* primaryKey_ = [ NSOrderedSet orderedSetWithObjects: @"Date", @"Id", @"TypeId", nil ];
 ```
 
 @param defaults_ Sometimes CSV files have gaps in the content. You should specify some defaults for them unless you intentionally want to receive importing errors.
 
 @return A properly initialized CsvToSqlite instance.
 */
-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_;


/**
 A designated initializer
 
 
 @param databaseName_ Full path to the SQLite database for writing. For example,
 ```
 NSString* databaseName_ = @"/tmp/1.sqlite";
 ```
 
 @param dataFileName_ Full path to the CSV file to import from. For example,
 ```
 NSString* dataFileName_ = [ [ NSBundle mainBundle ] pathForResource: @"1" ofType: @"csv" ];
 ```
 
 @param schema_ A dictionary of column names and their types. Column names must match those in the CSV file.
 ```
 NSDictionary* schema_ = @{
 @"Date"    : @"DATETIME",
 @"Integer" : @"INTEGER",
 @"Name"    : @"VARCHAR",
 @"Id"      : @"VARCHAR",
 @"TypeId"  : @"INTEGER"
 };
 ```
 
 @param primaryKey_ An ordered set of columns for the SQL primary key constraint.
 ```
 NSOrderedSet* primaryKey_ = [ NSOrderedSet orderedSetWithObjects: @"Date", @"Id", @"TypeId", nil ];
 ```
 
 @param defaults_ Sometimes CSV files have gaps in the content. You should specify some defaults for them unless you intentionally want to receive importing errors.
 
 @param lineEndingStyle_ Line ending symbol. Available options :
 
 |Platform          |Line Ending|
 |------------------|-----------|
 |Windows           | CR LF     |
 |Unix, Mac OS X    | LF        |
 |Mac (PPC)         | CR        |
 
 @param separatorChar_ Record separator. Usually it is a comma ","

 @param commentChar_ Some applications use a non-standard CSV extension to store additional data such as timestamps.
 ```
 #LastModified=06/10/2013 11:37:05
 ```
 
 If the file conforms RFC 4180 just pass zero.
 
 
 @return A properly initialized CsvToSqlite instance.
 */
-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_
               primaryKey:( NSOrderedSet* )primaryKey_
            defaultValues:( CsvDefaultValues* )defaults_
          lineEndingStyle:( CsvLineEndings )lineEndingStyle_
      recordSeparatorChar:( char )separatorChar_
        recordCommentChar:( char )commentChar_;


/**
 This method performs importing action.
 
 @param tableName_ Name of the table to import to.
 @param error_ NSError out parameter. Do not pass NULL.
 
 @return YES for successfull input.
 NO in case of 
 
 * Schema validation
 * Inconsistent contents of the file
 
 An error object will be written to the "error_" pointer.
 */
-(BOOL)storeDataInTable:( NSString* )tableName_
                  error:( NSError** )error_;

@end
