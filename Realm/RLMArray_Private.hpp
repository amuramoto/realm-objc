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

#import "RLMArray.h"

#import <tightdb/row.hpp>
#import <tightdb/link_view.hpp>
#import <tightdb/table_view.hpp>
#import <tightdb/query.hpp>

//
// RLMArray private properties/ivars for all subclasses
//
// NOTE: We put all sublass properties in the same class to keep
//       the ivar layout the same - this allows us to switch implementations
//       after creation
@interface RLMArray () {
  @private
    // array for standalone
    NSMutableArray *_backingArray;
  @protected
    // accessor ivars
    RLMRealm *_realm;
    NSString *_objectClassName;
    BOOL _readOnly;     // YES for RLMArrays which are never mutable
}

/**
 Initialize an RLMArray.
 
 @warning Realm arrays are typed. You must specify an RLMObject class name during initialization
 and can only add objects of this type to the array.
 
 @param objectClassName     The class name of the RLMObjects this RLMArray will hold.
 
 @return                    An initialized RLMArray instance.
 */
- (instancetype)initWithObjectClassName:(NSString *)objectClassName;

// create standalone array variant
+ (instancetype)standaloneArrayWithObjectClassName:(NSString *)objectClassName;

@end


//
// LinkView backed RLMArray subclass
//
@interface RLMArrayLinkView : RLMArray {
    // FIXME - make private once we have self updating accessors - for
    //         now this gets set externally
    @public
    tightdb::LinkViewRef _backingLinkView;
}
+ (instancetype)arrayWithObjectClassName:(NSString *)objectClassName
                                          view:(tightdb::LinkViewRef)view
                                         realm:(RLMRealm *)realm;
@end


//
// TableView backed RLMArray subclass
//
@interface RLMArrayTableView : RLMArray {
    tightdb::TableView _backingView;
    tightdb::util::UniquePtr<tightdb::Query> _backingQuery;
}
+ (instancetype)arrayWithObjectClassName:(NSString *)objectClassName
                                   query:(tightdb::Query *)query
                                    view:(tightdb::TableView &)view
                                   realm:(RLMRealm *)realm;

// custom getter/setter for query - query lifcycle management
// is different from other accessors and requires special treatment
@property (nonatomic, assign) tightdb::Query *backingQuery;

@end



