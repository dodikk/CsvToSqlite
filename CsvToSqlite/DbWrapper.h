#import <Foundation/Foundation.h>

@protocol DbWrapper <NSObject>

-(id)initWithPath:(NSString*)inPath_;
-(BOOL)open;
-(BOOL)close;


-(NSError*)lastError;

-(BOOL)insert:( NSString* )sql_
        error:( NSError** )error_;

-(BOOL)createTable:( NSString* )sql_
             error:( NSError** )error_;

@end
