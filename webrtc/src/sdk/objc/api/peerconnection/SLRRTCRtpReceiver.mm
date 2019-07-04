/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCRtpReceiver+Private.h"

#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCRtpParameters+Private.h"
#import "SLRRTCRtpReceiver+Native.h"
#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

#include "api/media_stream_interface.h"

namespace webrtc {

RtpReceiverDelegateAdapter::RtpReceiverDelegateAdapter(
    SLRRTCRtpReceiver *receiver) {
  RTC_CHECK(receiver);
  receiver_ = receiver;
}

void RtpReceiverDelegateAdapter::OnFirstPacketReceived(
    cricket::MediaType media_type) {
  SLRRTCRtpMediaType packet_media_type =
      [SLRRTCRtpReceiver mediaTypeForNativeMediaType:media_type];
  SLRRTCRtpReceiver *receiver = receiver_;
  [receiver.delegate rtpReceiver:receiver didReceiveFirstPacketForMediaType:packet_media_type];
}

}  // namespace webrtc

@implementation SLRRTCRtpReceiver {
  SLRRTCPeerConnectionFactory *_factory;
  rtc::scoped_refptr<webrtc::RtpReceiverInterface> _nativeRtpReceiver;
  std::unique_ptr<webrtc::RtpReceiverDelegateAdapter> _observer;
}

@synthesize delegate = _delegate;

- (NSString *)receiverId {
  return [NSString stringForStdString:_nativeRtpReceiver->id()];
}

- (SLRRTCRtpParameters *)parameters {
  return [[SLRRTCRtpParameters alloc]
      initWithNativeParameters:_nativeRtpReceiver->GetParameters()];
}

- (void)setParameters:(SLRRTCRtpParameters *)parameters {
  if (!_nativeRtpReceiver->SetParameters(parameters.nativeParameters)) {
    SLRRTCLogError(@"SLRRTCRtpReceiver(%p): Failed to set parameters: %@", self,
        parameters);
  }
}

- (nullable SLRRTCMediaStreamTrack *)track {
  rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> nativeTrack(
    _nativeRtpReceiver->track());
  if (nativeTrack) {
    return [SLRRTCMediaStreamTrack mediaTrackForNativeTrack:nativeTrack factory:_factory];
  }
  return nil;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCRtpReceiver {\n  receiverId: %@\n}",
      self.receiverId];
}

- (void)dealloc {
  if (_nativeRtpReceiver) {
    _nativeRtpReceiver->SetObserver(nullptr);
  }
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
  SLRRTCRtpReceiver *receiver = (SLRRTCRtpReceiver *)object;
  return _nativeRtpReceiver == receiver.nativeRtpReceiver;
}

- (NSUInteger)hash {
  return (NSUInteger)_nativeRtpReceiver.get();
}

#pragma mark - Native

- (void)setFrameDecryptor:(rtc::scoped_refptr<webrtc::FrameDecryptorInterface>)frameDecryptor {
  _nativeRtpReceiver->SetFrameDecryptor(frameDecryptor);
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::RtpReceiverInterface>)nativeRtpReceiver {
  return _nativeRtpReceiver;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeRtpReceiver:
                  (rtc::scoped_refptr<webrtc::RtpReceiverInterface>)nativeRtpReceiver {
  if (self = [super init]) {
    _factory = factory;
    _nativeRtpReceiver = nativeRtpReceiver;
    SLRRTCLogInfo(
        @"SLRRTCRtpReceiver(%p): created receiver: %@", self, self.description);
    _observer.reset(new webrtc::RtpReceiverDelegateAdapter(self));
    _nativeRtpReceiver->SetObserver(_observer.get());
  }
  return self;
}

+ (SLRRTCRtpMediaType)mediaTypeForNativeMediaType:
    (cricket::MediaType)nativeMediaType {
  switch (nativeMediaType) {
    case cricket::MEDIA_TYPE_AUDIO:
      return SLRRTCRtpMediaTypeAudio;
    case cricket::MEDIA_TYPE_VIDEO:
      return SLRRTCRtpMediaTypeVideo;
    case cricket::MEDIA_TYPE_DATA:
      return SLRRTCRtpMediaTypeData;
  }
}

+ (cricket::MediaType)nativeMediaTypeForMediaType:(SLRRTCRtpMediaType)mediaType {
  switch (mediaType) {
    case SLRRTCRtpMediaTypeAudio:
      return cricket::MEDIA_TYPE_AUDIO;
    case SLRRTCRtpMediaTypeVideo:
      return cricket::MEDIA_TYPE_VIDEO;
    case SLRRTCRtpMediaTypeData:
      return cricket::MEDIA_TYPE_DATA;
  }
}

+ (NSString *)stringForMediaType:(SLRRTCRtpMediaType)mediaType {
  switch (mediaType) {
    case SLRRTCRtpMediaTypeAudio:
      return @"AUDIO";
    case SLRRTCRtpMediaTypeVideo:
      return @"VIDEO";
    case SLRRTCRtpMediaTypeData:
      return @"DATA";
  }
}

@end
