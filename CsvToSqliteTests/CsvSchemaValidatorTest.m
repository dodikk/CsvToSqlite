#import "CsvSchemaValidatorTest.h"

#import "DBTableValidator.h"

@implementation CsvSchemaValidatorTest

-(void)setUp
{
    schema_ = [ NSDictionary dictionaryWithObjectsAndKeys:
                 @"DATETIME", @"Date"
               , @"INTEGER" , @"Visits"
               , @"INTEGER" , @"Value"                            
               , @"VARCHAR" , @"FacetId1"
               , @"VARCHAR" , @"FacetId2"
               , @"VARCHAR" , @"FacetId3"                            
               , nil ];
    
    
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

    NSDictionary* invalidSchema_ = [ NSDictionary dictionaryWithObjectsAndKeys:
                                      @"a" , @"Date"
                                    , @"b" , @"Visits"
                                    , @"c" , @"Value"                            
                                    , @"d" , @"FacetId1"
                                    , @"e" , @"FacetId2"
                                    , @"f" , @"FacetId3"                            
                                    , nil ];

    result_ = [ DBTableValidator csvSchema: primaryKey_
                              withDefaults: nil
                        matchesTableSchema: invalidSchema_ ];

    STAssertFalse( result_, @"false expected" );

}

@end
