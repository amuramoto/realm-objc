//
//  shared_group.m
//  TightDB
//
// Demo code for short tutorial using Objective-C interface
//

#import "RLMTestCase.h"

#import <realm/objc/RLMFast.h>
#import <realm/objc/RLMTableFast.h>
#import <realm/objc/RLMViewFast.h>
#import <realm/objc/RLMRealm.h>

@interface RLMSharedObject : RLMRow
@property (nonatomic, assign) BOOL hired;
@property (nonatomic, assign) NSInteger age;
@end

@implementation RLMSharedObject
@end

RLM_TABLE(RLMSharedTable, RLMSharedObject);

@interface RLMIntegerObject : RLMRow
@property int integer;
@end

@implementation RLMIntegerObject
@end

@interface MACTestSharedGroup: RLMTestCase

@end

@implementation MACTestSharedGroup

- (void)testTransactionManager {
    
    // TODO: Update test to include more ASSERTS
    
    [[self realmWithTestPath] writeUsingBlock:^(RLMRealm *realm) {
        // Create new table in realm
        RLMSharedTable *table = [realm createTableNamed:@"table" objectClass:[RLMSharedObject class]];
        
        // Add some rows
        [table addRow:@[@YES, @50]];
        [table addRow:@[@YES, @52]];
        [table addRow:@[@YES, @53]];
        [table addRow:@[@YES, @54]];
    }];
    
    RLMRealm *realm = [self realmWithTestPath];
    RLMSharedTable *diskTable = [realm tableNamed:@"table"];
    for (NSUInteger i = 0; i < [diskTable rowCount]; i++) {
        RLMSharedObject *cursor = [diskTable rowAtIndex:i];
        NSLog(@"%zu: %ld", i, cursor.age);
        NSLog(@"%zu: %i", i, cursor.hired);
    }
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        RLMSharedTable *diskTable = [realm tableNamed:@"table"];
        NSLog(@"Disktable size: %zu", [diskTable rowCount]);
        for (NSUInteger i = 0; i < 50; i++) {
            [diskTable addRow:@[@YES, @(i)]];
        }
    }];
    
    [realm beginWriteTransaction];
    diskTable = [realm tableNamed:@"table"];
    NSLog(@"Disktable size: %zu", [diskTable rowCount]);
    for (NSUInteger i = 0; i < 50; i++) {
        [diskTable addRow:@[@YES, @(i)]];
    }
    [realm rollbackWriteTransaction];
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        RLMSharedTable *diskTable = [realm tableNamed:@"table"];
        NSLog(@"Disktable size: %zu", [diskTable rowCount]);
        for (NSUInteger i = 0; i < 50; i++) {
            [diskTable addRow:@[@YES, @(i)]];
        }
        
        XCTAssertNil([realm tableNamed:@"Does not exist"], @"Table does not exist");
    }];
    
    diskTable = [realm tableNamed:@"table"];
    NSLog(@"Disktable size: %zu", [diskTable rowCount]);
    
    XCTAssertThrows([diskTable removeAllRows], @"Not allowed in read transaction");
}

- (void)testTransactionManagerAtDefaultPath {
    // Create a new transaction manager
    RLMRealm *realm = [self realmWithTestPath];
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        [realm createTableNamed:@"table" objectClass:[RLMSharedObject class]];
    }];
    XCTAssertNotNil([realm tableNamed:@"table"], @"table shouldn't be nil");
}

- (void)testReadRealm {
    RLMRealm * realm = [self realmWithTestPath];
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *t = [realm createTableNamed:@"table" objectClass:[RLMIntegerObject class]];
        [t addRow:@[@10]];
    }];
    
    RLMTable *t = [realm tableNamed:@"table"];
    
    XCTAssertThrows([t addRow:nil], @"Is in read transaction");
    XCTAssertThrows([t addRow:@[@1]], @"Is in read transaction");
    
    RLMQuery *q = [t where];
    XCTAssertThrows([q removeRows], @"Is in read transaction");
    
    RLMView *v = [q findAllRows];
    
    XCTAssertThrows([v removeAllRows], @"Is in read transaction");
    XCTAssertThrows([[v where] removeRows], @"Is in read transaction");
    
    XCTAssertEqual(t.rowCount,    (NSUInteger)1, @"No rows have been removed");
    XCTAssertEqual([q countRows], (NSUInteger)1, @"No rows have been removed");
    XCTAssertEqual(v.rowCount,    (NSUInteger)1, @"No rows have been removed");
    
    XCTAssertNil([realm tableNamed:@"Does not exist"], @"Table does not exist");
}

- (void)testSingleTableTransactions {
    RLMRealm *realm = [self realmWithTestPath];
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *t = [realm createTableNamed:@"table" objectClass:[RLMIntegerObject class]];
        [t addRow:@[@10]];
    }];
    
    RLMTable *table = [realm tableNamed:@"table"];
    XCTAssertTrue([table rowCount] == 1, @"No rows have been removed");
    
    [realm beginWriteTransaction];
    [table addRow:@[@10]];
    [realm commitWriteTransaction];
    
    XCTAssertTrue([table rowCount] == 2, @"Rows were added");
}

- (void)testRealmExceptions {
    RLMRealm *realm = [self realmWithTestPath];
    
    [realm writeUsingBlock:^(RLMRealm *realm) {
        XCTAssertThrows([realm createTableNamed:nil objectClass:[RLMIntegerObject class]], @"name is nil");
        XCTAssertThrows([realm createTableNamed:@"" objectClass:[RLMIntegerObject class]], @"name is empty");
        
        XCTAssertThrows([realm createTableNamed:@"table" objectClass:[RLMRow class]], @"object class must be subclass of RLMRow");
        XCTAssertThrows([realm createTableNamed:@"table" objectClass:[NSObject class]], @"object class must be subclass of RLMRow");
        
        XCTAssertNoThrow([realm createTableNamed:@"table" objectClass:[RLMIntegerObject class]], @"normal create table throws");
        XCTAssertThrows([realm createTableNamed:@"table" objectClass:[RLMIntegerObject class]], @"name already exists");
    }];
    
    XCTAssertThrows([realm tableNamed:nil], @"name is nil");
    XCTAssertThrows([realm tableNamed:@""], @"name is empty");
    XCTAssertThrows([realm createTableNamed:@"name" objectClass:[RLMIntegerObject class]], @"creating table not allowed in read transaction");
    XCTAssertNil([realm tableNamed:@"weird name"], @"get table that does not exists return nil");
}

@end
