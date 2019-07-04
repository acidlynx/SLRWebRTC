/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCAudioTrack+Private.h"

#import "SLRRTCAudioSource+Private.h"
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCPeerConnectionFactory+Private.h"
#import "helpers/NSString+StdString.h"

#include "rtc_base/checks.h"

@implementation SLRRTCAudioTrack

@synthesize source = _source;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                         source:(SLRRTCAudioSource *)source
                        trackId:(NSString *)trackId {
  RTC_DCHECK(factory);
  RTC_DCHECK(source);
  RTC_DCHECK(trackId.length);

  std::string nativeId = [NSString stdStringForString:trackId];
  rtc::scoped_refptr<webrtc::AudioTrackInterface> track =
      factory.nativeFactory->CreateAudioTrack(nativeId, source.nativeAudioSource);
  if (self = [self initWithFactory:factory nativeTrack:track type:SLRRTCMediaStreamTrackTypeAudio]) {
    _source = source;
  }
  return self;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                    nativeTrack:(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack
                           type:(SLRRTCMediaStreamTrackType)type {
  NSParameterAssert(factory);
  NSParameterAssert(nativeTrack);
  NSParameterAssert(type == SLRRTCMediaStreamTrackTypeAudio);
  return [super initWithFactory:factory nativeTrack:nativeTrack type:type];
}


- (SLRRTCAudioSource *)source {
  if (!_source) {
    rtc::scoped_refptr<webrtc::AudioSourceInterface> source =
        self.nativeAudioTrack->GetSource();
    if (source) {
      _source =
          [[SLRRTCAudioSource alloc] initWithFactory:self.factory nativeAudioSource:source.get()];
    }
  }
  return _source;
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::AudioTrackInterface>)nativeAudioTrack {
  return static_cast<webrtc::AudioTrackInterface *>(self.nativeTrack.get());
}

@end
