//
//  RLMTestCase.m
//  Realm
//
//  Created by JP Simard on 4/22/14.
//  Copyright (c) 2014 Realm. All rights reserved.
//

#import "RLMTestCase.h"

NSString *const RLMTestRealmPath = @"test.realm";
NSString *const RLMTestRealmPathLock = @"test.realm.lock";

@implementation RLMTestCase

- (void)setUp {
    // This method is run before every test method
    [super setUp];
    [[NSFileManager defaultManager] removeItemAtPath:[RLMTestCase pathInAppDocumentsFolderForFileWithName:RLMTestRealmPath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[RLMTestCase pathInAppDocumentsFolderForFileWithName:RLMTestRealmPathLock] error:nil];
}

+ (void)tearDown {
    // This method is run after all tests in a test method have run
    [[NSFileManager defaultManager] removeItemAtPath:[RLMTestCase pathInAppDocumentsFolderForFileWithName:RLMTestRealmPath] error:nil];
    [super tearDown];
}

- (RLMRealm *)realmWithTestPath {
    return [RLMRealm realmWithPath:[RLMTestCase pathInAppDocumentsFolderForFileWithName:RLMTestRealmPath] error:nil];
}

- (void)createTestTableWithWriteBlock:(void(^)(RLMTable *table))block {
    RLMRealm *realm = [RLMRealm realmWithPath:[RLMTestCase pathInAppDocumentsFolderForFileWithName:RLMTestRealmPath]];
    [realm beginWriteTransaction];
    block([realm createTableWithName:@"table"]);
    [realm commitWriteTransaction];
}

+ (NSString *)pathInAppDocumentsFolderForFileWithName:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end
