#import "CsvToSqlite.h"
#import "DbWrapper.h"

@interface CsvToSqlite (Database)

-(id<DbWrapper>)castedWrapper;

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_;

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_;

-(BOOL)storeLine:( NSString* )line_
         inTable:( NSString* )tableName_
           error:( NSError** )errorPtr_;

-(void)closeDatabase;

@end
