#ifndef CsvToSqlite_CsvLineEndings_h
#define CsvToSqlite_CsvLineEndings_h


    #import <Foundation/Foundation.h>


/**
 Line ending style enumeration.
 */
typedef NS_ENUM( NSInteger, CsvLineEndings )
{
    /**
     CR LF - Windows style.
     */
   CSV_LE_WIN        = 0x0D0A,
    
    /**
     LF - Unix and Mac OS X style
     */
   CSV_LE_UNIX       = 0x0A  ,
    
    
    /**
     CR - Legacy mac style
     */
   CSV_LE_MAC_LEGACY = 0x0D  ,
};

#endif // CsvToSqlite_CsvLineEndings_h
