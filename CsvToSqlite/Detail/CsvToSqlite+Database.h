#import "CsvToSqlite.h"


@protocol ESWritableDbWrapper;
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

