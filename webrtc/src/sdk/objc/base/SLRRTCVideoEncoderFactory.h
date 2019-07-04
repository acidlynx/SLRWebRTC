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
#import "SLRRTCVideoCodecInfo.h"
#import "SLRRTCVideoEncoder.h"

NS_ASSUME_NONNULL_BEGIN

/** SLRRTCVideoEncoderFactory is an Objective-C version of webrtc::VideoEncoderFactory. */
RTC_OBJC_EXPORT
@protocol SLRRTCVideoEncoderFactory <NSObject>

- (nullable id<SLRRTCVideoEncoder>)createEncoder:(SLRRTCVideoCodecInfo *)info;
- (NSArray<SLRRTCVideoCodecInfo *> *)supportedCodecs;  // TODO(andersc): "supportedFormats" instead?

@end

NS_ASSUME_NONNULL_END
