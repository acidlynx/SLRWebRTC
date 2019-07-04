/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCSessionDescription+Private.h"

#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

#include "rtc_base/checks.h"

@implementation SLRRTCSessionDescription

@synthesize type = _type;
@synthesize sdp = _sdp;

+ (NSString *)stringForType:(SLRRTCSdpType)type {
  std::string string = [[self class] stdStringForType:type];
  return [NSString stringForStdString:string];
}

+ (SLRRTCSdpType)typeForString:(NSString *)string {
  std::string typeString = string.stdString;
  return [[self class] typeForStdString:typeString];
}

- (instancetype)initWithType:(SLRRTCSdpType)type sdp:(NSString *)sdp {
  NSParameterAssert(sdp.length);
  if (self = [super init]) {
    _type = type;
    _sdp = [sdp copy];
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCSessionDescription:\n%@\n%@",
                                    [[self class] stringForType:_type],
                                    _sdp];
}

#pragma mark - Private

- (webrtc::SessionDescriptionInterface *)nativeDescription {
  webrtc::SdpParseError error;

  webrtc::SessionDescriptionInterface *description =
      webrtc::CreateSessionDescription([[self class] stdStringForType:_type],
                                       _sdp.stdString,
                                       &error);

  if (!description) {
    SLRRTCLogError(@"Failed to create session description: %s\nline: %s",
                error.description.c_str(),
                error.line.c_str());
  }

  return description;
}

- (instancetype)initWithNativeDescription:
    (const webrtc::SessionDescriptionInterface *)nativeDescription {
  NSParameterAssert(nativeDescription);
  std::string sdp;
  nativeDescription->ToString(&sdp);
  SLRRTCSdpType type = [[self class] typeForStdString:nativeDescription->type()];

  return [self initWithType:type
                        sdp:[NSString stringForStdString:sdp]];
}

+ (std::string)stdStringForType:(SLRRTCSdpType)type {
  switch (type) {
    case SLRRTCSdpTypeOffer:
      return webrtc::SessionDescriptionInterface::kOffer;
    case SLRRTCSdpTypePrAnswer:
      return webrtc::SessionDescriptionInterface::kPrAnswer;
    case SLRRTCSdpTypeAnswer:
      return webrtc::SessionDescriptionInterface::kAnswer;
  }
}

+ (SLRRTCSdpType)typeForStdString:(const std::string &)string {
  if (string == webrtc::SessionDescriptionInterface::kOffer) {
    return SLRRTCSdpTypeOffer;
  } else if (string == webrtc::SessionDescriptionInterface::kPrAnswer) {
    return SLRRTCSdpTypePrAnswer;
  } else if (string == webrtc::SessionDescriptionInterface::kAnswer) {
    return SLRRTCSdpTypeAnswer;
  } else {
    RTC_NOTREACHED();
    return SLRRTCSdpTypeOffer;
  }
}

@end
