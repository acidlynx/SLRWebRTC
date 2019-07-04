/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCIceCandidate+Private.h"

#include <memory>

#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

@implementation SLRRTCIceCandidate

@synthesize sdpMid = _sdpMid;
@synthesize sdpMLineIndex = _sdpMLineIndex;
@synthesize sdp = _sdp;
@synthesize serverUrl = _serverUrl;

- (instancetype)initWithSdp:(NSString *)sdp
              sdpMLineIndex:(int)sdpMLineIndex
                     sdpMid:(NSString *)sdpMid {
  NSParameterAssert(sdp.length);
  if (self = [super init]) {
    _sdpMid = [sdpMid copy];
    _sdpMLineIndex = sdpMLineIndex;
    _sdp = [sdp copy];
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCIceCandidate:\n%@\n%d\n%@\n%@",
                                    _sdpMid,
                                    _sdpMLineIndex,
                                    _sdp,
                                    _serverUrl];
}

#pragma mark - Private

- (instancetype)initWithNativeCandidate:
    (const webrtc::IceCandidateInterface *)candidate {
  NSParameterAssert(candidate);
  std::string sdp;
  candidate->ToString(&sdp);

  SLRRTCIceCandidate *rtcCandidate =
      [self initWithSdp:[NSString stringForStdString:sdp]
          sdpMLineIndex:candidate->sdp_mline_index()
                 sdpMid:[NSString stringForStdString:candidate->sdp_mid()]];
  rtcCandidate->_serverUrl = [NSString stringForStdString:candidate->server_url()];
  return rtcCandidate;
}

- (std::unique_ptr<webrtc::IceCandidateInterface>)nativeCandidate {
  webrtc::SdpParseError error;

  webrtc::IceCandidateInterface *candidate = webrtc::CreateIceCandidate(
      _sdpMid.stdString, _sdpMLineIndex, _sdp.stdString, &error);

  if (!candidate) {
    SLRRTCLog(@"Failed to create ICE candidate: %s\nline: %s",
           error.description.c_str(),
           error.line.c_str());
  }

  return std::unique_ptr<webrtc::IceCandidateInterface>(candidate);
}

@end
