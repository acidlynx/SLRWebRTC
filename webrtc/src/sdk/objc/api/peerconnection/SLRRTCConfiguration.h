/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "SLRRTCCertificate.h"
#import "SLRRTCCryptoOptions.h"
#import "SLRRTCMacros.h"

@class SLRRTCIceServer;
@class SLRRTCIntervalRange;

/**
 * Represents the ice transport policy. This exposes the same states in C++,
 * which include one more state than what exists in the W3C spec.
 */
typedef NS_ENUM(NSInteger, SLRRTCIceTransportPolicy) {
  SLRRTCIceTransportPolicyNone,
  SLRRTCIceTransportPolicyRelay,
  SLRRTCIceTransportPolicyNoHost,
  SLRRTCIceTransportPolicyAll
};

/** Represents the bundle policy. */
typedef NS_ENUM(NSInteger, SLRRTCBundlePolicy) {
  SLRRTCBundlePolicyBalanced,
  SLRRTCBundlePolicyMaxCompat,
  SLRRTCBundlePolicyMaxBundle
};

/** Represents the rtcp mux policy. */
typedef NS_ENUM(NSInteger, SLRRTCRtcpMuxPolicy) { SLRRTCRtcpMuxPolicyNegotiate, SLRRTCRtcpMuxPolicyRequire };

/** Represents the tcp candidate policy. */
typedef NS_ENUM(NSInteger, SLRRTCTcpCandidatePolicy) {
  SLRRTCTcpCandidatePolicyEnabled,
  SLRRTCTcpCandidatePolicyDisabled
};

/** Represents the candidate network policy. */
typedef NS_ENUM(NSInteger, SLRRTCCandidateNetworkPolicy) {
  SLRRTCCandidateNetworkPolicyAll,
  SLRRTCCandidateNetworkPolicyLowCost
};

/** Represents the continual gathering policy. */
typedef NS_ENUM(NSInteger, SLRRTCContinualGatheringPolicy) {
  SLRRTCContinualGatheringPolicyGatherOnce,
  SLRRTCContinualGatheringPolicyGatherContinually
};

/** Represents the encryption key type. */
typedef NS_ENUM(NSInteger, SLRRTCEncryptionKeyType) {
  SLRRTCEncryptionKeyTypeRSA,
  SLRRTCEncryptionKeyTypeECDSA,
};

/** Represents the chosen SDP semantics for the SLRRTCPeerConnection. */
typedef NS_ENUM(NSInteger, SLRRTCSdpSemantics) {
  SLRRTCSdpSemanticsPlanB,
  SLRRTCSdpSemanticsUnifiedPlan,
};

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface SLRRTCConfiguration : NSObject

/** An array of Ice Servers available to be used by ICE. */
@property(nonatomic, copy) NSArray<SLRRTCIceServer *> *iceServers;

/** An SLRRTCCertificate for 're' use. */
@property(nonatomic, nullable) SLRRTCCertificate *certificate;

/** Which candidates the ICE agent is allowed to use. The W3C calls it
 * |iceTransportPolicy|, while in C++ it is called |type|. */
@property(nonatomic, assign) SLRRTCIceTransportPolicy iceTransportPolicy;

/** The media-bundling policy to use when gathering ICE candidates. */
@property(nonatomic, assign) SLRRTCBundlePolicy bundlePolicy;

/** The rtcp-mux policy to use when gathering ICE candidates. */
@property(nonatomic, assign) SLRRTCRtcpMuxPolicy rtcpMuxPolicy;
@property(nonatomic, assign) SLRRTCTcpCandidatePolicy tcpCandidatePolicy;
@property(nonatomic, assign) SLRRTCCandidateNetworkPolicy candidateNetworkPolicy;
@property(nonatomic, assign) SLRRTCContinualGatheringPolicy continualGatheringPolicy;

/** If set to YES, don't gather IPv6 ICE candidates.
 *  Default is NO.
 */
@property(nonatomic, assign) BOOL disableIPV6;

/** If set to YES, don't gather IPv6 ICE candidates on Wi-Fi.
 *  Only intended to be used on specific devices. Certain phones disable IPv6
 *  when the screen is turned off and it would be better to just disable the
 *  IPv6 ICE candidates on Wi-Fi in those cases.
 *  Default is NO.
 */
@property(nonatomic, assign) BOOL disableIPV6OnWiFi;

/** By default, the PeerConnection will use a limited number of IPv6 network
 *  interfaces, in order to avoid too many ICE candidate pairs being created
 *  and delaying ICE completion.
 *
 *  Can be set to INT_MAX to effectively disable the limit.
 */
@property(nonatomic, assign) int maxIPv6Networks;

/** Exclude link-local network interfaces
 *  from considertaion for gathering ICE candidates.
 *  Defaults to NO.
 */
@property(nonatomic, assign) BOOL disableLinkLocalNetworks;

@property(nonatomic, assign) int audioJitterBufferMaxPackets;
@property(nonatomic, assign) BOOL audioJitterBufferFastAccelerate;
@property(nonatomic, assign) int iceConnectionReceivingTimeout;
@property(nonatomic, assign) int iceBackupCandidatePairPingInterval;

/** Key type used to generate SSL identity. Default is ECDSA. */
@property(nonatomic, assign) SLRRTCEncryptionKeyType keyType;

/** ICE candidate pool size as defined in JSEP. Default is 0. */
@property(nonatomic, assign) int iceCandidatePoolSize;

/** Prune turn ports on the same network to the same turn server.
 *  Default is NO.
 */
@property(nonatomic, assign) BOOL shouldPruneTurnPorts;

/** If set to YES, this means the ICE transport should presume TURN-to-TURN
 *  candidate pairs will succeed, even before a binding response is received.
 */
@property(nonatomic, assign) BOOL shouldPresumeWritableWhenFullyRelayed;

/** If set to non-nil, controls the minimal interval between consecutive ICE
 *  check packets.
 */
@property(nonatomic, copy, nullable) NSNumber *iceCheckMinInterval;

/** ICE Periodic Regathering
 *  If set, WebRTC will periodically create and propose candidates without
 *  starting a new ICE generation. The regathering happens continuously with
 *  interval specified in milliseconds by the uniform distribution [a, b].
 */
@property(nonatomic, strong, nullable) SLRRTCIntervalRange *iceRegatherIntervalRange;

/** Configure the SDP semantics used by this PeerConnection. Note that the
 *  WebRTC 1.0 specification requires UnifiedPlan semantics. The
 *  SLRRTCRtpTransceiver API is only available with UnifiedPlan semantics.
 *
 *  PlanB will cause SLRRTCPeerConnection to create offers and answers with at
 *  most one audio and one video m= section with multiple SLRRTCRtpSenders and
 *  SLRRTCRtpReceivers specified as multiple a=ssrc lines within the section. This
 *  will also cause SLRRTCPeerConnection to ignore all but the first m= section of
 *  the same media type.
 *
 *  UnifiedPlan will cause SLRRTCPeerConnection to create offers and answers with
 *  multiple m= sections where each m= section maps to one SLRRTCRtpSender and one
 *  SLRRTCRtpReceiver (an SLRRTCRtpTransceiver), either both audio or both video. This
 *  will also cause SLRRTCPeerConnection to ignore all but the first a=ssrc lines
 *  that form a Plan B stream.
 *
 *  For users who wish to send multiple audio/video streams and need to stay
 *  interoperable with legacy WebRTC implementations or use legacy APIs,
 *  specify PlanB.
 *
 *  For all other users, specify UnifiedPlan.
 */
@property(nonatomic, assign) SLRRTCSdpSemantics sdpSemantics;

/** Actively reset the SRTP parameters when the DTLS transports underneath are
 *  changed after offer/answer negotiation. This is only intended to be a
 *  workaround for crbug.com/835958
 */
@property(nonatomic, assign) BOOL activeResetSrtpParams;

/**
 * If MediaTransportFactory is provided in PeerConnectionFactory, this flag informs PeerConnection
 * that it should use the MediaTransportInterface.
 */
@property(nonatomic, assign) BOOL useMediaTransport;

/**
 * If MediaTransportFactory is provided in PeerConnectionFactory, this flag informs PeerConnection
 * that it should use the MediaTransportInterface for data channels.
 */
@property(nonatomic, assign) BOOL useMediaTransportForDataChannels;

/**
 * Defines advanced optional cryptographic settings related to SRTP and
 * frame encryption for native WebRTC. Setting this will overwrite any
 * options set through the PeerConnectionFactory (which is deprecated).
 */
@property(nonatomic, nullable) SLRRTCCryptoOptions *cryptoOptions;

/**
 * Time interval between audio SLRRTCP reports.
 */
@property(nonatomic, assign) int rtcpAudioReportIntervalMs;

/**
 * Time interval between video SLRRTCP reports.
 */
@property(nonatomic, assign) int rtcpVideoReportIntervalMs;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
