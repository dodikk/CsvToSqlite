#include "LineParserFunctions.hpp"

#import "StringsChannel.h"


void generalParseAndStoreLine( const std::string& line_
                              , NSString* tableName_
                              , std::vector< char >& buffer_
                              , const char* headerFields_
                              , StringsChannel* queryChannel_
                              , NSError** errorPtr_ )
{
    static const char* insertFormat_ = "INSERT INTO '%s' ( %s ) %s;";
    const char* tableNameCStr_ = [ tableName_ cStringUsingEncoding: NSUTF8StringEncoding ];
    
    int requiredBufferSize_ = ::snprintf ( NULL, 0, insertFormat_
                                          , tableNameCStr_
                                          , headerFields_
                                          , line_.c_str() );
    
    if ( requiredBufferSize_ + 1 > buffer_.size() )
    {
        size_t newSizeForBuffer = static_cast<size_t>( requiredBufferSize_ ) + 1;
        buffer_.resize( newSizeForBuffer );
    }
    
    ::sprintf ( &buffer_[ 0 ], insertFormat_
               , tableNameCStr_
               , headerFields_
               , line_.c_str() );
    
    [ queryChannel_ putString: &buffer_[ 0 ] ];
}


