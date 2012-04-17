#ifndef CsvToSqlite_CsvLineEndings_h
#define CsvToSqlite_CsvLineEndings_h


enum CsvLineEndingsEnum
{
   CSV_LE_WIN        = 0x0D0A,
   CSV_LE_UNIX       = 0x0A  ,
   CSV_LE_MAC_LEGACY = 0x0D  ,
};
typedef NSInteger CsvLineEndings;


#endif
