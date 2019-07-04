/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCRtpReceiver.h"

#include "api/rtp_receiver_interface.h"

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCPeerConnectionFactory;

namespace webrtc {

class RtpReceiverDelegateAdapter : public RtpReceiverObserverInterface {
 public:
  RtpReceiverDelegateAdapter(SLRRTCRtpReceiver* receiver);

  void OnFirstPacketReceived(cricket::MediaType media_type) override;

 private:
  __weak SLRRTCRtpReceiver* receiver_;
};

}  // namespace webrtc

@interface SLRRTCRtpReceiver ()

@property(nonatomic, readonly) rtc::scoped_refptr<webrtc::RtpReceiverInterface> nativeRtpReceiver;

/** Initialize an SLRRTCRtpReceiver with a native RtpReceiverInterface. */
- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory*)factory
              nativeRtpReceiver:(rtc::scoped_refptr<webrtc::RtpReceiverInterface>)nativeRtpReceiver
    NS_DESIGNATED_INITIALIZER;

+ (SLRRTCRtpMediaType)mediaTypeForNativeMediaType:(cricket::MediaType)nativeMediaType;

+ (cricket::MediaType)nativeMediaTypeForMediaType:(SLRRTCRtpMediaType)mediaType;

+ (NSString*)stringForMediaType:(SLRRTCRtpMediaType)mediaType;

@end

NS_ASSUME_NONNULL_END
