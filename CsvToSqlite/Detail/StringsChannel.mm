#import "StringsChannel.h"


@implementation StringsChannel
{
    NSUInteger _size;

    std::list< std::string > _data;

    NSCondition* _lock;
}

-(id)initWithSize:( NSUInteger )size_
{
    NSParameterAssert( size_ != 0 );

    self = [ super init ];

    if ( self )
    {
        self->_size = size_;
        self->_lock = [ NSCondition new ];
    }

    return self;
}

+(id)newStringsChannelWithSize:( NSUInteger )size_
{
   // Cocoapods project fails with [[ self alloc ] initWithSize:]
   return [ [ StringsChannel alloc ] initWithSize: size_ ];
}

-(void)putString:( const std::string& )str_
{
    [ self->_lock lock ];

    while ( self->_data.size() >= self->_size )
    {
        [ self->_lock wait ];
    }

    self->_data.push_back( str_ );
    [ self->_lock signal ];

    [ self->_lock unlock ];
}

-(void)putUnboundedString:( const std::string& )str_
{
    [ self->_lock lock ];

    self->_data.push_back( str_ );
    [ self->_lock signal ];

    [ self->_lock unlock ];
}

-(std::string)popString
{
    [ self->_lock lock ];

    std::string result_;

    if ( self->_data.size() >= self->_size )
    {
        result_ = *self->_data.begin();
        self->_data.pop_front();

        if ( self->_data.size() < self->_size )
            [ self->_lock signal ];
    }
    else
    {
        while ( self->_data.size() == 0 )
        {
            [ self->_lock wait ];
        }

        result_ = *self->_data.begin();
        self->_data.pop_front();
        if ( self->_data.size() < self->_size )
            [ self->_lock signal ];
    }

    [ self->_lock unlock ];

    return result_;
}

@end
