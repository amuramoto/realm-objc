//
//  group.m
//  TightDB
//
//  Test save/load on disk of a realm with one table
//

#import "RLMTestCase.h"

#import <realm/objc/Realm.h>
#import <realm/objc/RLMRealm.h>

@interface RLMTestObj2 : RLMRow

@property (nonatomic, copy) NSString *first;
@property (nonatomic, assign) NSInteger second;

@end

@implementation RLMTestObj2
@end

RLM_TABLE(RLMTestTable2, RLMTestObj2);

@interface MACTestRealm : RLMTestCase

@end

@implementation MACTestRealm

- (void)testRealm {
    // Load the realm
    RLMRealm *realm = [self realmWithTestPath];
    XCTAssertTrue(realm, @"Realm from disk should be valid");

    // Create new table in realm
    [realm beginWriteTransaction];
    RLMTestTable2 *t = (RLMTestTable2 *)[realm createTableNamed:@"test" objectClass:[RLMTestObj2 class]];

    // Verify
    XCTAssertEqual(t.columnCount, (NSUInteger)2, @"Should have 2 columns");
    XCTAssertEqual(t.rowCount, (NSUInteger)0, @"Should have 0 rows");

    // Modify table
    [t addRow:@[@"Test", @23]];
    [realm commitWriteTransaction];

    // Verify
    RLMRealm *realm2 = [self realmWithTestPath];
    RLMTestTable2 *t2 = (RLMTestTable2 *)[realm2 tableNamed:@"test"];
    XCTAssertEqual(t2.rowCount, (NSUInteger)1, @"test table should have one row");
}

- (void)testGetTable {
    XCTAssertNil([[self realmWithTestPath] tableNamed:@"noTable"], @"Table does not exist");
}

- (void)testRealmTableCount {
    XCTAssertEqual([[self realmWithTestPath] tableCount], (NSUInteger)0, @"No tables added");
    [[self realmWithTestPath] writeUsingBlock:^(RLMRealm *realm) {
        [realm createTableNamed:@"table" objectClass:[RLMTestObj2 class]];
    }];
    XCTAssertEqual([[self realmWithTestPath] tableCount], (NSUInteger)1, @"1 table added");
}

@end
