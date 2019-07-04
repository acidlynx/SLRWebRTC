/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#include <vector>

#include "rtc_base/gunit.h"

#import "api/peerconnection/SLRRTCTracing.h"
#import "helpers/NSString+StdString.h"

@interface SLRRTCTracingTest : NSObject
- (void)tracingTestNoInitialization;
@end

@implementation SLRRTCTracingTest

- (NSString *)documentsFilePathForFileName:(NSString *)fileName {
  NSParameterAssert(fileName.length);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirPath = paths.firstObject;
  NSString *filePath =
  [documentsDirPath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (void)tracingTestNoInitialization {
  NSString *filePath = [self documentsFilePathForFileName:@"webrtc-trace.txt"];
  EXPECT_EQ(NO, SLRRTCStartInternalCapture(filePath));
  SLRRTCStopInternalCapture();
}

@end

TEST(SLRRTCTracingTest, TracingTestNoInitialization) {
  @autoreleasepool {
    SLRRTCTracingTest *test = [[SLRRTCTracingTest alloc] init];
    [test tracingTestNoInitialization];
  }
}
