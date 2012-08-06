#import "CsvSchemaValidatorTest.h"

#import "DBTableValidator.h"

@implementation CsvSchemaValidatorTest

-(void)setUp
{
    schema_ = @{
    @"Date"     : @"DATETIME",
    @"Visits"   : @"INTEGER" ,
    @"Value"    : @"INTEGER" ,
    @"FacetId1" : @"VARCHAR" ,
    @"FacetId2" : @"VARCHAR" ,
    @"FacetId3" : @"VARCHAR"
    };

    primaryKey_ = [ NSOrderedSet orderedSetWithObjects:
                     @"Date"
                   , @"Visits"
                   , @"Value"                    
                   , @"FacetId1"
                   , @"FacetId2"
                   , @"FacetId3"                                
                   , nil ];
}

-(void)testAnyNilSchemaLeadsToNO
{
    BOOL result_ = NO;

    {
        result_ = [ DBTableValidator csvSchema: nil
                                  withDefaults: nil
                            matchesTableSchema: schema_ ];

        STAssertFalse( result_, @"false expected" );
    }

    {
        result_ = [ DBTableValidator csvSchema: primaryKey_
                                  withDefaults: nil
                            matchesTableSchema: nil ];
        
        STAssertFalse( result_, @"false expected" );
    }


    {
        result_ = [ DBTableValidator csvSchema: primaryKey_
                                  withDefaults: nil
                            matchesTableSchema: schema_ ];
        
        STAssertTrue( result_, @"true expected" );
    }
    
    {
        primaryKey_ = [ NSOrderedSet orderedSetWithObjects: 
                       @"Date"
                       , @"Visits"
                       , @"FacetId2"
                       , @"FacetId3"                                
                       , nil ];
        
        result_ = [ DBTableValidator csvSchema: primaryKey_
                                  withDefaults: nil
                            matchesTableSchema: schema_ ];
        
        STAssertFalse( result_, @"incomplete schema should not pass" );
        
    }
}

-(void)testUnsupportedSqlTypeReusltsInNo
{
    BOOL result_ = YES;

    NSDictionary* invalidSchema_ = @{
    @"Date"     : @"a",
    @"Visits"   : @"b",
    @"Value"    : @"c",
    @"FacetId1" : @"d",
    @"FacetId2" : @"e",
    @"FacetId3" : @"f" };

    result_ = [ DBTableValidator csvSchema: primaryKey_
                              withDefaults: nil
                        matchesTableSchema: invalidSchema_ ];

    STAssertFalse( result_, @"false expected" );
}

@end
