#import "SqliteTypes.h"


NSString* const SQL_NONE     = @"NONE"    ;
NSString* const SQL_BLOB     = @"BLOB"    ;
NSString* const SQL_BOOLEAN  = @"BOOLEAN" ;
NSString* const SQL_CHAR     = @"CHAR"    ;
NSString* const SQL_DATE     = @"DATE"    ;
NSString* const SQL_DATETIME = @"DATETIME";
NSString* const SQL_INT      = @"INT"     ;
NSString* const SQL_INTEGER  = @"INTEGER" ;
NSString* const SQL_NUMERIC  = @"NUMERIC" ;
NSString* const SQL_REAL     = @"REAL"    ;
NSString* const SQL_TEXT     = @"TEXT"    ;
NSString* const SQL_VARCHAR  = @"VARCHAR" ;


static NSSet* TYPES_SET = nil;

@implementation SqliteTypes

+(NSSet*)typesSet
{
   if ( nil == TYPES_SET )
   {
      TYPES_SET = [ NSSet setWithObjects:
                    SQL_NONE     ,
                    SQL_BLOB     ,
                    SQL_BOOLEAN  ,
                    SQL_CHAR     ,
                    SQL_DATE     ,
                    SQL_DATETIME ,
                    SQL_INT      ,
                    SQL_INTEGER  ,
                    SQL_NUMERIC  ,
                    SQL_REAL     ,
                    SQL_TEXT     ,
                    SQL_VARCHAR  ,
                    nil ];
   }

   return TYPES_SET;
}

@end 

BOOL isSqlDateType( NSString* sqlType_ )
{
    BOOL hasDatetime_ = [ sqlType_ isEqualToString: SQL_DATETIME ];
    BOOL hasDate_     = [ sqlType_ isEqualToString: SQL_DATE     ];

    return hasDatetime_ || hasDate_;
}
