#import "CsvToSqlite.h"
#import "DbWrapper.h"

@interface CsvToSqlite (Database)

-(id<DbWrapper>)castedWrapper;

-(void)openDatabaseWithError:( NSError** )errorPtr_;

-(void)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_;

-(void)storeLine:( NSString* )line_
         inTable:( NSString* )tableName_
           error:( NSError** )errorPtr_;

-(void)closeDatabase;

@end
