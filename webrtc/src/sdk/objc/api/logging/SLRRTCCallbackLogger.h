/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "SLRRTCLogging.h"
#import "SLRRTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SLRRTCCallbackLoggerMessageHandler)(NSString *message);
typedef void (^SLRRTCCallbackLoggerMessageAndSeverityHandler)(NSString *message,
                                                           SLRRTCLoggingSeverity severity);

// This class intercepts WebRTC logs and forwards them to a registered block.
// This class is not threadsafe.
RTC_OBJC_EXPORT
@interface SLRRTCCallbackLogger : NSObject

// The severity level to capture. The default is kRTCLoggingSeverityInfo.
@property(nonatomic, assign) SLRRTCLoggingSeverity severity;

// The callback handler will be called on the same thread that does the
// logging, so if the logging callback can be slow it may be a good idea
// to implement dispatching to some other queue.
- (void)start:(nullable SLRRTCCallbackLoggerMessageHandler)handler;
- (void)startWithMessageAndSeverityHandler:
        (nullable SLRRTCCallbackLoggerMessageAndSeverityHandler)handler;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
