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

#import "RLMRealmBrowserWindowController.h"
#import "NSTableColumn+Resize.h"

const NSUInteger kMaxNumberOfArrayEntriesInToolTip = 5;

@implementation RLMRealmBrowserWindowController

#pragma mark - NSWindowsController overrides

- (void)windowDidLoad
{
    [self.tableViewController viewDidLoad];
        
}

- (void)updateSelectedTypeNode:(RLMObjectNode *)typeNode
{
    [self.outlineViewController selectTypeNode:typeNode];
    [self.tableViewController updateSelectedObjectNode:typeNode];
}

- (void)updateSelectedObjectNode:(RLMObjectNode *)outlineNode
{
    [self.tableViewController updateSelectedObjectNode:outlineNode];
}

- (void)classSelectionWasChangedTo:(RLMClazzNode *)classNode
{
    [self.outlineViewController selectTypeNode:classNode];
}

- (void)addArray:(RLMArray *)array fromProperty:(RLMProperty *)property object:(RLMObject *)object
{
    RLMClazzNode *selectedClassNode = (RLMClazzNode *)self.selectedTypeNode;
    
    RLMArrayNode *arrayNode = [selectedClassNode displayChildArray:array
                                                      fromProperty:property
                                                            object:object];
    
    NSOutlineView *outlineView = (NSOutlineView *)self.outlineViewController.view;
    [outlineView reloadData];
    
    [outlineView expandItem:selectedClassNode];
    
    NSInteger index = [outlineView rowForItem:arrayNode];
    if (index != NSNotFound) {
        [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                 byExtendingSelection:NO];
    }    
}

@end
