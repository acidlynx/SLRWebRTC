/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCVideoEncoderFactoryH264.h"

#import "SLRRTCH264ProfileLevelId.h"
#import "SLRRTCVideoEncoderH264.h"

@implementation SLRRTCVideoEncoderFactoryH264

- (NSArray<SLRRTCVideoCodecInfo *> *)supportedCodecs {
  NSMutableArray<SLRRTCVideoCodecInfo *> *codecs = [NSMutableArray array];
  NSString *codecName = kRTCVideoCodecH264Name;

  NSDictionary<NSString *, NSString *> *constrainedHighParams = @{
    @"profile-level-id" : kRTCMaxSupportedH264ProfileLevelConstrainedHigh,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  SLRRTCVideoCodecInfo *constrainedHighInfo =
      [[SLRRTCVideoCodecInfo alloc] initWithName:codecName parameters:constrainedHighParams];
  [codecs addObject:constrainedHighInfo];

  NSDictionary<NSString *, NSString *> *constrainedBaselineParams = @{
    @"profile-level-id" : kRTCMaxSupportedH264ProfileLevelConstrainedBaseline,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  SLRRTCVideoCodecInfo *constrainedBaselineInfo =
      [[SLRRTCVideoCodecInfo alloc] initWithName:codecName parameters:constrainedBaselineParams];
  [codecs addObject:constrainedBaselineInfo];

  return [codecs copy];
}

- (id<SLRRTCVideoEncoder>)createEncoder:(SLRRTCVideoCodecInfo *)info {
  return [[SLRRTCVideoEncoderH264 alloc] initWithCodecInfo:info];
}

@end
