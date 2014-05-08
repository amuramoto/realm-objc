//
//  get_subtable.m
//  TightDB
//
// Demo code for short tutorial using Objective-C interface
//

#import "RLMTestCase.h"

#import <realm/objc/Realm.h>
#import <realm/objc/RLMRealm.h>

@interface RLMTestSubtableObj : RLMRow
@property BOOL hired;
@property int age;
@end

@implementation RLMTestSubtableObj
@end

RLM_TABLE(RLMTestSubtable, RLMTestSubtableObj);

@interface RLMTestObj : RLMRow
@property BOOL hired;
@property int age;
@property RLMTestSubtable *subtable;
@end

@implementation RLMTestObj
@end

RLM_TABLE(RLMTestTable, RLMTestObj);

@interface MACTestGetSubtable: RLMTestCase

@end

@implementation MACTestGetSubtable

- (void)testGetSubtable
{
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTestTable *table = (RLMTestTable *)[realm createTableNamed:@"table" objectClass:[RLMTestObj class]];
        
        [table addRow:@[@NO, @10, @[]]];
        [table.lastRow.subtable addRow:@[@YES, @42]];
        
        RLMTestSubtableObj *obj = table.lastRow.subtable.firstRow;
        XCTAssertEqual(obj.age, (int)42, @"Sub table row should be 42");
    }];
}

@end
