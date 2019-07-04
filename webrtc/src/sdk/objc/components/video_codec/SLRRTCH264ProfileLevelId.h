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

#import "SLRRTCMacros.h"

RTC_OBJC_EXPORT extern NSString *const kRTCVideoCodecH264Name;
RTC_OBJC_EXPORT extern NSString *const kRTCLevel31ConstrainedHigh;
RTC_OBJC_EXPORT extern NSString *const kRTCLevel31ConstrainedBaseline;
RTC_OBJC_EXPORT extern NSString *const kRTCMaxSupportedH264ProfileLevelConstrainedHigh;
RTC_OBJC_EXPORT extern NSString *const kRTCMaxSupportedH264ProfileLevelConstrainedBaseline;

/** H264 Profiles and levels. */
typedef NS_ENUM(NSUInteger, SLRRTCH264Profile) {
  SLRRTCH264ProfileConstrainedBaseline,
  SLRRTCH264ProfileBaseline,
  SLRRTCH264ProfileMain,
  SLRRTCH264ProfileConstrainedHigh,
  SLRRTCH264ProfileHigh,
};

typedef NS_ENUM(NSUInteger, SLRRTCH264Level) {
  SLRRTCH264Level1_b = 0,
  SLRRTCH264Level1 = 10,
  SLRRTCH264Level1_1 = 11,
  SLRRTCH264Level1_2 = 12,
  SLRRTCH264Level1_3 = 13,
  SLRRTCH264Level2 = 20,
  SLRRTCH264Level2_1 = 21,
  SLRRTCH264Level2_2 = 22,
  SLRRTCH264Level3 = 30,
  SLRRTCH264Level3_1 = 31,
  SLRRTCH264Level3_2 = 32,
  SLRRTCH264Level4 = 40,
  SLRRTCH264Level4_1 = 41,
  SLRRTCH264Level4_2 = 42,
  SLRRTCH264Level5 = 50,
  SLRRTCH264Level5_1 = 51,
  SLRRTCH264Level5_2 = 52
};

RTC_OBJC_EXPORT
@interface SLRRTCH264ProfileLevelId : NSObject

@property(nonatomic, readonly) SLRRTCH264Profile profile;
@property(nonatomic, readonly) SLRRTCH264Level level;
@property(nonatomic, readonly) NSString *hexString;

- (instancetype)initWithHexString:(NSString *)hexString;
- (instancetype)initWithProfile:(SLRRTCH264Profile)profile level:(SLRRTCH264Level)level;

@end
