/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCPeerConnection+Private.h"

#import "SLRRTCDataChannel+Private.h"
#import "SLRRTCDataChannelConfiguration+Private.h"
#import "helpers/NSString+StdString.h"

@implementation SLRRTCPeerConnection (DataChannel)

- (nullable SLRRTCDataChannel *)dataChannelForLabel:(NSString *)label
                                   configuration:(SLRRTCDataChannelConfiguration *)configuration {
  std::string labelString = [NSString stdStringForString:label];
  const webrtc::DataChannelInit nativeInit =
      configuration.nativeDataChannelInit;
  rtc::scoped_refptr<webrtc::DataChannelInterface> dataChannel =
      self.nativePeerConnection->CreateDataChannel(labelString,
                                                   &nativeInit);
  if (!dataChannel) {
    return nil;
  }
  return [[SLRRTCDataChannel alloc] initWithFactory:self.factory nativeDataChannel:dataChannel];
}

@end
