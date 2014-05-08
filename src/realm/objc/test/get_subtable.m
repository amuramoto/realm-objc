//
//  get_subtable.m
//  TightDB
//
// Demo code for short tutorial using Objective-C interface
//

#import "RLMTestCase.h"

#import <realm/objc/Realm.h>
#import <realm/objc/RLMRealm.h>

@interface RLMTestObj : RLMRow

@property (nonatomic, assign) BOOL hired;
@property (nonatomic, assign) int age;

@end

@implementation RLMTestObj
@end

RLM_TABLE_TYPE_FOR_OBJECT_TYPE(RLMTestSubtable, RLMTestObj);

@interface MACTestGetSubtable: RLMTestCase

@end

@implementation MACTestGetSubtable

- (void)testGetSubtable
{
    [self createTestTableWithWriteBlock:^(RLMTable *table) {
        // Create table with all column types
        RLMDescriptor * desc = table.descriptor;
        [desc addColumnWithName:@"Outer" type:RLMTypeBool];
        [desc addColumnWithName:@"Number" type:RLMTypeInt];
        RLMDescriptor * subdesc = [desc addColumnTable:@"RLMTestSubtable"];
        [subdesc addColumnWithName:@"hired" type:RLMTypeBool];
        [subdesc addColumnWithName:@"age" type:RLMTypeInt];
        
        {
            [table addRow:@[@NO, @10, @[]]];
            RLMTable *subtable = table.lastRow[@"RLMTestSubtable"];
            [subtable addRow:@[@YES, @42]];
        }
        
        {
            RLMTable *subtable = table.lastRow[@"RLMTestSubtable"];
            RLMTestObj *obj = subtable.firstRow;
            XCTAssertEqual([obj[@"age"] integerValue], (NSInteger)42, @"Sub table row should be 42");
        }
    }];
}

@end
