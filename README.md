### Library 
This is a library for parsing simple *.CSV files.  
The library does not fully comply to rfc4180 because we do not support quoted values.

The main goal is importing *.CSV data to the SQLite database with the minimal memory footprint.

```
License : BSD
```

### Features
The library performs importing of CSV files to SQLite tables. We made our best to make it use as little memory as possible.

1. **Clear Objective-C interface** - the user sees only the facade class in Objective-C. All the tricks are 
2. **Low memory consuption** - C++ iostreams are used to avoid memory warnings since datasets may be fairly large
3. **Multiple line endings support** - both Windows ( CR LF ) and Unix (LF ) line endings are processed correctly
4. **SQL schema validation** - CSV column names are parsed and user specified types are assigned to columns. In case of column count or name mismatch an error is produced
5. **Time performance optimizations** - file IO (FS bound) and parsing operations (CPU bound) are performed on multiple threads and use the **producer-consumer** model.
6. **Non standard comments** - the CSV content may be preceeded by some 

```
The library does not fully comply to rfc4180 for speed and simplicity.
We do not support quoted values.
```

### Geting Started

Here is an example of CSV importer usage :

```objective-c
-(void)testImportWithInvalidDefauls
{
    NSString* csvPath_ = [ [ NSBundle bundleForClass: [ self class ] ] pathForResource: @"UnixTest3" 
                                                                                ofType: @"csv" ];

    NSDictionary* schema_ = @{
    @"Date"    : @"DATETIME",
    @"Integer" : @"INTEGER",
    @"Name"    : @"VARCHAR",
    @"Id"      : @"VARCHAR",
    @"TypeId"  : @"INTEGER"
    };

    NSOrderedSet* primaryKey_ = [ NSOrderedSet orderedSetWithObjects: @"Date", @"Id", @"TypeId", nil ];

    CsvDefaultValues* defaults_ = [ CsvDefaultValues new ];

    [ defaults_ addDefaultValue: @""
                      forColumn: @"Name" ];
    [ defaults_ addDefaultValue: @"10"
                      forColumn: @"TypeId" ];

    CsvToSqlite* converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"1.sqlite" 
                                                              dataFileName: csvPath_ 
                                                            databaseSchema: schema_ 
                                                                primaryKey: primaryKey_
                                                             defaultValues: defaults_
                                                             separatorChar: ';'
                                                               commentChar: '#'
                                                                lineReader: [ UnixLineReader new ]
                                                            dbWrapperClass: [ FMDatabase class ] ];
    converter_.csvDateFormat = @"yyyyMMdd";
    
 NSError* error_;
 [ converter_  storeDataInTable: @"Campaigns" 
                          error: &error_ ];
 XCTAssertNotNil( error_, @"Unexpected error" );
}
```


### Performance Tips and Tricks
Columns parsing is the largest bottleneck for this implementation of the CSV importer. For some datasets this step may be skipped.

In order to implement this, the original CSV line
```sql
Date      , Id, Visits
2014-01-01, 10, 100500
```

is converted to the query below:
```sql
INSERT INTO [TrafficStats]       - SQL Insert statement added
( Date, Id, Visits )             - Brackets added
VALUES                           - SQL keyword added
( '2014-01-01', '10', '100500' ) - Brackets and quotes added
```


1. The dataset does not contain any dates.
2. The dataset contains dates in ANSI format (**yyyy-MM-dd**) or any other format supported : by SQLite <http://www.sqlite.org/lang_datefunc.html>.
3. The dataset contains dates in the ```yyyyMMdd``` format




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

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/dodikk/csvtosqlite/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

