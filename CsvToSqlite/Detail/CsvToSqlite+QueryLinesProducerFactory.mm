#import "CsvToSqlite+QueryLinesProducerFactory.h"

#import "CsvToSqlite+Database.h"
#import "CsvToSqlite+Test.h"

#import "CsvColumnsParser.h"
#import "CsvDefaultValues.h"


@implementation CsvToSqlite (QueryLinesProducerFactory)

-(BOOL)sqlSchemaHasDates
{
    __block BOOL result_ = NO;
    [ self.schema.allValues enumerateObjectsUsingBlock: ^( NSString* schemaType_, NSUInteger idx_, BOOL *stop_ )
    {
        if ( isSqlDateType( schemaType_ ) )
        {
            result_ = YES;
            *stop_  = YES;
        }
    } ];

    return result_;
}

-(QueryLineProducer)queryLinesProducerWithQueryChannel:( StringsChannel* )queryChannel_
{
    NSOrderedSet* defaultColumns_ = self.defaultValues.columns;
    NSMutableOrderedSet* schemaColumns_ = [ [ NSMutableOrderedSet alloc ] initWithArray: self.csvSchema.array ];
    [ schemaColumns_ unionOrderedSet: defaultColumns_ ];
    NSArray* headers_       = [ schemaColumns_ array ];
    NSString* headerFields_ = [ headers_ componentsJoinedByString: @", " ];

    NSUInteger requeredNumOfColumns_ = [ headers_ count ];

    QueryLineProducer generalQueryLinesProducer_ = ^BOOL( const std::string& line_
                                                         , NSString* tableName_
                                                         , std::vector< char >& buffer_
                                                         , NSError** errorPtr_ )
    {
        return generalQueryLinesProducer( self
                                         , line_
                                         , tableName_
                                         , buffer_
                                         , queryChannel_
                                         , headerFields_
                                         , requeredNumOfColumns_
                                         , errorPtr_ );
    };

    if ( [ self sqlSchemaHasDates ] )
    {
        return generalQueryLinesProducer_;
    }
    else if ( [ @"yyyyMMdd" isEqualToString: self.csvDateFormat ] )
    {
        //cache access to required properties
        NSOrderedSet* csvSchema_ = self.csvSchema;
        NSDictionary* schema_    = self.schema;
        char separator_          = self.columnsParser->_separator;
        CsvDefaultValues* defaultValues_ = self.defaultValues;
        const char* headerFieldsStr_ = [ headerFields_ cStringUsingEncoding: NSUTF8StringEncoding ];

        return ^BOOL( const std::string& line_
                     , NSString* tableName_
                     , std::vector< char >& buffer_
                     , NSError** errorPtr_ )
        {
            //use headerFields_ value to own headerFieldsStr_ ptr in block
            const char* localHeaderFieldsStr_ = headerFields_ ? headerFieldsStr_ : "";

            return fastQueryLinesProducer1( line_
                                           , tableName_
                                           , buffer_
                                           , localHeaderFieldsStr_
                                           , requeredNumOfColumns_
                                           , defaultValues_
                                           , csvSchema_
                                           , schema_
                                           , separator_
                                           , queryChannel_
                                           , errorPtr_ );
        };
    }
    else if ( [ @"yyyy-MM-dd" isEqualToString: self.csvDateFormat ] )
    {
        return ^BOOL( const std::string& line_
                     , NSString* tableName_
                     , std::vector< char >& buffer_
                     , NSError** errorPtr_ )
        {
            return queryLinesProducer2( self
                                       , line_
                                       , tableName_
                                       , queryChannel_
                                       , errorPtr_ );
        };
    }

    return generalQueryLinesProducer_;
}

@end
