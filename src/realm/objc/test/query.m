//
//  query.m
//  TightDB
//

#import "RLMTestCase.h"

#import <realm/objc/Realm.h>
#import <realm/objc/RLMQueryFast.h>
#import <realm/objc/RLMTableFast.h>

#pragma mark - Realm Models

@interface TestQueryObj : RLMRow

@property (nonatomic, assign) NSInteger age;

@end

@implementation TestQueryObj
@end

RLM_TABLE(TestQueryTable2, TestQueryObj);

@interface TestQueryAllObj : RLMRow

@property (nonatomic, assign) BOOL      BoolCol;
@property (nonatomic, assign) NSInteger IntCol;
@property (nonatomic, assign) float     FloatCol;
@property (nonatomic, assign) double    DoubleCol;
@property (nonatomic, copy)   NSString *StringCol;
@property (nonatomic, strong) NSData   *BinaryCol;
@property (nonatomic, strong) NSDate   *DateCol;
//@property (nonatomic, strong) TestQueryTable2 *TableCol; // FIXME
@property (nonatomic, strong) id        MixedCol;

@end

@implementation TestQueryAllObj
@end

RLM_TABLE(TestQueryAllTable2, TestQueryAllObj);

@interface RLMMathObject : RLMRow
@property int     IntCol;
@property float   FloatCol;
@property double  DoubleCol;
@property NSDate *DateCol;
@end

@implementation RLMMathObject
@end

RLM_TABLE(RLMMathTable, RLMMathObject);

@interface RLMIntObject : RLMRow
@property int Int;
@end

@implementation RLMIntObject
@end

@interface RLMFloatObject : RLMRow
@property float Float;
@end

@implementation RLMFloatObject
@end

@interface RLMDoubleObject : RLMRow
@property double Double;
@end

@implementation RLMDoubleObject
@end

@interface RLMDateObject : RLMRow
@property NSDate *date;
@end

@implementation RLMDateObject
@end

@interface RLMStringObject : RLMRow
@property NSString *string;
@end

@implementation RLMStringObject
@end

@interface RLMDataObject : RLMRow
@property NSData *data;
@end

@implementation RLMDataObject
@end

#pragma mark - Query Tests

@interface MACtestQuery: RLMTestCase

@end

@implementation MACtestQuery

- (void)testQuery {
    
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        TestQueryAllTable2 *table = [realm createTableNamed:@"table" objectClass:[TestQueryAllObj class]];
        NSLog(@"Table: %@", table);
        XCTAssertNotNil(table, @"Table is nil");
        
        const char bin[4] = { 0, 1, 2, 3 };
        NSData *bin1 = [[NSData alloc] initWithBytes:bin length:sizeof bin / 2];
        NSData *bin2 = [[NSData alloc] initWithBytes:bin length:sizeof bin];
        
        TestQueryTable2 *subtable = [realm createTableNamed:@"subtable" objectClass:[TestQueryObj class]];
        [subtable addRow:@[@22]];
        
        NSDate *zeroDate = [NSDate dateWithTimeIntervalSince1970:0];
        [table addRow:@[@NO, @54, @(0.7f), @0.8, @"foo", bin1, zeroDate, @2]];
        [table addRow:@[@YES, @506, @(7.7f), @8.8, @"banach", bin2, [NSDate date], @"bar"]];
        
        XCTAssertEqual([[table allWhere:@"BoolCol == NO"] rowCount], (NSUInteger)1, @"BoolCol equal");
        XCTAssertEqual([[table allWhere:@"IntCol == 54"] rowCount], (NSUInteger)1, @"IntCol equal");
        NSUInteger floatCount = [[table allWhere:@"FloatCol == %@", @(0.7f)] rowCount];
        XCTAssertEqual(floatCount, (NSUInteger)1, @"FloatCol equal");
        XCTAssertEqual([[table allWhere:@"DoubleCol == 0.8"] rowCount], (NSUInteger)1, @"DoubleCol equal");
        XCTAssertEqual([[table allWhere:@"StringCol == 'foo'"] rowCount], (NSUInteger)1, @"StringCol equal");
        NSUInteger binaryCount = [[table allWhere:@"BinaryCol == %@", bin1] rowCount];
        XCTAssertEqual(binaryCount, (NSUInteger)1, @"BinaryCol equal");
        NSUInteger dateCount = [[table allWhere:@"DateCol == %@", zeroDate] rowCount];
        XCTAssertEqual(dateCount, (NSUInteger)1, @"DateCol equal");
        // These are not yet implemented
        // NSUInteger subtableCount = [[table allWhere:@"TableCol == %@", subtable] rowCount];
        // XCTAssertEqual(subtableCount, (NSUInteger)1, @"TableCol equal");
        // NSUInteger mixedCount = [[table allWhere:@"MixedCol == %@", @"bar"] rowCount];
        // XCTAssertEqual(mixedCount, (NSUInteger)1, @"MixedCol equal");
        
        NSString *predicate = @"BoolCol == NO";
        
        XCTAssertEqual([[table minOfProperty:@"IntCol" where:predicate] integerValue], (int)54, @"IntCol min");
        XCTAssertEqual([[table maxOfProperty:@"IntCol" where:predicate] integerValue], (int)54, @"IntCol max");
        XCTAssertEqual([[table sumOfProperty:@"IntCol" where:predicate] integerValue], (int)54, @"IntCol sum");
        XCTAssertEqual([[table averageOfProperty:@"IntCol" where:predicate] integerValue], (int)54, @"IntCol avg");
        
        XCTAssertEqual([[table minOfProperty:@"FloatCol" where:predicate] floatValue], (float)0.7f, @"FloatCol min");
        XCTAssertEqual([[table maxOfProperty:@"FloatCol" where:predicate] floatValue], (float)0.7f, @"FloatCol max");
        XCTAssertEqual([[table sumOfProperty:@"FloatCol" where:predicate] floatValue], (float)0.7f, @"FloatCol sum");
        XCTAssertEqual([[table averageOfProperty:@"FloatCol" where:predicate] floatValue], (float)0.7f, @"FloatCol avg");
        
        XCTAssertEqual([[table minOfProperty:@"DoubleCol" where:predicate] doubleValue], (double)0.8, @"DoubleCol min");
        XCTAssertEqual([[table maxOfProperty:@"DoubleCol" where:predicate] doubleValue], (double)0.8, @"DoubleCol max");
        XCTAssertEqual([[table sumOfProperty:@"DoubleCol" where:predicate] doubleValue], (double)0.8, @"DoubleCol sum");
        XCTAssertEqual([[table averageOfProperty:@"DoubleCol" where:predicate] doubleValue], (double)0.8, @"DoubleCol avg");
    }];

}

- (void)testMathOperations {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMMathObject class]];
        
        //======== Zero rows added ========//
        
        // Min
        XCTAssertEqual([[table minOfProperty:@"IntCol" where:nil] integerValue], NSIntegerMax);
        XCTAssertEqual([[table minOfProperty:@"FloatCol" where:nil] floatValue], (float)INFINITY);
        XCTAssertEqual([[table minOfProperty:@"DoubleCol" where:nil] doubleValue], (double)INFINITY);
        // FIXME: Support min/max on dates
        // XCTAssertNil([table minOfProperty:@"DateCol" where:nil]);
        
        // Max
        XCTAssertEqual([[table maxOfProperty:@"IntCol" where:nil] integerValue], NSIntegerMin);
        XCTAssertEqual([[table maxOfProperty:@"FloatCol" where:nil] floatValue], (float)-INFINITY);
        XCTAssertEqual([[table maxOfProperty:@"DoubleCol" where:nil] doubleValue], (double)-INFINITY);
        // FIXME: Support min/max on dates
        // XCTAssertNil([table maxOfProperty:@"DateCol" where:nil]);
        
        // Sum
        XCTAssertEqual([[table sumOfProperty:@"IntCol" where:nil] integerValue], (NSInteger)0);
        XCTAssertEqual([[table sumOfProperty:@"FloatCol" where:nil] floatValue], (float)0);
        XCTAssertEqual([[table sumOfProperty:@"DoubleCol" where:nil] doubleValue], (double)0);
        
        // Average
        XCTAssertEqual([[table averageOfProperty:@"IntCol" where:nil] integerValue], (NSInteger)0);
        XCTAssertEqual([[table averageOfProperty:@"FloatCol" where:nil] floatValue], (float)0);
        XCTAssertEqual([[table averageOfProperty:@"DoubleCol" where:nil] doubleValue], (double)0);
        
        //======== Add rows with values ========//
        
        NSDate *date3 = [NSDate date];
        NSDate *date33 = [date3 dateByAddingTimeInterval:1];
        NSDate *date333 = [date33 dateByAddingTimeInterval:1];
        
        [table addRow:@[@3, @3.3f, @3.3, date3]];
        [table addRow:@[@33, @33.33f, @33.33, date33]];
        [table addRow:@[@333, @333.333f, @333.333, date333]];
        
        // Min
        XCTAssertEqual([[table minOfProperty:@"IntCol" where:nil] integerValue], (NSInteger)3);
        XCTAssertEqualWithAccuracy([[table minOfProperty:@"FloatCol" where:nil] floatValue], (float)3.3, 0.1);
        XCTAssertEqualWithAccuracy([[table minOfProperty:@"DoubleCol" where:nil] doubleValue], (double)3.3, 0.1);
        // FIXME: Support min/max on dates
        // XCTAssertEqualWithAccuracy([(NSDate *)[table minOfProperty:@"DateCol" where:nil] timeIntervalSince1970], date3.timeIntervalSince1970, 0.999);
        
        // Max
        XCTAssertEqual([[table maxOfProperty:@"IntCol" where:nil] integerValue], (NSInteger)333);
        XCTAssertEqualWithAccuracy([[table maxOfProperty:@"FloatCol" where:nil] floatValue], (float)333.333, 0.1);
        XCTAssertEqualWithAccuracy([[table maxOfProperty:@"DoubleCol" where:nil] doubleValue], (double)333.333, 0.1);
        // FIXME: Support min/max on dates
        // XCTAssertEqualWithAccuracy([(NSDate *)[table maxOfProperty:@"DateCol" where:nil] timeIntervalSince1970], date333.timeIntervalSince1970, 0.999);
        
        // Sum
        XCTAssertEqual([[table sumOfProperty:@"IntCol" where:nil] integerValue], (NSInteger)369);
        XCTAssertEqualWithAccuracy([[table sumOfProperty:@"FloatCol" where:nil] floatValue], (float)369.963, 0.1);
        XCTAssertEqualWithAccuracy([[table sumOfProperty:@"DoubleCol" where:nil] doubleValue], (double)369.963, 0.1);
        
        // Average
        XCTAssertEqual([[table averageOfProperty:@"IntCol" where:nil] doubleValue], (double)123);
        XCTAssertEqualWithAccuracy([[table averageOfProperty:@"FloatCol" where:nil] doubleValue], (double)123.321, 0.1);
        XCTAssertEqualWithAccuracy([[table averageOfProperty:@"DoubleCol" where:nil] doubleValue], (double)123.321, 0.1);
    }];
}

- (void)testFind {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMMathTable *table = [realm createTableNamed:@"table" objectClass:[RLMMathObject class]];
        
        // Add 6 empty rows
        for (NSUInteger index = 0; index < 6; index++) {
            [table addRow:nil];
        }
        table[0].IntCol = 10;
        table[1].IntCol = 42;
        table[2].IntCol = 27;
        table[3].IntCol = 31;
        table[4].IntCol = 8;
        table[5].IntCol = 39;
        
        XCTAssertEqualObjects([table firstWhere:@"IntCol > 10"][@"IntCol"], @42, @"Row 1 is greater than 10");
        XCTAssertNil([table firstWhere:@"IntCol > 100"], @"No rows are greater than 100");
        RLMView *view = [table allWhere:@"IntCol between %@", @[@20, @40]];
        XCTAssertEqualObjects(view.firstRow[@"IntCol"], @27, @"The first row in the table with IntCol between 20 and 40 is 27");
        
        [table removeAllRows];
        XCTAssertNil([table firstWhere:nil]);
    }];
}

//- (void)testSubtableQuery {
//    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
//        RLMDescriptor *d = table.descriptor;
//        RLMDescriptor *subDesc = [d addColumnTable:@"subtable"];
//        [subDesc addColumnWithName:@"subCol" type:RLMTypeBool];
//        [table addRow:nil];
//        XCTAssertEqual(table.rowCount, (NSUInteger)1,@"one row added");
//        
//        RLMTable * subTable = [table RLM_tableInColumnWithIndex:0 atRowIndex:0];
//        [subTable addRow:nil];
//        [subTable RLM_setBool:YES inColumnWithIndex:0 atRowIndex:0];
//        RLMQuery *q = [table where];
//        
//        RLMView *v = [[[[q subtableInColumnWithIndex:0] boolIsEqualTo:YES inColumnWithIndex:0] parent] findAllRows];
//        XCTAssertEqual(v.rowCount, (NSUInteger)1,@"one match");
//    }];
//}

#pragma mark - Predicates

- (void)testIntegerPredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMIntObject class]];
        NSArray *ints = @[@0, @1, @2, @3];
        for (NSNumber *intNum in ints) {
            [table addRow:@[intNum]];
        }
        
        NSNumber *intNum = ints[1];
        
        // Lesser than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int < %@", intNum]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(0, 1)]
                       name:@"lesser than"
                     column:@"Int"];

        // Lesser than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int <= %@", intNum]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(0, 2)]
                       name:@"lesser than or equal"
                     column:@"Int"];
        
        // Equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int == %@", intNum]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(1, 1)]
                       name:@"equal"
                     column:@"Int"];

        // Greater than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int >= %@", intNum]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"greater than or equal"
                     column:@"Int"];

        // Greater than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int > %@", intNum]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"greater than"
                     column:@"Int"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int != %@", intNum]
                    onTable:table
                withResults:@[ints[0], ints[2], ints[3]]
                       name:@"not equal"
                     column:@"Int"];
        
        // Between
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int between %@", @[intNum, ints.lastObject]]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"between"
                     column:@"Int"];
        
        // Between (inverse)
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int between %@", @[ints.lastObject, intNum]]
                    onTable:table
                withResults:@[]
                       name:@"between (inverse)"
                     column:@"Int"];
        
        // AND
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int >= %@ && Int <= %@", intNum, ints.lastObject]
                    onTable:table
                withResults:[ints subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"AND"
                     column:@"Int"];
        
        // OR
        [self testPredicate:[NSPredicate predicateWithFormat:@"Int <= %@ || Int >= %@", ints.firstObject, ints.lastObject]
                    onTable:table
                withResults:@[ints.firstObject, ints.lastObject]
                       name:@"OR"
                     column:@"Int"];
    }];
}

- (void)testFloatPredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMFloatObject class]];
        NSArray *floats = @[@0, @1, @2, @3];
        for (NSNumber *floatNum in floats) {
            [table addRow:@[floatNum]];
        }
        
        NSNumber *floatNum = floats[1];
        
        // Lesser than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float < %@", floatNum]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(0, 1)]
                       name:@"lesser than"
                     column:@"Float"];
        
        // Lesser than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float <= %@", floatNum]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(0, 2)]
                       name:@"lesser than or equal"
                     column:@"Float"];
        
        // Equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float == %@", floatNum]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(1, 1)]
                       name:@"equal"
                     column:@"Float"];
        
        // Greater than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float >= %@", floatNum]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"greater than or equal"
                     column:@"Float"];
        
        // Greater than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float > %@", floatNum]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"greater than"
                     column:@"Float"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float != %@", floatNum]
                    onTable:table
                withResults:@[floats[0], floats[2], floats[3]]
                       name:@"not equal"
                     column:@"Float"];
        
        // Between
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float between %@", @[floatNum, floats.lastObject]]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"between"
                     column:@"Float"];
        
        // Between (inverse)
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float between %@", @[floats.lastObject, floatNum]]
                    onTable:table
                withResults:@[]
                       name:@"between (inverse)"
                     column:@"Float"];
        
        // AND
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float >= %@ && Float <= %@", floatNum, floats.lastObject]
                    onTable:table
                withResults:[floats subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"AND"
                     column:@"Float"];
        
        // OR
        [self testPredicate:[NSPredicate predicateWithFormat:@"Float <= %@ || Float >= %@", floats.firstObject, floats.lastObject]
                    onTable:table
                withResults:@[floats.firstObject, floats.lastObject]
                       name:@"OR"
                     column:@"Float"];
    }];
}

- (void)testDoublePredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMDoubleObject class]];
        NSArray *doubles = @[@0, @1, @2, @3];
        for (NSNumber *doubleNum in doubles) {
            [table addRow:@[doubleNum]];
        }
        
        NSNumber *doubleNum = doubles[1];
        
        // Lesser than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double < %@", doubleNum]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(0, 1)]
                       name:@"lesser than"
                     column:@"Double"];
        
        // Lesser than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double <= %@", doubleNum]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(0, 2)]
                       name:@"lesser than or equal"
                     column:@"Double"];
        
        // Equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double == %@", doubleNum]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(1, 1)]
                       name:@"equal"
                     column:@"Double"];
        
        // Greater than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double >= %@", doubleNum]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"greater than or equal"
                     column:@"Double"];
        
        // Greater than
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double > %@", doubleNum]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"greater than"
                     column:@"Double"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double != %@", doubleNum]
                    onTable:table
                withResults:@[doubles[0], doubles[2], doubles[3]]
                       name:@"not equal"
                     column:@"Double"];
        
        // Between
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double between %@", @[doubleNum, doubles.lastObject]]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"between"
                     column:@"Double"];
        
        // Between (inverse)
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double between %@", @[doubles.lastObject, doubleNum]]
                    onTable:table
                withResults:@[]
                       name:@"between (inverse)"
                     column:@"Double"];
        
        // AND
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double >= %@ && Double <= %@", doubleNum, doubles.lastObject]
                    onTable:table
                withResults:[doubles subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"AND"
                     column:@"Double"];
        
        // OR
        [self testPredicate:[NSPredicate predicateWithFormat:@"Double <= %@ || Double >= %@", doubles.firstObject, doubles.lastObject]
                    onTable:table
                withResults:@[doubles.firstObject, doubles.lastObject]
                       name:@"OR"
                     column:@"Double"];
    }];
}

- (void)testDatePredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMDateObject class]];
        NSArray *dates = @[[NSDate dateWithTimeIntervalSince1970:0],
                           [NSDate dateWithTimeIntervalSince1970:1],
                           [NSDate dateWithTimeIntervalSince1970:2],
                           [NSDate dateWithTimeIntervalSince1970:3]];
        for (NSDate *date in dates) {
            [table addRow:@[date]];
        }
        
        NSDate *date = dates[1];
        
        // Lesser than
        [self testPredicate:[NSPredicate predicateWithFormat:@"date < %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(0, 1)]
                       name:@"lesser than"
                     column:@"date"];
        
        // Lesser than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"date <= %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(0, 2)]
                       name:@"lesser than or equal"
                     column:@"date"];
        
        // Equal (single '=')
        [self testPredicate:[NSPredicate predicateWithFormat:@"date = %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(1, 1)]
                       name:@"equal(1)"
                     column:@"date"];
        
        // Equal (double '=')
        [self testPredicate:[NSPredicate predicateWithFormat:@"date == %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(1, 1)]
                       name:@"equal(2)"
                     column:@"date"];
        
        // Greater than or equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"date >= %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"greater than or equal"
                     column:@"date"];
        
        // Greater than
        [self testPredicate:[NSPredicate predicateWithFormat:@"date > %@", date]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"greater than"
                     column:@"date"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"date != %@", date]
                    onTable:table
                withResults:@[dates[0], dates[2], dates[3]]
                       name:@"not equal"
                     column:@"date"];
        
        // Between
        [self testPredicate:[NSPredicate predicateWithFormat:@"date between %@", @[date, dates.lastObject]]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"between"
                     column:@"date"];
        
        // Between (inverse)
        [self testPredicate:[NSPredicate predicateWithFormat:@"date between %@", @[dates.lastObject, date]]
                    onTable:table
                withResults:@[]
                       name:@"between (inverse)"
                     column:@"date"];
        
        // AND
        [self testPredicate:[NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", date, dates.lastObject]
                    onTable:table
                withResults:[dates subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"AND"
                     column:@"date"];
        
        // OR
        [self testPredicate:[NSPredicate predicateWithFormat:@"date <= %@ || date >= %@", dates.firstObject, dates.lastObject]
                    onTable:table
                withResults:@[dates.firstObject, dates.lastObject]
                       name:@"OR"
                     column:@"date"];
    }];
}

- (void)testStringPredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMStringObject class]];
        NSArray *strings = @[@"a",
                             @"ab",
                             @"abc",
                             @"abcd"];
        for (NSString *string in strings) {
            [table addRow:@[string]];
        }
        
        // Equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"string == %@", @"a"]
                    onTable:table
                withResults:[strings subarrayWithRange:NSMakeRange(0, 1)]
                       name:@"equal"
                     column:@"string"];
        
        // Equal (fail)
        [self testPredicate:[NSPredicate predicateWithFormat:@"string == %@", @"A"]
                    onTable:table
                withResults:@[]
                       name:@"equal (fail)"
                     column:@"string"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"string != %@", @"a"]
                    onTable:table
                withResults:[strings subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"not equal"
                     column:@"string"];
        
        // Begins with
        [self testPredicate:[NSPredicate predicateWithFormat:@"string beginswith %@", @"ab"]
                    onTable:table
                withResults:[strings subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"beginswith"
                     column:@"string"];
        
        // Begins with (fail)
        [self testPredicate:[NSPredicate predicateWithFormat:@"string beginswith %@", @"A"]
                    onTable:table
                withResults:@[]
                       name:@"beginswith (fail)"
                     column:@"string"];
        
        // Contains
        [self testPredicate:[NSPredicate predicateWithFormat:@"string contains %@", @"bc"]
                    onTable:table
                withResults:[strings subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"contains"
                     column:@"string"];
        
        // Ends with
        [self testPredicate:[NSPredicate predicateWithFormat:@"string endswith %@", @"cd"]
                    onTable:table
                withResults:@[strings.lastObject]
                       name:@"endswith"
                     column:@"string"];
        
        // NSCaseInsensitivePredicateOption
        [self testPredicate:[NSPredicate predicateWithFormat:@"string contains[c] %@", @"C"]
                    onTable:table
                withResults:[strings subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"NSCaseInsensitivePredicateOption"
                     column:@"string"];
        
        // NSDiacriticInsensitivePredicateOption
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"string contains[d] %@", @"ç"];
            XCTAssertThrows([table allWhere:predicate],
                            @"String predicate with diacritic insensitive option should throw");
        }
        
        // AND
        [self testPredicate:@"string contains 'c' && string contains 'd'"
                    onTable:table
                withResults:@[@"abcd"]
                       name:@"AND"
                     column:@"string"];
        
        // OR
        [self testPredicate:@"string contains 'c' || string contains 'd'"
                    onTable:table
                withResults:@[@"abc", @"abcd"]
                       name:@"OR"
                     column:@"string"];
        
        // Complex
        [self testPredicate:@"(string contains 'b' || string contains 'c') && string endswith[c] 'D'"
                    onTable:table
                withResults:@[@"abcd"]
                       name:@"complex"
                     column:@"string"];
    }];
}

- (void)testBinaryPredicates {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMDataObject class]];
        NSArray *dataArray = @[[@"a" dataUsingEncoding:NSUTF8StringEncoding],
                               [@"ab" dataUsingEncoding:NSUTF8StringEncoding],
                               [@"abc" dataUsingEncoding:NSUTF8StringEncoding],
                               [@"abcd" dataUsingEncoding:NSUTF8StringEncoding]];
        for (NSData *data in dataArray) {
            [table addRow:@[data]];
        }
        
        // Equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"data == %@", dataArray.lastObject]
                    onTable:table
                withResults:@[dataArray.lastObject]
                       name:@"equal"
                     column:@"data"];
        
        // Not equal
        [self testPredicate:[NSPredicate predicateWithFormat:@"data != %@", dataArray.firstObject]
                    onTable:table
                withResults:[dataArray subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"not equal"
                     column:@"data"];
        
        // Begins with
        [self testPredicate:[NSPredicate predicateWithFormat:@"data beginswith %@", dataArray[1]]
                    onTable:table
                withResults:[dataArray subarrayWithRange:NSMakeRange(1, 3)]
                       name:@"beginswith"
                     column:@"data"];
        
        // Contains
        [self testPredicate:[NSPredicate predicateWithFormat:@"data contains %@",
                             [@"bc" dataUsingEncoding:NSUTF8StringEncoding]]
                    onTable:table
                withResults:[dataArray subarrayWithRange:NSMakeRange(2, 2)]
                       name:@"contains"
                     column:@"data"];
        
        // Ends with
        [self testPredicate:[NSPredicate predicateWithFormat:@"data endswith %@",
                             [@"cd" dataUsingEncoding:NSUTF8StringEncoding]]
                    onTable:table
                withResults:@[dataArray.lastObject]
                       name:@"endswith"
                     column:@"data"];
    }];
}

#pragma mark - Variadic

- (void)testVariadicPredicateFormat {
    [self.realmWithTestPath writeUsingBlock:^(RLMRealm *realm) {
        RLMTable *table = [realm createTableNamed:@"table" objectClass:[RLMIntObject class]];
        NSArray *ints = @[@0, @1, @2, @3];
        for (NSNumber *intNum in ints) {
            [table addRow:@[intNum]];
        }
        
        // Variadic firstWhere
        RLMRow *row = [table firstWhere:@"Int <= %@", @1];
        XCTAssertEqualObjects(@0,
                              row[@"Int"],
                              @"Variadic firstWhere predicate should return correct result");
        
        // Variadic allWhere
        RLMView *view = [table allWhere:@"Int <= %@", @1];
        NSArray *results = @[@0, @1];
        XCTAssertEqual(view.rowCount,
                       results.count,
                       @"Variadic allWhere predicate should return correct count");
        for (NSUInteger i = 0; i < results.count; i++) {
            XCTAssertEqualObjects(results[i],
                                  view[i][@"Int"],
                                  @"Variadic allWhere predicate should return correct results");
        }
    }];
}

#pragma mark - Predicate Helpers

- (void)testPredicate:(id)predicate
              onTable:(RLMTable *)table
          withResults:(NSArray *)results
                 name:(NSString *)name
               column:(NSString *)column {
    RLMView *view = [table allWhere:predicate];
    XCTAssertEqual(view.rowCount,
                   results.count,
                   @"%@ predicate should return correct count", name);
    for (NSUInteger i = 0; i < results.count; i++) {
        XCTAssertEqualObjects(results[i],
                              view[i][column],
                              @"%@ predicate should return correct results", name);
    }
}

@end
