#import "BuiltInApiTest.h"

#import <sqlite3.h>

@implementation BuiltInApiTest

-(void)testDatabaseIsInSerializedMode
{    
    int isThreadSafe_ = sqlite3_threadsafe();
    STAssertTrue( 0 != isThreadSafe_, @"Apple compiles sqlite with mutexes enabled" );
    STAssertTrue( SQLITE_CONFIG_MULTITHREAD  == isThreadSafe_, @"Apple builds in multithreaded mode" );
}

-(void)testCanSwitchTo
{
    int errorCode_ = sqlite3_config( SQLITE_CONFIG_SERIALIZED );
    STAssertTrue( errorCode_ == SQLITE_OK, @"SQLite should be able to switch in Serialized mode" );
}

-(void)testOpenInSerializedMode
{
    NSBundle* mainBundle_ = [ NSBundle bundleForClass: [ self class ] ];
    NSString* dbPath_ = [ mainBundle_ pathForResource: @"2"
                                               ofType: @"sqlite" ];
    
    sqlite3* dbHandle_ = NULL;

    int error_  = sqlite3_open_v2
    ( 
        [ dbPath_ UTF8String ], &dbHandle_, 
        SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, 
        NULL 
    );
    sqlite3_close( dbHandle_ );
    
    
    STAssertTrue( error_ == SQLITE_OK, @"SQLite can open DB in serialized mode" );
}

@end
