#import "CsvToSqlite.h"

#include "QueryLineProducer.h"

@class StringsChannel;

@interface CsvToSqlite (QueryLinesProducerFactory)

-(QueryLineProducer)queryLinesProducerWithQueryChannel:( StringsChannel* )queryChannel_;

@end
