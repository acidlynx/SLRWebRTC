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

#import "SLRRTCCodecSpecificInfo.h"
#import "SLRRTCMacros.h"

/** Class for H264 specific config. */
typedef NS_ENUM(NSUInteger, SLRRTCH264PacketizationMode) {
  SLRRTCH264PacketizationModeNonInterleaved = 0,  // Mode 1 - STAP-A, FU-A is allowed
  SLRRTCH264PacketizationModeSingleNalUnit        // Mode 0 - only single NALU allowed
};

RTC_OBJC_EXPORT
@interface SLRRTCCodecSpecificInfoH264 : NSObject <SLRRTCCodecSpecificInfo>

@property(nonatomic, assign) SLRRTCH264PacketizationMode packetizationMode;

@end
