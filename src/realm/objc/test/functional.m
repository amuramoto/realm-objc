//  functional.m
//  TightDB
//
//  This test is aimed at verifying functionallity added by the binding.


#import "RLMTestCase.h"
#import <realm/objc/RLMFast.h>
#import <realm/objc/RLMTable.h>
#import <realm/objc/RLMTableFast.h>

@interface RLMPerson : RLMRow
@property NSString *name;
@property NSInteger age;
@property BOOL      hired;
@end

@implementation RLMPerson
@end

RLM_TABLE(RLMPersonTable, RLMPerson);

#define TABLE_SIZE 1000 // must be even number
#define INSERT_ROW 5

@interface MACtestFunctional : RLMTestCase
@end

@implementation MACtestFunctional

- (void)testCreateTable {
    RLMRealm *realm = [self realmWithTestPath];
    [realm writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMPerson class]];
        [table addRow:@{@"name": @"Sue", @"age": @23, @"hired": @YES}];
    }];
    
    RLMPersonTable *table = (RLMPersonTable *)[realm tableNamed:@"table"];
    XCTAssertTrue(table, @"Realm should have a table");
    XCTAssertTrue([table isKindOfClass:[RLMPersonTable class]], @"table should be of class RLMPersonTable");
    
    RLMPerson *sue = table[0];
    XCTAssertEqualObjects(sue.name, @"Sue", @"first row's name should be Sue");
    XCTAssertTrue([sue isKindOfClass:[RLMPerson class]], @"first row should be of class RLMPerson");
}

- (void)testTypedRow {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        // Row in a table.
        
        RLMPersonTable *table = (RLMPersonTable *)[realm createTableNamed:@"table" objectClass:[RLMPerson class]];
        
        // Add rows
        for (NSUInteger index = 0; index < TABLE_SIZE; index++) {
            [table addRow:nil];
            RLMPerson *person = [table lastRow];
            person.name = [@"Person_" stringByAppendingString:@(index).stringValue];
            person.age = index;
            person.hired = index % 2;
        }
        
        // Check values
        NSUInteger i = 0;
        for (RLMPerson *person in table) {
            NSString *expected = [@"Person_" stringByAppendingString:@(i).stringValue];
            XCTAssertTrue([person.name isEqualToString:expected], @"Check name");
            XCTAssertTrue([@(person.age) isEqual:@(i)], @"Check age");
            XCTAssertTrue([@(person.hired) isEqual:@(i % 2)], @"Check hired");
            i++;
        }
        
        // Insert a row
        [table insertRow:nil atIndex:INSERT_ROW];
        RLMPerson *person = [table rowAtIndex:INSERT_ROW];
        person.name = @"Person_Inserted";
        person.age = 99;
        person.hired = YES;
        
        // Check inserted row
        person = [table rowAtIndex:INSERT_ROW];
        XCTAssertTrue([person.name isEqualToString:@"Person_Inserted"], @"Check name");
        XCTAssertTrue([@(person.age) isEqual:@99], @"Check age");
        XCTAssertTrue([@(person.hired) isEqual:@YES], @"Check hired");
        
        // Check row before
        person = [table rowAtIndex:INSERT_ROW - 1];
        NSString *expected = [@"Person_" stringByAppendingString:@(INSERT_ROW - 1).stringValue];
        XCTAssertTrue([person.name isEqualToString:expected], @"Check name");
        XCTAssertTrue([@(person.age) isEqual:@(INSERT_ROW - 1)], @"Check age");
        XCTAssertTrue([@(person.hired) isEqual:@((INSERT_ROW - 1) % 2)], @"Check hired");
        
        // Check row after (should be equal to the previous row at index INSERT_ROW).
        person = [table rowAtIndex:INSERT_ROW + 1];
        expected = [@"Person_" stringByAppendingString:@(INSERT_ROW).stringValue];
        XCTAssertTrue([person.name isEqualToString:expected], @"Check name");
        XCTAssertTrue([@(person.age) isEqual:@(INSERT_ROW)], @"Check age");
        XCTAssertTrue([@(person.hired) isEqual:@(INSERT_ROW % 2)], @"Check hired");
        
        // Check last row
        person = [table lastRow];
        expected = [@"Person_" stringByAppendingString:@(TABLE_SIZE - 1).stringValue];
        XCTAssertTrue([person.name isEqualToString:expected], @"Check name");
        XCTAssertTrue([@(person.age) isEqual:@(TABLE_SIZE - 1)], @"Check age");
        XCTAssertTrue([@(person.hired) isEqual:@((TABLE_SIZE - 1) % 2)], @"Check hired");
        
        // Remove the inserted. The query test check that the row was
        // removed correctly (that we're back to the original table).
        [table removeRowAtIndex:INSERT_ROW];
        [table removeLastRow];
        [table removeLastRow];
        XCTAssertEqualObjects(@(table.rowCount), @(TABLE_SIZE - 2), @"Check the size");
        
        // TODO: InsertRowAtIndex.. out-of-bounds check (depends on error handling strategy)
        // TODO: RowAtIndex.. out-of-bounds check (depends onerror handling strategy
        
        // Row in a query.
        
        RLMView *view = [table allWhere:nil];
        XCTAssertEqual(view.rowCount, (NSUInteger)(TABLE_SIZE-2), @"Check the size");
        
        i = 0;
        for (person in view) {
            expected = [@"Person_" stringByAppendingString:@(i).stringValue];
            XCTAssertTrue([person.name isEqualToString:expected], @"Check name");
            XCTAssertTrue([@(person.age) isEqual:@(i)], @"Check age");
            XCTAssertTrue([@(person.hired) isEqual:@(i % 2)], @"Check hired");
            i++;
        }
        
        view = [table allWhere:@"hired == YES"];
        
        // Modify a row in the view
        
        person = (RLMPerson *)view.lastRow;
        person.name = @"Modified by view";
        
        // Check the effect on the table
        
        person = table.lastRow;
        XCTAssertTrue([person.name isEqualToString:@"Modified by view"], @"Check mod by view");
        
        // Now delete that row
        
        [view removeRowAtIndex:view.rowCount - 1];  // last row in view (hired = all YES)
        
        // And check it's gone.
        
        XCTAssertEqualObjects(@(table.rowCount), @(TABLE_SIZE-3), @"Check the size");
    }];
}

- (void)testRowDescription {
    [[self realmWithTestPath] writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"people" objectClass:[RLMPerson class]];
        [table addRow:@[@"John", @25, @YES]];
        NSString *rowDescription = [table.firstRow description];
        XCTAssertTrue([rowDescription rangeOfString:@"name"].location != NSNotFound, @"column names should be displayed when calling \"description\" on RLMRow");
        XCTAssertTrue([rowDescription rangeOfString:@"John"].location != NSNotFound, @"column values should be displayed when calling \"description\" on RLMRow");
        
        XCTAssertTrue([rowDescription rangeOfString:@"age"].location != NSNotFound, @"column names should be displayed when calling \"description\" on RLMRow");
        XCTAssertTrue([rowDescription rangeOfString:@"25"].location != NSNotFound, @"column values should be displayed when calling \"description\" on RLMRow");
    }];
}

@end
