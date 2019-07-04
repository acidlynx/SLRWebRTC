/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCConfiguration.h"

#include "api/peer_connection_interface.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLRRTCConfiguration ()

+ (webrtc::PeerConnectionInterface::IceTransportsType)nativeTransportsTypeForTransportPolicy:
        (SLRRTCIceTransportPolicy)policy;

+ (SLRRTCIceTransportPolicy)transportPolicyForTransportsType:
        (webrtc::PeerConnectionInterface::IceTransportsType)nativeType;

+ (NSString *)stringForTransportPolicy:(SLRRTCIceTransportPolicy)policy;

+ (webrtc::PeerConnectionInterface::BundlePolicy)nativeBundlePolicyForPolicy:
        (SLRRTCBundlePolicy)policy;

+ (SLRRTCBundlePolicy)bundlePolicyForNativePolicy:
        (webrtc::PeerConnectionInterface::BundlePolicy)nativePolicy;

+ (NSString *)stringForBundlePolicy:(SLRRTCBundlePolicy)policy;

+ (webrtc::PeerConnectionInterface::RtcpMuxPolicy)nativeRtcpMuxPolicyForPolicy:
        (SLRRTCRtcpMuxPolicy)policy;

+ (SLRRTCRtcpMuxPolicy)rtcpMuxPolicyForNativePolicy:
        (webrtc::PeerConnectionInterface::RtcpMuxPolicy)nativePolicy;

+ (NSString *)stringForRtcpMuxPolicy:(SLRRTCRtcpMuxPolicy)policy;

+ (webrtc::PeerConnectionInterface::TcpCandidatePolicy)nativeTcpCandidatePolicyForPolicy:
        (SLRRTCTcpCandidatePolicy)policy;

+ (SLRRTCTcpCandidatePolicy)tcpCandidatePolicyForNativePolicy:
        (webrtc::PeerConnectionInterface::TcpCandidatePolicy)nativePolicy;

+ (NSString *)stringForTcpCandidatePolicy:(SLRRTCTcpCandidatePolicy)policy;

+ (webrtc::PeerConnectionInterface::CandidateNetworkPolicy)nativeCandidateNetworkPolicyForPolicy:
        (SLRRTCCandidateNetworkPolicy)policy;

+ (SLRRTCCandidateNetworkPolicy)candidateNetworkPolicyForNativePolicy:
        (webrtc::PeerConnectionInterface::CandidateNetworkPolicy)nativePolicy;

+ (NSString *)stringForCandidateNetworkPolicy:(SLRRTCCandidateNetworkPolicy)policy;

+ (rtc::KeyType)nativeEncryptionKeyTypeForKeyType:(SLRRTCEncryptionKeyType)keyType;

+ (webrtc::SdpSemantics)nativeSdpSemanticsForSdpSemantics:(SLRRTCSdpSemantics)sdpSemantics;

+ (SLRRTCSdpSemantics)sdpSemanticsForNativeSdpSemantics:(webrtc::SdpSemantics)sdpSemantics;

+ (NSString *)stringForSdpSemantics:(SLRRTCSdpSemantics)sdpSemantics;

/**
 * SLRRTCConfiguration struct representation of this SLRRTCConfiguration. This is
 * needed to pass to the underlying C++ APIs.
 */
- (nullable webrtc::PeerConnectionInterface::RTCConfiguration *)createNativeConfiguration;

- (instancetype)initWithNativeConfiguration:
        (const webrtc::PeerConnectionInterface::RTCConfiguration &)config NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
