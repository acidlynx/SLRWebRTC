/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCRtpSender+Private.h"

#import "SLRRTCDtmfSender+Private.h"
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCRtpParameters+Private.h"
#import "SLRRTCRtpSender+Native.h"
#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

#include "api/media_stream_interface.h"

@implementation SLRRTCRtpSender {
  SLRRTCPeerConnectionFactory *_factory;
  rtc::scoped_refptr<webrtc::RtpSenderInterface> _nativeRtpSender;
}

@synthesize dtmfSender = _dtmfSender;

- (NSString *)senderId {
  return [NSString stringForStdString:_nativeRtpSender->id()];
}

- (SLRRTCRtpParameters *)parameters {
  return [[SLRRTCRtpParameters alloc]
      initWithNativeParameters:_nativeRtpSender->GetParameters()];
}

- (void)setParameters:(SLRRTCRtpParameters *)parameters {
  if (!_nativeRtpSender->SetParameters(parameters.nativeParameters).ok()) {
    SLRRTCLogError(@"SLRRTCRtpSender(%p): Failed to set parameters: %@", self,
        parameters);
  }
}

- (SLRRTCMediaStreamTrack *)track {
  rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> nativeTrack(
    _nativeRtpSender->track());
  if (nativeTrack) {
    return [SLRRTCMediaStreamTrack mediaTrackForNativeTrack:nativeTrack factory:_factory];
  }
  return nil;
}

- (void)setTrack:(SLRRTCMediaStreamTrack *)track {
  if (!_nativeRtpSender->SetTrack(track.nativeTrack)) {
    SLRRTCLogError(@"SLRRTCRtpSender(%p): Failed to set track %@", self, track);
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCRtpSender {\n  senderId: %@\n}",
      self.senderId];
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (object == nil) {
    return NO;
  }
  if (![object isMemberOfClass:[self class]]) {
    return NO;
  }
  SLRRTCRtpSender *sender = (SLRRTCRtpSender *)object;
  return _nativeRtpSender == sender.nativeRtpSender;
}

- (NSUInteger)hash {
  return (NSUInteger)_nativeRtpSender.get();
}

#pragma mark - Native

- (void)setFrameEncryptor:(rtc::scoped_refptr<webrtc::FrameEncryptorInterface>)frameEncryptor {
  _nativeRtpSender->SetFrameEncryptor(frameEncryptor);
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::RtpSenderInterface>)nativeRtpSender {
  return _nativeRtpSender;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                nativeRtpSender:(rtc::scoped_refptr<webrtc::RtpSenderInterface>)nativeRtpSender {
  NSParameterAssert(factory);
  NSParameterAssert(nativeRtpSender);
  if (self = [super init]) {
    _factory = factory;
    _nativeRtpSender = nativeRtpSender;
    rtc::scoped_refptr<webrtc::DtmfSenderInterface> nativeDtmfSender(
        _nativeRtpSender->GetDtmfSender());
    if (nativeDtmfSender) {
      _dtmfSender = [[SLRRTCDtmfSender alloc] initWithNativeDtmfSender:nativeDtmfSender];
    }
    SLRRTCLogInfo(@"SLRRTCRtpSender(%p): created sender: %@", self, self.description);
  }
  return self;
}

@end
