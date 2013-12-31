### Library 
This is a library for parsing simple *.CSV files.  
The library does not fully comply to rfc4180 because we do not support quoted values.

The main goal is importing *.CSV data to the SQLite database with the minimal memory footprint.

```
License : BSD
```

### Dependencies : 
1. dodikk / ObjcScopedGuard <https://github.com/dodikk/ObjcScopedGuard.git>
2. dodikk / ESLocale <https://github.com/dodikk/ESLocale.git>
3. ccgus / fmdb <https://github.com/ccgus/fmdb.git>
4. dodikk / ESDatabaseWrapper <https://github.com/dodikk/ESDatabaseWrapper.git>

The recommended approach is using sub-projects. However, **cocoapods** users are welcome to enter the ```pod install CsvToSqlite``` command



### TODO:
```
Make the library rfc4180 compliant. Start using davedelong / CHCSVParser for better CSV handling
```