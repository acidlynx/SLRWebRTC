/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMediaSource.h"

#include "api/media_stream_interface.h"

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCPeerConnectionFactory;

typedef NS_ENUM(NSInteger, SLRRTCMediaSourceType) {
  SLRRTCMediaSourceTypeAudio,
  SLRRTCMediaSourceTypeVideo,
};

@interface SLRRTCMediaSource ()

@property(nonatomic, readonly) rtc::scoped_refptr<webrtc::MediaSourceInterface> nativeMediaSource;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeMediaSource:(rtc::scoped_refptr<webrtc::MediaSourceInterface>)nativeMediaSource
                           type:(SLRRTCMediaSourceType)type NS_DESIGNATED_INITIALIZER;

+ (webrtc::MediaSourceInterface::SourceState)nativeSourceStateForState:(SLRRTCSourceState)state;

+ (SLRRTCSourceState)sourceStateForNativeState:(webrtc::MediaSourceInterface::SourceState)nativeState;

+ (NSString *)stringForState:(SLRRTCSourceState)state;

@end

NS_ASSUME_NONNULL_END
