////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import XCTest
import TestFramework

class SwiftLinkTests: RLMTestCase {
    
    func testBasicLink() {
        let realm = realmWithTestPath()
        
        let owner = OwnerObject()
        owner.name = "Tim"
        owner.dog = DogObject()
        owner.dog.dogName = "Harvie"
        
        realm.beginWriteTransaction()
        realm.addObject(owner)
        realm.commitWriteTransaction()
        
        let owners = OwnerObject.allObjectsInRealm(realm)
        let dogs = DogObject.allObjectsInRealm(realm)
        XCTAssertEqual(owners.count, 1, "Expecting 1 owner")
        XCTAssertEqual(dogs.count, 1, "Expecting 1 dog")
        XCTAssertEqualObjects((owners[0] as OwnerObject).name, "Tim", "Tim is named Tim")
        XCTAssertEqualObjects((dogs[0] as DogObject).dogName, "Harvie", "Harvie is named Harvie")
        
        let tim = owners[0] as OwnerObject
        XCTAssertEqualObjects(tim.dog.dogName, "Harvie", "Tim's dog should be Harvie")
    }
    
    func testMultipleOwnerLink() {
        let realm = realmWithTestPath()
        
        let owner = OwnerObject()
        owner.name = "Tim"
        owner.dog = DogObject()
        owner.dog.dogName = "Harvie"
        
        realm.beginWriteTransaction()
        realm.addObject(owner)
        realm.commitWriteTransaction()
        
        XCTAssertEqual(OwnerObject.allObjectsInRealm(realm).count, 1, "Expecting 1 owner")
        XCTAssertEqual(DogObject.allObjectsInRealm(realm).count, 1, "Expecting 1 dog")
        
        realm.beginWriteTransaction()
        let fiel = OwnerObject.createInRealm(realm, withObject: ["Fiel", NSNull()])
        fiel.dog = owner.dog
        realm.commitWriteTransaction()
        
        XCTAssertEqual(OwnerObject.allObjectsInRealm(realm).count, 2, "Expecting 2 owners")
        XCTAssertEqual(DogObject.allObjectsInRealm(realm).count, 1, "Expecting 1 dog")
    }
    
    func testLinkRemoval() {
        let realm = realmWithTestPath()
        
        let owner = OwnerObject()
        owner.name = "Tim"
        owner.dog = DogObject()
        owner.dog.dogName = "Harvie"
        
        realm.beginWriteTransaction()
        realm.addObject(owner)
        realm.commitWriteTransaction()
        
        XCTAssertEqual(OwnerObject.allObjectsInRealm(realm).count, 1, "Expecting 1 owner")
        XCTAssertEqual(DogObject.allObjectsInRealm(realm).count, 1, "Expecting 1 dog")
        
        realm.beginWriteTransaction()
        realm.deleteObject(owner.dog)
        realm.commitWriteTransaction()
        
        XCTAssertNil(owner.dog, "Dog should be nullified when deleted")
        
        // refresh owner and check
        let owner2 = OwnerObject.allObjectsInRealm(realm).firstObject
        XCTAssertNotNil(owner, "Should have 1 owner")
        XCTAssertNil(owner.dog, "Dog should be nullified when deleted")
        XCTAssertEqual(DogObject.allObjectsInRealm(realm).count, 0, "Expecting 0 dogs")
    }

//    FIXME - disabled until we fix commit log issue which break transacions when leaking realm objects
//    func testCircularLinks() {
//        let realm = realmWithTestPath()
//        
//        let obj = CircleObject()
//        obj.data = "a"
//        obj.next = obj
//        
//        realm.beginWriteTransaction()
//        realm.addObject(obj)
//        obj.next.data = "b"
//        realm.commitWriteTransaction()
//        
//        let obj2 = OwnerObject.allObjectsInRealm(realm).firstObject() as CircleObject
//        XCTAssertEqualObjects(obj2.data, "b", "data should be 'b'")
//        XCTAssertEqualObjects(obj2.data, obj2.next.data, "objects should be equal")
//    }
}
