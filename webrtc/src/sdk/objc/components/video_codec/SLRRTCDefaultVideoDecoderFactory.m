/*
 *  Copyright 2017 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCDefaultVideoDecoderFactory.h"

#import "SLRRTCH264ProfileLevelId.h"
#import "SLRRTCVideoDecoderH264.h"
#import "api/video_codec/SLRRTCVideoCodecConstants.h"
#import "api/video_codec/SLRRTCVideoDecoderVP8.h"
#import "base/SLRRTCVideoCodecInfo.h"
#if defined(RTC_ENABLE_VP9)
#import "api/video_codec/SLRRTCVideoDecoderVP9.h"
#endif

@implementation SLRRTCDefaultVideoDecoderFactory

- (id<SLRRTCVideoDecoder>)createDecoder:(SLRRTCVideoCodecInfo *)info {
  if ([info.name isEqualToString:kRTCVideoCodecH264Name]) {
    return [[SLRRTCVideoDecoderH264 alloc] init];
  } else if ([info.name isEqualToString:kRTCVideoCodecVp8Name]) {
    return [SLRRTCVideoDecoderVP8 vp8Decoder];
#if defined(RTC_ENABLE_VP9)
  } else if ([info.name isEqualToString:kRTCVideoCodecVp9Name]) {
    return [SLRRTCVideoDecoderVP9 vp9Decoder];
#endif
  }

  return nil;
}

- (NSArray<SLRRTCVideoCodecInfo *> *)supportedCodecs {
  return @[
    [[SLRRTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecH264Name],
    [[SLRRTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecVp8Name],
#if defined(RTC_ENABLE_VP9)
    [[SLRRTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecVp9Name],
#endif
  ];
}

@end
