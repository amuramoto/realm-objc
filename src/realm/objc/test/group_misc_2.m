//
//  group_misc_2.m
//  TightDB
//
// Demo code for short tutorial using Objective-C interface
//

#import "RLMTestCase.h"

#import <realm/objc/Realm.h>
#import <realm/objc/RLMRealm.h>
#import <realm/objc/RLMPrivate.h>

@interface MyObject : RLMRow

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL hired;
@property (nonatomic, assign) NSInteger spare;

@end

@implementation MyObject
@end

RLM_TABLE(MyTable, MyObject);

@interface MyObject2 : RLMRow

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL hired;

@end

@implementation MyObject2
@end

RLM_TABLE(MyTable2, MyObject2);

@interface MACTestRealmMisc2 : RLMTestCase

@end

@implementation MACTestRealmMisc2

- (void)testRealm_Misc2 {
    [[self realmWithTestPath] writeUsingBlock:^(RLMRealm *realm) {
        MyTable *table = (MyTable *)[realm createTableNamed:@"table" objectClass:[MyObject class]];
        
        // Add some rows
        [table addRow:@[@"John", @20, @YES, @0]];
        [table addRow:@[@"Mary", @21, @NO, @0]];
        [table addRow:@[@"Lars", @21, @YES, @0]];
        [table addRow:@[@"Phil", @43, @NO, @0]];
        [table addRow:@[@"Anni", @54, @YES, @0]];
        
        //------------------------------------------------------
        
        XCTAssertNil([table firstWhere:@"name == 'Philip'"], @"Philip should not be there");
        XCTAssertNotNil([table firstWhere:@"name == 'Mary'"], @"Mary should be there");
        XCTAssertEqual([table countWhere:@"age == 21"], (NSUInteger)2, @"Should be two rows in view");
    
        //------------------------------------------------------

        MyTable2* table2 = (MyTable2 *)[realm createTableNamed:@"table2" objectClass:[MyObject2 class]];
        
        // Add some rows
        [table2 addRow:@[@20, @YES]];
        [table2 addRow:@[@21, @NO]];
        [table2 addRow:@[@22, @YES]];
        [table2 addRow:@[@43, @NO]];
        [table2 addRow:@[@54, @YES]];

        // Create view (current employees between 20 and 30 years old)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hired == YES && age between %@", @[@20, @30]];
        RLMView *g = [table2 allWhere:predicate];
        
        // Get number of matching entries
        XCTAssertEqual(g.rowCount, (NSUInteger)2, @"Expected 2 rows in query");
        
        // Get the average age
        XCTAssertEqual([[table2 averageOfProperty:@"age" where:predicate] doubleValue], (double)21.0,@"Expected 21 average");
        
        // Iterate over view
        for (NSUInteger i = 0; i < [g rowCount]; i++) {
            NSLog(@"%zu: is %@ years old", i, g[i][@"age"]);
        }

        //------------------------------------------------------
        
        // Load a realm from disk (and print contents)
        RLMRealm * fromDisk = [self realmWithTestPath];
        MyTable* diskTable = (MyTable *)[fromDisk tableNamed:@"table"];
        
        for (NSUInteger i = 0; i < diskTable.rowCount; i++) {
            MyObject *object = diskTable[i];
            NSLog(@"%zu: %@", i, object.name);
            NSLog(@"%zu: %ld", i, (long)object.age);
        }
    }];
}

@end
