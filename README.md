This is a library for parsing simple *.CSV files.  
The library does not fully comply to rfc4180 because we do not support quoted values.

The main goal is importing *.CSV data to the SQLite database with the minimal memory footprint.


Dependencies : 
1. dodikk / ObjcScopedGuard
git://github.com/dodikk/ObjcScopedGuard.git
-----

2. dodikk / ESLocale
git clone git://github.com/dodikk/ESLocale.git
-----

3. ccgus / fmdb
git clone git://github.com/ccgus/fmdb.git
-----

4. dodikk / ESDatabaseWrapper
git clone https://github.com/dodikk/ESDatabaseWrapper.git
-----

License : BSD

TODO : Make the library rfc4180 compliant. Start using davedelong / CHCSVParser for better CSV handling
