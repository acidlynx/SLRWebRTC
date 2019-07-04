/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMediaSource+Private.h"

#include "rtc_base/checks.h"

@implementation SLRRTCMediaSource {
  SLRRTCPeerConnectionFactory *_factory;
  SLRRTCMediaSourceType _type;
}

@synthesize nativeMediaSource = _nativeMediaSource;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeMediaSource:(rtc::scoped_refptr<webrtc::MediaSourceInterface>)nativeMediaSource
                           type:(SLRRTCMediaSourceType)type {
  RTC_DCHECK(factory);
  RTC_DCHECK(nativeMediaSource);
  if (self = [super init]) {
    _factory = factory;
    _nativeMediaSource = nativeMediaSource;
    _type = type;
  }
  return self;
}

- (SLRRTCSourceState)state {
  return [[self class] sourceStateForNativeState:_nativeMediaSource->state()];
}

#pragma mark - Private

+ (webrtc::MediaSourceInterface::SourceState)nativeSourceStateForState:
    (SLRRTCSourceState)state {
  switch (state) {
    case SLRRTCSourceStateInitializing:
      return webrtc::MediaSourceInterface::kInitializing;
    case SLRRTCSourceStateLive:
      return webrtc::MediaSourceInterface::kLive;
    case SLRRTCSourceStateEnded:
      return webrtc::MediaSourceInterface::kEnded;
    case SLRRTCSourceStateMuted:
      return webrtc::MediaSourceInterface::kMuted;
  }
}

+ (SLRRTCSourceState)sourceStateForNativeState:
    (webrtc::MediaSourceInterface::SourceState)nativeState {
  switch (nativeState) {
    case webrtc::MediaSourceInterface::kInitializing:
      return SLRRTCSourceStateInitializing;
    case webrtc::MediaSourceInterface::kLive:
      return SLRRTCSourceStateLive;
    case webrtc::MediaSourceInterface::kEnded:
      return SLRRTCSourceStateEnded;
    case webrtc::MediaSourceInterface::kMuted:
      return SLRRTCSourceStateMuted;
  }
}

+ (NSString *)stringForState:(SLRRTCSourceState)state {
  switch (state) {
    case SLRRTCSourceStateInitializing:
      return @"Initializing";
    case SLRRTCSourceStateLive:
      return @"Live";
    case SLRRTCSourceStateEnded:
      return @"Ended";
    case SLRRTCSourceStateMuted:
      return @"Muted";
  }
}

@end
