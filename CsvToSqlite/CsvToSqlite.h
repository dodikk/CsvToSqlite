#import <Foundation/Foundation.h>

@interface CsvToSqlite : NSObject

@property ( nonatomic, strong, readonly ) NSString* databaseName;
@property ( nonatomic, strong, readonly ) NSString* dataFileName;
@property ( nonatomic, strong, readonly ) NSDictionary* schema  ;


-(id)initWithDatabaseName:( NSString* )databaseName_
             dataFileName:( NSString* )dataFileName_
           databaseSchema:( NSDictionary* )schema_;

@end
