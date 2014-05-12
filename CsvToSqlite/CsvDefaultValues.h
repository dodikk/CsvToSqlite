#import <Foundation/Foundation.h>


/**
 A class to hold key-value pairs of devault values for gaps in the CSV content
 */
@interface CsvDefaultValues : NSObject

/**
 Columns that have default values.
 */
@property ( nonatomic, readonly ) NSOrderedSet* columns ;

/**
 Default values. The order matches wiht the order of columns .
 */
@property ( nonatomic, readonly ) NSArray*      defaults;


/**
 Assigns a default value to a given column.
 
 Warning : no validation is made for performance reasons.
 
 
 @param defaultValue_ A placeholder value to fill empty content with.
 @param column_ Name of the column that might contain empty content.
 
 */
-(void)addDefaultValue:( NSString* )defaultValue_
             forColumn:( NSString* )column_;


/**
 Number of columns that have default values.
 */
-(NSUInteger)count;

/**
 Returns the structure to the initial empty state.
 */
-(void)clear;

@end
