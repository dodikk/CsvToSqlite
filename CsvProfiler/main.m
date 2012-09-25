#import <UIKit/UIKit.h>

#import "DbImportTest.h"



int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        DbImportTest* test_ = [ DbImportTest new ];
        
        [ test_ setUp ];
        [ test_ testCampaignImportRealDbWin ];
        [ test_ tearDown ];
        
        return 0;
    }
}
