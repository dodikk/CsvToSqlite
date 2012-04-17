#import <Foundation/Foundation.h>
#import "DbWrapper.h"

@interface MockDb : NSObject<DbWrapper>

-(NSArray*)queriesLog;

@end
