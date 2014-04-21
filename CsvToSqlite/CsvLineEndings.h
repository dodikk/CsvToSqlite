#ifndef CsvToSqlite_CsvLineEndings_h
#define CsvToSqlite_CsvLineEndings_h

/**
 Line ending style enumeration.
 */
enum CsvLineEndingsEnum
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
typedef NSInteger CsvLineEndings;


#endif
