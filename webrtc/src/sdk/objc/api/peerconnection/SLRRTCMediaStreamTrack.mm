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
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCVideoTrack+Private.h"

#import "helpers/NSString+StdString.h"

NSString * const kRTCMediaStreamTrackKindAudio =
    @(webrtc::MediaStreamTrackInterface::kAudioKind);
NSString * const kRTCMediaStreamTrackKindVideo =
    @(webrtc::MediaStreamTrackInterface::kVideoKind);

@implementation SLRRTCMediaStreamTrack {
  SLRRTCPeerConnectionFactory *_factory;
  rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> _nativeTrack;
  SLRRTCMediaStreamTrackType _type;
}

- (NSString *)kind {
  return [NSString stringForStdString:_nativeTrack->kind()];
}

- (NSString *)trackId {
  return [NSString stringForStdString:_nativeTrack->id()];
}

- (BOOL)isEnabled {
  return _nativeTrack->enabled();
}

- (void)setIsEnabled:(BOOL)isEnabled {
  _nativeTrack->set_enabled(isEnabled);
}

- (SLRRTCMediaStreamTrackState)readyState {
  return [[self class] trackStateForNativeState:_nativeTrack->state()];
}

- (NSString *)description {
  NSString *readyState = [[self class] stringForState:self.readyState];
  return [NSString stringWithFormat:@"SLRRTCMediaStreamTrack:\n%@\n%@\n%@\n%@",
                                    self.kind,
                                    self.trackId,
                                    self.isEnabled ? @"enabled" : @"disabled",
                                    readyState];
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isMemberOfClass:[self class]]) {
    return NO;
  }
  return [self isEqualToTrack:(SLRRTCMediaStreamTrack *)object];
}

- (NSUInteger)hash {
  return (NSUInteger)_nativeTrack.get();
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack {
  return _nativeTrack;
}

@synthesize factory = _factory;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                    nativeTrack:(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack
                           type:(SLRRTCMediaStreamTrackType)type {
  NSParameterAssert(nativeTrack);
  NSParameterAssert(factory);
  if (self = [super init]) {
    _factory = factory;
    _nativeTrack = nativeTrack;
    _type = type;
  }
  return self;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                    nativeTrack:(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack {
  NSParameterAssert(nativeTrack);
  if (nativeTrack->kind() ==
      std::string(webrtc::MediaStreamTrackInterface::kAudioKind)) {
    return [self initWithFactory:factory nativeTrack:nativeTrack type:SLRRTCMediaStreamTrackTypeAudio];
  }
  if (nativeTrack->kind() ==
      std::string(webrtc::MediaStreamTrackInterface::kVideoKind)) {
    return [self initWithFactory:factory nativeTrack:nativeTrack type:SLRRTCMediaStreamTrackTypeVideo];
  }
  return nil;
}

- (BOOL)isEqualToTrack:(SLRRTCMediaStreamTrack *)track {
  if (!track) {
    return NO;
  }
  return _nativeTrack == track.nativeTrack;
}

+ (webrtc::MediaStreamTrackInterface::TrackState)nativeTrackStateForState:
    (SLRRTCMediaStreamTrackState)state {
  switch (state) {
    case SLRRTCMediaStreamTrackStateLive:
      return webrtc::MediaStreamTrackInterface::kLive;
    case SLRRTCMediaStreamTrackStateEnded:
      return webrtc::MediaStreamTrackInterface::kEnded;
  }
}

+ (SLRRTCMediaStreamTrackState)trackStateForNativeState:
    (webrtc::MediaStreamTrackInterface::TrackState)nativeState {
  switch (nativeState) {
    case webrtc::MediaStreamTrackInterface::kLive:
      return SLRRTCMediaStreamTrackStateLive;
    case webrtc::MediaStreamTrackInterface::kEnded:
      return SLRRTCMediaStreamTrackStateEnded;
  }
}

+ (NSString *)stringForState:(SLRRTCMediaStreamTrackState)state {
  switch (state) {
    case SLRRTCMediaStreamTrackStateLive:
      return @"Live";
    case SLRRTCMediaStreamTrackStateEnded:
      return @"Ended";
  }
}

+ (SLRRTCMediaStreamTrack *)mediaTrackForNativeTrack:
                             (rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack
                                          factory:(SLRRTCPeerConnectionFactory *)factory {
  NSParameterAssert(nativeTrack);
  NSParameterAssert(factory);
  if (nativeTrack->kind() == webrtc::MediaStreamTrackInterface::kAudioKind) {
    return [[SLRRTCAudioTrack alloc] initWithFactory:factory
                                      nativeTrack:nativeTrack
                                             type:SLRRTCMediaStreamTrackTypeAudio];
  } else if (nativeTrack->kind() == webrtc::MediaStreamTrackInterface::kVideoKind) {
    return [[SLRRTCVideoTrack alloc] initWithFactory:factory
                                      nativeTrack:nativeTrack
                                             type:SLRRTCMediaStreamTrackTypeVideo];
  } else {
    return [[SLRRTCMediaStreamTrack alloc] initWithFactory:factory nativeTrack:nativeTrack];
  }
}

@end
