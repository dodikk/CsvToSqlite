#ifndef CsvToSqlite_CsvLineEndings_h
#define CsvToSqlite_CsvLineEndings_h

#ifdef __OBJC__
    #import <Foundation/Foundation.h>
#endif

/**
 Line ending style enumeration.
 */

#ifdef __OBJC__
typedef NS_ENUM( NSInteger, CsvLineEndings )
#else
enum CsvLineEndingsEnum
#endif // __OBJC__
{
    /**
     CR LF - Windows style.
     */
   CSV_LE_WIN        = 0x0D0A,
    
    /*
     LF - Unix and Mac OS X style
     */
   CSV_LE_UNIX       = 0x0A  ,
    
    
    /**
     CR - Legacy mac style
     */
   CSV_LE_MAC_LEGACY = 0x0D  ,
};

#ifndef __OBJC__
typedef NSInteger CsvLineEndings;
#endif // __OBJC__

#endif // CsvToSqlite_CsvLineEndings_h
