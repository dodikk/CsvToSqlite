#import <Foundation/Foundation.h>

extern NSString* const SQL_NONE    ;
extern NSString* const SQL_BLOB    ;
extern NSString* const SQL_BOOLEAN ;
extern NSString* const SQL_CHAR    ;
extern NSString* const SQL_DATE    ;
extern NSString* const SQL_DATETIME;
extern NSString* const SQL_INT     ;
extern NSString* const SQL_INTEGER ;
extern NSString* const SQL_NUMERIC ;
extern NSString* const SQL_REAL    ;
extern NSString* const SQL_TEXT    ;
extern NSString* const SQL_VARCHAR ;


@interface SqliteTypes : NSObject

+(NSSet*)typesSet;

@end

#ifdef __cplusplus
extern "C" {
#endif

BOOL isSqlDateType( NSString* sqlType_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
