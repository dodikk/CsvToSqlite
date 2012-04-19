#ifndef CsvToSqlite_CsvMacros_h
#define CsvToSqlite_CsvMacros_h

#define INIT_ASSERT_NIL( X ) \
   if ( nil == X )           \
   {                         \
      return nil;            \
   }

#define INIT_ASSERT_EMPTY_STRING( X )            \
   if ( nil == X || [ @"" isEqualToString: X ] ) \
   {                                             \
      return nil;                                \
   }


#define CHECK_ERROR__RET_BOOL( ERROR_PTR ) \
   if ( nil != *ERROR_PTR )                \
   {                                       \
      NSLog( @"%@", *ERROR_PTR );          \
      return NO;                           \
   }


#define CHECK_ERROR__RET( ERROR_PTR ) \
   if ( nil != *ERROR_PTR )           \
   {                                  \
      NSLog( @"%@", *ERROR_PTR );     \
      return;                         \
   }


#endif
