#import "CsvColumnsParserTest.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

#import "CsvColumnsParser.h"
#import "StreamUtils.h"

#import "WindowsLineReader.h"
#import "UnixLineReader.h"

#include <fstream>

@implementation CsvColumnsParserTest

-(void)testColumnsParserAllowsInit
{
   STAssertThrows( [ CsvColumnsParser new ], @"unexpected @init support" );
}

-(void)testColumnsParserRequiresSeparatorChar
{
   char separator = ';';

   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: separator
                                                                          comment: '#'
                                                                       lineReader: [ WindowsLineReader new ] ];
   STAssertNotNil( parser_, @"valid object expected" );
   STAssertTrue( separator == parser_->_separator, @"Incorrect initialization" );
}

-(void)testParseColumnsReturnsCorrectValues
{
   std::ifstream stream_;
   [ StreamUtils csvStream: stream_ 
              withFileName: @"Campaigns" ];

   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';'
                                                                          comment: '#'
                                                                       lineReader: [ WindowsLineReader new ]]; 
   NSOrderedSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
//   stream_.seekg( std::ios::beg );
   STAssertTrue( stream_.tellg() != 0, @"stream should have moved on" );
   stream_.close();
   
   STAssertTrue( [ result_ count ] == 6, @"Headers count mismatch" );
   STAssertTrue( [ result_ containsObject: @"Date"     ], @"Date     mismatch" );
   STAssertTrue( [ result_ containsObject: @"Visits"   ], @"Visits   mismatch" );
   STAssertTrue( [ result_ containsObject: @"Value"    ], @"Value    mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId1" ], @"FacetId1 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId2" ], @"FacetId2 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId3" ], @"FacetId3 mismatch - %@", result_ );
}

-(void)testParseColumnsReturnsNilForBadStream
{
   std::ifstream stream_;   
   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';'
                                                                          comment: '#'
                                                                       lineReader: [ WindowsLineReader new ] ]; 
   NSOrderedSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
   STAssertNil( result_, @"nil expected for invalid stream input" );
}

-(void)testParseColumnsReturnsNilForEmptyFile
{
   std::ifstream stream_;   
   [ StreamUtils csvStream: stream_ 
              withFileName: @"Empty" ];
   
   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';'
                                                                          comment: '#'
                                                                       lineReader: [ WindowsLineReader new ] ]; 
   NSOrderedSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
   STAssertNil( result_, @"nil expected for invalid stream input" );
}

-(void)testParseColumnsSupportsUnix
{
   std::ifstream stream_;
   [ StreamUtils csvStream: stream_ 
              withFileName: @"UnixTest" ];
   
   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';'
                                                                          comment: '#'
                                                                       lineReader: [ UnixLineReader new ]]; 
   NSOrderedSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
//   STAssertTrue( stream_.seekg( std::ios::beg ) != 0, @"stream should have moved on" );
   stream_.close();
   
   STAssertTrue( [ result_ count ] == 6, @"Headers count mismatch" );
   STAssertTrue( [ result_ containsObject: @"Date"     ], @"Date     mismatch" );
   STAssertTrue( [ result_ containsObject: @"Visits"   ], @"Visits   mismatch" );
   STAssertTrue( [ result_ containsObject: @"Value"    ], @"Value    mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId1" ], @"FacetId1 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId2" ], @"FacetId2 mismatch" );
   STAssertTrue( [ result_ containsObject: @"FacetId3" ], @"FacetId3 mismatch" );
}

-(void)testParserDoesNotDetectColumns
{
   std::ifstream stream_;
   [ StreamUtils csvStream: stream_ 
              withFileName: @"Unix-NoHeader" ];
   
   CsvColumnsParser* parser_ = [ [ CsvColumnsParser alloc ] initWithSeparatorChar: ';'
                                                                          comment: '#'
                                                                       lineReader: [ UnixLineReader new ] ]; 
   NSOrderedSet* result_ = [ parser_ parseColumnsFromStream: stream_ ];
   
//   STAssertTrue( stream_.seekg( std::ios::beg ) != 0, @"stream should have moved on" );
   stream_.close();
   
   STAssertTrue( [ result_ count ] == 6, @"Headers count mismatch" );
   STAssertTrue( [ result_ containsObject: @"20081222"     ], @"Date     mismatch" );
   STAssertTrue( [ result_ containsObject: @"24"   ], @"Visits   mismatch" );
   STAssertTrue( [ result_ containsObject: @"0"    ], @"Value    mismatch" );
   STAssertTrue( [ result_ containsObject: @"10000000-0000-0000-0000-000000000000" ], @"FacetId1 mismatch" );
   STAssertTrue( [ result_ containsObject: @"16000000-0000-0000-0000-000000000000" ], @"FacetId2 mismatch" );
   STAssertTrue( [ result_ containsObject: @"00000000-0000-0000-0000-000000000000" ], @"FacetId3 mismatch" );
}

@end
