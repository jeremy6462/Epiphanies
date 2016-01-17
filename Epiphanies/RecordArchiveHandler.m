//
//  RecordArchiveHandler.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/17/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import "RecordArchiveHandler.h"

@implementation RecordArchiveHandler

-(NSData *) archive: (CKRecord *)record {
    NSMutableData *archivedData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
    archiver.requiresSecureCoding = YES;
    [record encodeSystemFieldsWithCoder:archiver];
    [archiver finishEncoding];
    return archivedData;
}

-(CKRecord *) unarchive: (NSData *) archivedData {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
    unarchiver.requiresSecureCoding = YES;
    CKRecord *unarchivedRecord = [[CKRecord alloc] initWithCoder:unarchiver];
    return unarchivedRecord;
}

@end
