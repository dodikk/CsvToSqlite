#import "MockDb.h"

@interface MockDb()

@property ( nonatomic, strong ) NSMutableArray* mQueriesLog;

@end


@implementation MockDb

@synthesize mQueriesLog;

-(id)initWithPath:(NSString*)inPath_
{
   return [ super init ];
}

-(NSArray*)queriesLog
{
   return [ self.mQueriesLog copy ];
}


#pragma mark -
#pragma mark DbWrapper
-(BOOL)open
{
   self.mQueriesLog = [ NSMutableArray new ];
   return YES;
}

// TODO : adk - maybe cleanup the log
-(BOOL)close
{
   return YES;
}


-(NSError*)lastError
{
   return nil;
}

-(BOOL)tableExists:(NSString*)tableName_
{
   return NO;
}

-(BOOL)insert:( NSString* )sql_
        error:( NSError** )error_
{
   [ self.mQueriesLog addObject: sql_ ];
   return YES;
}

-(BOOL)createTable:( NSString* )sql_
             error:( NSError** )error_
{
   [ self.mQueriesLog addObject: sql_ ];
   return YES;
}

@end
