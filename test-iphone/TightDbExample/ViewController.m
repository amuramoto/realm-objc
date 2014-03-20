//
//  ViewController.m
//  TightDbExample
//

#import <Tightdb/Tightdb.h>

#import "ViewController.h"
#import "Utils.h"
#import "Performance.h"

TIGHTDB_TABLE_4(MyTable,
                Name,  String,
                Age,   Int,
                Hired, Bool,
                Spare, Int)

TIGHTDB_TABLE_2(MyTable2,
                Hired, Bool,
                Age,   Int)


@interface ViewController ()
@end
@implementation ViewController
{
    Utils *_utils;
}

#pragma mark - View code
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.view = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _utils = [[Utils alloc] initWithView:(UIScrollView *)self.view];
    [self testGroup];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Performance *perf = [[Performance alloc] initWithUtils:_utils];
        [perf testInsert];
        [perf testFetch];
        [perf testFetchSparse];
        [perf testFetchAndIterate];
        [perf testUnqualifiedFetchAndIterate];
        [perf testWriteToDisk];
        [perf testReadTransaction];
        [perf testWriteTransaction];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Example code


- (void)testGroup
{
    TDBGroup *group = [TDBGroup group];
    // Create new table in group
    MyTable *table = [group getOrCreateTableWithName:@"employees" asTableClass:[MyTable class]];

    // Add some rows
    [table addName:@"John" Age:20 Hired:YES Spare:0];
    [table addName:@"Mary" Age:21 Hired:NO Spare:0];
    [table addName:@"Lars" Age:21 Hired:YES Spare:0];
    [table addName:@"Phil" Age:43 Hired:NO Spare:0];
    [table addName:@"Anni" Age:54 Hired:YES Spare:0];

    NSLog(@"MyTable Size: %i", [table rowCount]);

    //------------------------------------------------------

    size_t row;
    row = [table.Name find:@"Philip"];              // row = (size_t)-1
    NSLog(@"Philip: %zu", row);
    [_utils Eval:row==-1 msg:@"Philip should not be there"];
    row = [table.Name find:@"Mary"];
    NSLog(@"Mary: %zu", row);
    [_utils Eval:row==1 msg:@"Mary should have been there"];

    MyTable_View *view = [[[table where].Age columnIsEqualTo:21] findAll];
    size_t cnt = [view rowCount];                      // cnt = 2
    [_utils Eval:cnt == 2 msg:@"Should be two rows in view"];

    //------------------------------------------------------

    MyTable2 *table2 = [[MyTable2 alloc] init];

    // Add some rows
    [table2 addHired:YES Age:20];
    [table2 addHired:NO Age:21];
    [table2 addHired:YES Age:22];
    [table2 addHired:NO Age:43];
    [table2 addHired:YES Age:54];

    // Create query (current employees between 20 and 30 years old)
    MyTable2_Query *q = [[[table2 where].Hired columnIsEqualTo:YES]
                                        .Age   columnIsBetween:20 and_:30];

    // Get number of matching entries
    NSLog(@"Query count: %i", [q countRows]);
    [_utils Eval:[q countRows] == 2 msg:@"Expected 2 rows in query"];


    // Get the average age - currently only a low-level interface!
    double avg = [q.Age avg];
    NSLog(@"Average: %f", avg);
    [_utils Eval: avg== 21.0 msg:@"Expected 20.5 average"];

    // Execute the query and return a table (view)
    TDBView *res = [q findAll];
    for (size_t i = 0; i < [res rowCount]; i++) {
        // cursor missing. Only low-level interface!
        NSLog(@"%zu: is %lld years old",i , [res intInColumnWithIndex:i atRowIndex:i]);
    }

    //------------------------------------------------------

    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[_utils pathForDataFile:@"employees.tightdb"] error:nil];

    // Write to disk
    [group writeToFile:[_utils pathForDataFile:@"employees.tightdb"] withError:nil];

    // Load a group from disk (and print contents)
    TDBGroup *fromDisk = [TDBGroup groupWithFile:[_utils pathForDataFile:@"employees.tightdb"] withError:nil];
    MyTable *diskTable = [fromDisk getOrCreateTableWithName:@"employees" asTableClass:[MyTable class]];

    [diskTable addName:@"Anni" Age:54 Hired:YES Spare:0];
    [diskTable insertEmptyRowAtIndex:2 Name:@"Thomas" Age:41 Hired:NO Spare:1];
    NSLog(@"Disktable size: %i", [diskTable rowCount]);
    for (size_t i = 0; i < [diskTable rowCount]; i++) {
        MyTable_Row *row = [diskTable rowAtIndex:i];
        NSLog(@"%zu: %@", i, [row Name]);
        NSLog(@"%zu: %@", i, row.Name);
        NSLog(@"%zu: %@", i, [diskTable stringInColumnWithIndex:0 atRowIndex:i]);
    }

    // Write same group to memory buffer
    TDBBinary* buffer = [group writeToBuffer];

    // Load a group from memory (and print contents)
    TDBGroup *fromMem = [TDBGroup groupWithBuffer:buffer withError:nil];
    MyTable *memTable = [fromMem getOrCreateTableWithName:@"employees" asTableClass:[MyTable class]];

    for (MyTable_Row *row in memTable)
    {
        NSLog(@"From mem: %@ is %lld years old.", row.Name, row.Age);
    }

    // 1: Iterate over table
    for (MyTable_Row *row in diskTable)
    {
        [_utils Eval:YES msg:@"Enumerator running"];
        NSLog(@"From disk: %@ is %lld years old.", row.Name, row.Age);
    }

    // Do a query, and get all matches as TableView
    MyTable_View *v = [[[[diskTable where].Hired columnIsEqualTo:YES].Age columnIsBetween:20 and_:30] findAll];
    NSLog(@"View count: %i", [v rowCount]);
    // 2: Iterate over the resulting TableView
    for (MyTable_Row *row in v) {
        NSLog(@"%@ is %lld years old.", row.Name, row.Age);
    }

    // 3: Iterate over query (lazy)

    MyTable_Query *qe = [[diskTable where].Age columnIsEqualTo:21];
    NSLog(@"Query lazy count: %i", [qe countRows]);
    for (MyTable_Row *row in qe) {
        NSLog(@"%@ is %lld years old.", row.Name, row.Age);
    }

}


@end



