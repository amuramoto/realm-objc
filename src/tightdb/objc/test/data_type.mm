//
//  data_type.mm
//  TightDB
//
// Check that data type enumeration values are in synch with the core library
//

#import <SenTestingKit/SenTestingKit.h>

#import "TestHelper.h"

#import <tightdb/objc/type.h>
#import <tightdb/data_type.hpp>

@interface TestDataType: SenTestCase
@end
@implementation TestDataType

- (void)testDataType
{
    @autoreleasepool {
        STAssertEquals((int)tightdb_Bool,   (int)tightdb::type_Bool,   @"Bool");
        STAssertEquals((int)tightdb_Int,    (int)tightdb::type_Int,    @"Int");
        STAssertEquals((int)tightdb_Float,  (int)tightdb::type_Float,  @"Float");
        STAssertEquals((int)tightdb_Double, (int)tightdb::type_Double, @"Double");
        STAssertEquals((int)tightdb_String, (int)tightdb::type_String, @"String");
        STAssertEquals((int)tightdb_Binary, (int)tightdb::type_Binary, @"Binary");
        STAssertEquals((int)tightdb_Date,   (int)tightdb::type_Date,   @"Date");
        STAssertEquals((int)tightdb_Table,  (int)tightdb::type_Table,  @"Table");
        STAssertEquals((int)tightdb_Mixed,  (int)tightdb::type_Mixed,  @"Mixed");
    }
    TEST_CHECK_ALLOC;
}

@end
