/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCRtpTransceiver+Private.h"

#import "SLRRTCRtpEncodingParameters+Private.h"
#import "SLRRTCRtpParameters+Private.h"
#import "SLRRTCRtpReceiver+Private.h"
#import "SLRRTCRtpSender+Private.h"
#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

@implementation SLRRTCRtpTransceiverInit

@synthesize direction = _direction;
@synthesize streamIds = _streamIds;
@synthesize sendEncodings = _sendEncodings;

- (instancetype)init {
  if (self = [super init]) {
    _direction = SLRRTCRtpTransceiverDirectionSendRecv;
  }
  return self;
}

- (webrtc::RtpTransceiverInit)nativeInit {
  webrtc::RtpTransceiverInit init;
  init.direction = [SLRRTCRtpTransceiver nativeRtpTransceiverDirectionFromDirection:_direction];
  for (NSString *streamId in _streamIds) {
    init.stream_ids.push_back([streamId UTF8String]);
  }
  for (SLRRTCRtpEncodingParameters *sendEncoding in _sendEncodings) {
    init.send_encodings.push_back(sendEncoding.nativeParameters);
  }
  return init;
}

@end

@implementation SLRRTCRtpTransceiver {
  SLRRTCPeerConnectionFactory *_factory;
  rtc::scoped_refptr<webrtc::RtpTransceiverInterface> _nativeRtpTransceiver;
}

- (SLRRTCRtpMediaType)mediaType {
  return [SLRRTCRtpReceiver mediaTypeForNativeMediaType:_nativeRtpTransceiver->media_type()];
}

- (NSString *)mid {
  if (_nativeRtpTransceiver->mid()) {
    return [NSString stringForStdString:*_nativeRtpTransceiver->mid()];
  } else {
    return nil;
  }
}

@synthesize sender = _sender;
@synthesize receiver = _receiver;

- (BOOL)isStopped {
  return _nativeRtpTransceiver->stopped();
}

- (SLRRTCRtpTransceiverDirection)direction {
  return [SLRRTCRtpTransceiver
      rtpTransceiverDirectionFromNativeDirection:_nativeRtpTransceiver->direction()];
}

- (void)setDirection:(SLRRTCRtpTransceiverDirection)direction {
  _nativeRtpTransceiver->SetDirection(
      [SLRRTCRtpTransceiver nativeRtpTransceiverDirectionFromDirection:direction]);
}

- (BOOL)currentDirection:(SLRRTCRtpTransceiverDirection *)currentDirectionOut {
  if (_nativeRtpTransceiver->current_direction()) {
    *currentDirectionOut = [SLRRTCRtpTransceiver
        rtpTransceiverDirectionFromNativeDirection:*_nativeRtpTransceiver->current_direction()];
    return YES;
  } else {
    return NO;
  }
}

- (void)stop {
  _nativeRtpTransceiver->Stop();
}

- (NSString *)description {
  return [NSString
      stringWithFormat:@"SLRRTCRtpTransceiver {\n  sender: %@\n  receiver: %@\n}", _sender, _receiver];
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
  SLRRTCRtpTransceiver *transceiver = (SLRRTCRtpTransceiver *)object;
  return _nativeRtpTransceiver == transceiver.nativeRtpTransceiver;
}

- (NSUInteger)hash {
  return (NSUInteger)_nativeRtpTransceiver.get();
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::RtpTransceiverInterface>)nativeRtpTransceiver {
  return _nativeRtpTransceiver;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
           nativeRtpTransceiver:
               (rtc::scoped_refptr<webrtc::RtpTransceiverInterface>)nativeRtpTransceiver {
  NSParameterAssert(factory);
  NSParameterAssert(nativeRtpTransceiver);
  if (self = [super init]) {
    _factory = factory;
    _nativeRtpTransceiver = nativeRtpTransceiver;
    _sender = [[SLRRTCRtpSender alloc] initWithFactory:_factory
                                    nativeRtpSender:nativeRtpTransceiver->sender()];
    _receiver = [[SLRRTCRtpReceiver alloc] initWithFactory:_factory
                                      nativeRtpReceiver:nativeRtpTransceiver->receiver()];
    SLRRTCLogInfo(@"SLRRTCRtpTransceiver(%p): created transceiver: %@", self, self.description);
  }
  return self;
}

+ (webrtc::RtpTransceiverDirection)nativeRtpTransceiverDirectionFromDirection:
        (SLRRTCRtpTransceiverDirection)direction {
  switch (direction) {
    case SLRRTCRtpTransceiverDirectionSendRecv:
      return webrtc::RtpTransceiverDirection::kSendRecv;
    case SLRRTCRtpTransceiverDirectionSendOnly:
      return webrtc::RtpTransceiverDirection::kSendOnly;
    case SLRRTCRtpTransceiverDirectionRecvOnly:
      return webrtc::RtpTransceiverDirection::kRecvOnly;
    case SLRRTCRtpTransceiverDirectionInactive:
      return webrtc::RtpTransceiverDirection::kInactive;
  }
}

+ (SLRRTCRtpTransceiverDirection)rtpTransceiverDirectionFromNativeDirection:
        (webrtc::RtpTransceiverDirection)nativeDirection {
  switch (nativeDirection) {
    case webrtc::RtpTransceiverDirection::kSendRecv:
      return SLRRTCRtpTransceiverDirectionSendRecv;
    case webrtc::RtpTransceiverDirection::kSendOnly:
      return SLRRTCRtpTransceiverDirectionSendOnly;
    case webrtc::RtpTransceiverDirection::kRecvOnly:
      return SLRRTCRtpTransceiverDirectionRecvOnly;
    case webrtc::RtpTransceiverDirection::kInactive:
      return SLRRTCRtpTransceiverDirectionInactive;
  }
}

@end
