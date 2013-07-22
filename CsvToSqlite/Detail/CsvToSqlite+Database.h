#import "CsvToSqlite.h"

#include <string>
#include <vector>

@class StringsChannel;

@interface CsvToSqlite (Database)

-(id<ESWritableDbWrapper>)castedWrapper;

-(BOOL)openDatabaseWithError:( NSError** )errorPtr_;

-(BOOL)createTableNamed:( NSString* )tableName_
                  error:( NSError** )errorPtr_;

-(void)beginTransaction;
-(void)commitTransaction;
-(void)rollbackTransaction;

-(void)closeDatabase;

@property ( nonatomic ) NSString* headerFieldsForInsert;
@property ( nonatomic ) NSString* defaultValuesForInsert;


-(NSString*)computeHeaderFieldsForInsert;
-(NSString*)computeDefaultValuesForInsert;

@end

void generalParseAndStoreLine( const std::string& line_
                              , NSString* tableName_
                              , std::vector< char >& buffer_
                              , const char* headerFields_
                              , StringsChannel* queryChannel_
                              , NSError** errorPtr_ );