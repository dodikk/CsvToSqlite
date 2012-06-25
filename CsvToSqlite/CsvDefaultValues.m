#import "CsvDefaultValues.h"

@interface CsvDefaultValues()

@property ( nonatomic, strong ) NSMutableOrderedSet* mutableColumns ;
@property ( nonatomic, strong ) NSMutableArray*      mutableDefaults;

@end


@implementation CsvDefaultValues

@synthesize mutableColumns ;
@synthesize mutableDefaults;

@dynamic columns ;
@dynamic defaults;

-(id)init
{
    self = [ super init ];
    {
        self.mutableColumns  = [ NSMutableOrderedSet new ];
        self.mutableDefaults = [ NSMutableArray new ];
    }
    
    return self;
}

-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_
{
    if ( nil == defaultValue_ )
    {
        NSLog( @"[!!!WARNING!!!] - CsvDefaultValues : attempting to store nil value" );
        return;
    }
    else if ( nil == column_ )
    {
        NSLog( @"[!!!WARNING!!!] - CsvDefaultValues : attempting to store nil column" );        
        return;
    }

    [ self.mutableColumns  addObject: column_       ];
    [ self.mutableDefaults addObject: defaultValue_ ];
}

-(NSOrderedSet*)columns 
{
    return [ NSOrderedSet orderedSetWithOrderedSet: self.mutableColumns ];
}

-(NSArray*)defaults
{
    return [ NSArray arrayWithArray: self.mutableDefaults ];
}

-(NSUInteger)count
{
    NSUInteger valuesCount_ = [ self.mutableDefaults count ];
    NSUInteger columnCount_ = [ self.mutableColumns  count ];
    
    NSParameterAssert( columnCount_ == valuesCount_ );
    
    return valuesCount_;
}

-(void)clear
{
    self.mutableColumns  = [ NSMutableOrderedSet new ];
    self.mutableDefaults = [ NSMutableArray new ];
}

@end
