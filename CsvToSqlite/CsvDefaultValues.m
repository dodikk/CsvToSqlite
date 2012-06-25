#import "CsvDefaultValues.h"

@interface CsvDefaultValues()

@property ( nonatomic, readonly ) NSMutableOrderedSet* mutableColumns ;
@property ( nonatomic, readonly ) NSMutableArray*      mutableDefaults;

@end


@implementation CsvDefaultValues

@synthesize mutableColumns ;
@synthesize mutableDefaults;

@dynamic columns ;
@dynamic defaults;


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

@end
