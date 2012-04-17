#ifndef CsvToSqlite_CsvMacros_h
#define CsvToSqlite_CsvMacros_h

#define INIT_ASSERT_NIL( X ) \
   if ( nil == X )           \
   {                         \
      return nil;            \
   }

#define INIT_ASSERT_EMPTY_STRING( X ) \
   if ( nil == X || @"" == X )        \
   {                                  \
      return nil;                     \
   }


#define CHECK_ERROR__RET_BOOL( ERROR_PTR ) \
   if ( nil != *error_ )                   \
   {                                       \
      return NO;                           \
   }


#define CHECK_ERROR__RET( ERROR_PTR ) \
   if ( nil != *error_ )              \
   {                                  \
      return;                         \
   }


#endif
