/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCPeerConnection.h"

#include "api/peer_connection_interface.h"

NS_ASSUME_NONNULL_BEGIN

namespace webrtc {

/**
 * These objects are created by SLRRTCPeerConnectionFactory to wrap an
 * id<SLRRTCPeerConnectionDelegate> and call methods on that interface.
 */
class PeerConnectionDelegateAdapter : public PeerConnectionObserver {
 public:
  PeerConnectionDelegateAdapter(SLRRTCPeerConnection *peerConnection);
  ~PeerConnectionDelegateAdapter() override;

  void OnSignalingChange(PeerConnectionInterface::SignalingState new_state) override;

  void OnAddStream(rtc::scoped_refptr<MediaStreamInterface> stream) override;

  void OnRemoveStream(rtc::scoped_refptr<MediaStreamInterface> stream) override;

  void OnTrack(rtc::scoped_refptr<RtpTransceiverInterface> transceiver) override;

  void OnDataChannel(rtc::scoped_refptr<DataChannelInterface> data_channel) override;

  void OnRenegotiationNeeded() override;

  void OnIceConnectionChange(PeerConnectionInterface::IceConnectionState new_state) override;

  void OnConnectionChange(PeerConnectionInterface::PeerConnectionState new_state) override;

  void OnIceGatheringChange(PeerConnectionInterface::IceGatheringState new_state) override;

  void OnIceCandidate(const IceCandidateInterface *candidate) override;

  void OnIceCandidatesRemoved(const std::vector<cricket::Candidate> &candidates) override;

  void OnAddTrack(rtc::scoped_refptr<RtpReceiverInterface> receiver,
                  const std::vector<rtc::scoped_refptr<MediaStreamInterface>> &streams) override;

  void OnRemoveTrack(rtc::scoped_refptr<RtpReceiverInterface> receiver) override;

 private:
  __weak SLRRTCPeerConnection *peer_connection_;
};

}  // namespace webrtc

@interface SLRRTCPeerConnection ()

/** The factory used to create this SLRRTCPeerConnection */
@property(nonatomic, readonly) SLRRTCPeerConnectionFactory *factory;

/** The native PeerConnectionInterface created during construction. */
@property(nonatomic, readonly) rtc::scoped_refptr<webrtc::PeerConnectionInterface>
    nativePeerConnection;

/** Initialize an SLRRTCPeerConnection with a configuration, constraints, and
 *  delegate.
 */
- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                  configuration:(SLRRTCConfiguration *)configuration
                    constraints:(SLRRTCMediaConstraints *)constraints
                       delegate:(nullable id<SLRRTCPeerConnectionDelegate>)delegate
    NS_DESIGNATED_INITIALIZER;

+ (webrtc::PeerConnectionInterface::SignalingState)nativeSignalingStateForState:
        (SLRRTCSignalingState)state;

+ (SLRRTCSignalingState)signalingStateForNativeState:
        (webrtc::PeerConnectionInterface::SignalingState)nativeState;

+ (NSString *)stringForSignalingState:(SLRRTCSignalingState)state;

+ (webrtc::PeerConnectionInterface::IceConnectionState)nativeIceConnectionStateForState:
        (SLRRTCIceConnectionState)state;

+ (webrtc::PeerConnectionInterface::PeerConnectionState)nativeConnectionStateForState:
        (SLRRTCPeerConnectionState)state;

+ (SLRRTCIceConnectionState)iceConnectionStateForNativeState:
        (webrtc::PeerConnectionInterface::IceConnectionState)nativeState;

+ (SLRRTCPeerConnectionState)connectionStateForNativeState:
        (webrtc::PeerConnectionInterface::PeerConnectionState)nativeState;

+ (NSString *)stringForIceConnectionState:(SLRRTCIceConnectionState)state;

+ (NSString *)stringForConnectionState:(SLRRTCPeerConnectionState)state;

+ (webrtc::PeerConnectionInterface::IceGatheringState)nativeIceGatheringStateForState:
        (SLRRTCIceGatheringState)state;

+ (SLRRTCIceGatheringState)iceGatheringStateForNativeState:
        (webrtc::PeerConnectionInterface::IceGatheringState)nativeState;

+ (NSString *)stringForIceGatheringState:(SLRRTCIceGatheringState)state;

+ (webrtc::PeerConnectionInterface::StatsOutputLevel)nativeStatsOutputLevelForLevel:
        (SLRRTCStatsOutputLevel)level;

@end

NS_ASSUME_NONNULL_END
