/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "components/video_codec/SLRRTCH264ProfileLevelId.h"

#import <XCTest/XCTest.h>

@interface SLRRTCH264ProfileLevelIdTests : XCTestCase

@end

static NSString *level31ConstrainedHigh = @"640c1f";
static NSString *level31ConstrainedBaseline = @"42e01f";

@implementation SLRRTCH264ProfileLevelIdTests

- (void)testInitWithString {
  SLRRTCH264ProfileLevelId *profileLevelId =
      [[SLRRTCH264ProfileLevelId alloc] initWithHexString:level31ConstrainedHigh];
  XCTAssertEqual(profileLevelId.profile, SLRRTCH264ProfileConstrainedHigh);
  XCTAssertEqual(profileLevelId.level, SLRRTCH264Level3_1);

  profileLevelId = [[SLRRTCH264ProfileLevelId alloc] initWithHexString:level31ConstrainedBaseline];
  XCTAssertEqual(profileLevelId.profile, SLRRTCH264ProfileConstrainedBaseline);
  XCTAssertEqual(profileLevelId.level, SLRRTCH264Level3_1);
}

- (void)testInitWithProfileAndLevel {
  SLRRTCH264ProfileLevelId *profileLevelId =
      [[SLRRTCH264ProfileLevelId alloc] initWithProfile:SLRRTCH264ProfileConstrainedHigh
                                               level:SLRRTCH264Level3_1];
  XCTAssertEqualObjects(profileLevelId.hexString, level31ConstrainedHigh);

  profileLevelId = [[SLRRTCH264ProfileLevelId alloc] initWithProfile:SLRRTCH264ProfileConstrainedBaseline
                                                            level:SLRRTCH264Level3_1];
  XCTAssertEqualObjects(profileLevelId.hexString, level31ConstrainedBaseline);
}

@end
