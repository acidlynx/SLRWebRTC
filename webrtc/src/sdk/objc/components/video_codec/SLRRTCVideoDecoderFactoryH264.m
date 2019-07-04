/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCVideoDecoderFactoryH264.h"

#import "SLRRTCH264ProfileLevelId.h"
#import "SLRRTCVideoDecoderH264.h"

@implementation SLRRTCVideoDecoderFactoryH264

- (id<SLRRTCVideoDecoder>)createDecoder:(SLRRTCVideoCodecInfo *)info {
  return [[SLRRTCVideoDecoderH264 alloc] init];
}

- (NSArray<SLRRTCVideoCodecInfo *> *)supportedCodecs {
  NSString *codecName = kRTCVideoCodecH264Name;
  return @[ [[SLRRTCVideoCodecInfo alloc] initWithName:codecName parameters:nil] ];
}

@end
