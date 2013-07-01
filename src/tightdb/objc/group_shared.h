/*************************************************************************
 *
 * TIGHTDB CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2012] TightDB Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of TightDB Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to TightDB Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from TightDB Incorporated.
 *
 **************************************************************************/

#import <Foundation/Foundation.h>
#import <tightdb/objc/group.h>

typedef void(^TightdbSharedGroupReadTransactionBlock)(TightdbGroup *group);
typedef BOOL(^TightdbSharedGroupWriteTransactionBlock)(TightdbGroup *group);

@interface TightdbSharedGroup: NSObject
+(TightdbSharedGroup *)groupWithFilename:(NSString *)filename;
+(TightdbSharedGroup *)groupWithFilename:(NSString *)filename error:(NSError *__autoreleasing *)error;

-(BOOL)readTransaction:(TightdbSharedGroupReadTransactionBlock)block;
-(BOOL)readTransaction:(TightdbSharedGroupReadTransactionBlock)block error:(NSError *__autoreleasing *)error;
-(BOOL)writeTransaction:(TightdbSharedGroupWriteTransactionBlock)block;
-(BOOL)writeTransaction:(TightdbSharedGroupWriteTransactionBlock)block error:(NSError *__autoreleasing *)error;

@end
