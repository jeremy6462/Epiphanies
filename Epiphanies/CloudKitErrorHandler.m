//
//  CloudKitErrorHandler.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/19/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "CloudKitErrorHandler.h"

typedef NS_ENUM(NSInteger, CloudKitErrorResponse) {
    Retry,
    Ignore,
    MergeIssue,
    Success
};

@implementation CloudKitErrorHandler

- (CloudKitErrorResponse) handleError:(NSError *)error
{
    if(error == nil) return Success;
    
    switch ([error code])
    {
        case CKErrorNetworkUnavailable:
        case CKErrorNetworkFailure:
            // A reachability check might be appropriate here so we don't just keep retrying if the user has no service
        case CKErrorServiceUnavailable:
        case CKErrorRequestRateLimited:
            return Retry;
            break;
            
        case CKErrorBadContainer:
        case CKErrorMissingEntitlement:
        case CKErrorPermissionFailure:
        case CKErrorBadDatabase:
            // This app uses the publicDB with default world readable permissions
        case CKErrorUnknownItem:
        case CKErrorAssetFileNotFound:
            // This shouldn't happen. If an Image record is deleted it should delete all Post records that reference it (CKReferenceActionDeleteSelf)
        case CKErrorIncompatibleVersion:
        case CKErrorQuotaExceeded:
            //App quota will be exceeded, cancelling operation
        case CKErrorOperationCancelled:
            // Nothing to do here, we intentionally cancelled
        case CKErrorNotAuthenticated:
        case CKErrorInvalidArguments:
        case CKErrorResultsTruncated:
        case CKErrorServerRecordChanged:
        case CKErrorAssetFileModified:
        case CKErrorChangeTokenExpired:
        case CKErrorBatchRequestFailed:
        case CKErrorZoneBusy:
        case CKErrorZoneNotFound:
        case CKErrorLimitExceeded:
        case CKErrorUserDeletedZone:
            // These errors are pretty irrelevant here
            // We're fetching only one record by its recordID
            // These errors could be hit fetching multiple records, using zones, saving records, or fetching with predicates
        case CKErrorInternalError:
        case CKErrorServerRejectedRequest:
        case CKErrorConstraintViolation:
            NSLog(@"Nonrecoverable error, will not retry");
        default:
            return Ignore;
            break;
    }
}

@end
