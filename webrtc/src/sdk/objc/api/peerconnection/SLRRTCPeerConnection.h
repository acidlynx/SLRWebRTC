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

#import "SLRRTCMacros.h"

@class SLRRTCConfiguration;
@class SLRRTCDataChannel;
@class SLRRTCDataChannelConfiguration;
@class SLRRTCIceCandidate;
@class SLRRTCMediaConstraints;
@class SLRRTCMediaStream;
@class SLRRTCMediaStreamTrack;
@class SLRRTCPeerConnectionFactory;
@class SLRRTCRtpReceiver;
@class SLRRTCRtpSender;
@class SLRRTCRtpTransceiver;
@class SLRRTCRtpTransceiverInit;
@class SLRRTCSessionDescription;
@class SLRRTCStatisticsReport;
@class SLRRTCLegacyStatsReport;

typedef NS_ENUM(NSInteger, SLRRTCRtpMediaType);

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kRTCPeerConnectionErrorDomain;
extern int const kRTCSessionDescriptionErrorCode;

/** Represents the signaling state of the peer connection. */
typedef NS_ENUM(NSInteger, SLRRTCSignalingState) {
  SLRRTCSignalingStateStable,
  SLRRTCSignalingStateHaveLocalOffer,
  SLRRTCSignalingStateHaveLocalPrAnswer,
  SLRRTCSignalingStateHaveRemoteOffer,
  SLRRTCSignalingStateHaveRemotePrAnswer,
  // Not an actual state, represents the total number of states.
  SLRRTCSignalingStateClosed,
};

/** Represents the ice connection state of the peer connection. */
typedef NS_ENUM(NSInteger, SLRRTCIceConnectionState) {
  SLRRTCIceConnectionStateNew,
  SLRRTCIceConnectionStateChecking,
  SLRRTCIceConnectionStateConnected,
  SLRRTCIceConnectionStateCompleted,
  SLRRTCIceConnectionStateFailed,
  SLRRTCIceConnectionStateDisconnected,
  SLRRTCIceConnectionStateClosed,
  SLRRTCIceConnectionStateCount,
};

/** Represents the combined ice+dtls connection state of the peer connection. */
typedef NS_ENUM(NSInteger, SLRRTCPeerConnectionState) {
  SLRRTCPeerConnectionStateNew,
  SLRRTCPeerConnectionStateConnecting,
  SLRRTCPeerConnectionStateConnected,
  SLRRTCPeerConnectionStateDisconnected,
  SLRRTCPeerConnectionStateFailed,
  SLRRTCPeerConnectionStateClosed,
};

/** Represents the ice gathering state of the peer connection. */
typedef NS_ENUM(NSInteger, SLRRTCIceGatheringState) {
  SLRRTCIceGatheringStateNew,
  SLRRTCIceGatheringStateGathering,
  SLRRTCIceGatheringStateComplete,
};

/** Represents the stats output level. */
typedef NS_ENUM(NSInteger, SLRRTCStatsOutputLevel) {
  SLRRTCStatsOutputLevelStandard,
  SLRRTCStatsOutputLevelDebug,
};

@class SLRRTCPeerConnection;

RTC_OBJC_EXPORT
@protocol SLRRTCPeerConnectionDelegate <NSObject>

/** Called when the SignalingState changed. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didChangeSignalingState:(SLRRTCSignalingState)stateChanged;

/** Called when media is received on a new stream from remote peer. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection didAddStream:(SLRRTCMediaStream *)stream;

/** Called when a remote peer closes a stream.
 *  This is not called when SLRRTCSdpSemanticsUnifiedPlan is specified.
 */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection didRemoveStream:(SLRRTCMediaStream *)stream;

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(SLRRTCPeerConnection *)peerConnection;

/** Called any time the IceConnectionState changes. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didChangeIceConnectionState:(SLRRTCIceConnectionState)newState;

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didChangeIceGatheringState:(SLRRTCIceGatheringState)newState;

/** New ice candidate has been found. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didGenerateIceCandidate:(SLRRTCIceCandidate *)candidate;

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didRemoveIceCandidates:(NSArray<SLRRTCIceCandidate *> *)candidates;

/** New data channel has been opened. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didOpenDataChannel:(SLRRTCDataChannel *)dataChannel;

/** Called when signaling indicates a transceiver will be receiving media from
 *  the remote endpoint.
 *  This is only called with SLRRTCSdpSemanticsUnifiedPlan specified.
 */
@optional
/** Called any time the PeerConnectionState changes. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didChangeConnectionState:(SLRRTCPeerConnectionState)newState;

- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
    didStartReceivingOnTransceiver:(SLRRTCRtpTransceiver *)transceiver;

/** Called when a receiver and its track are created. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
        didAddReceiver:(SLRRTCRtpReceiver *)rtpReceiver
               streams:(NSArray<SLRRTCMediaStream *> *)mediaStreams;

/** Called when the receiver and its track are removed. */
- (void)peerConnection:(SLRRTCPeerConnection *)peerConnection
     didRemoveReceiver:(SLRRTCRtpReceiver *)rtpReceiver;

@end

RTC_OBJC_EXPORT
@interface SLRRTCPeerConnection : NSObject

/** The object that will be notifed about events such as state changes and
 *  streams being added or removed.
 */
@property(nonatomic, weak, nullable) id<SLRRTCPeerConnectionDelegate> delegate;
/** This property is not available with SLRRTCSdpSemanticsUnifiedPlan. Please use
 *  |senders| instead.
 */
@property(nonatomic, readonly) NSArray<SLRRTCMediaStream *> *localStreams;
@property(nonatomic, readonly, nullable) SLRRTCSessionDescription *localDescription;
@property(nonatomic, readonly, nullable) SLRRTCSessionDescription *remoteDescription;
@property(nonatomic, readonly) SLRRTCSignalingState signalingState;
@property(nonatomic, readonly) SLRRTCIceConnectionState iceConnectionState;
@property(nonatomic, readonly) SLRRTCPeerConnectionState connectionState;
@property(nonatomic, readonly) SLRRTCIceGatheringState iceGatheringState;
@property(nonatomic, readonly, copy) SLRRTCConfiguration *configuration;

/** Gets all SLRRTCRtpSenders associated with this peer connection.
 *  Note: reading this property returns different instances of SLRRTCRtpSender.
 *  Use isEqual: instead of == to compare SLRRTCRtpSender instances.
 */
@property(nonatomic, readonly) NSArray<SLRRTCRtpSender *> *senders;

/** Gets all SLRRTCRtpReceivers associated with this peer connection.
 *  Note: reading this property returns different instances of SLRRTCRtpReceiver.
 *  Use isEqual: instead of == to compare SLRRTCRtpReceiver instances.
 */
@property(nonatomic, readonly) NSArray<SLRRTCRtpReceiver *> *receivers;

/** Gets all SLRRTCRtpTransceivers associated with this peer connection.
 *  Note: reading this property returns different instances of
 *  SLRRTCRtpTransceiver. Use isEqual: instead of == to compare SLRRTCRtpTransceiver
 *  instances.
 *  This is only available with SLRRTCSdpSemanticsUnifiedPlan specified.
 */
@property(nonatomic, readonly) NSArray<SLRRTCRtpTransceiver *> *transceivers;

- (instancetype)init NS_UNAVAILABLE;

/** Sets the PeerConnection's global configuration to |configuration|.
 *  Any changes to STUN/TURN servers or ICE candidate policy will affect the
 *  next gathering phase, and cause the next call to createOffer to generate
 *  new ICE credentials. Note that the BUNDLE and SLRRTCP-multiplexing policies
 *  cannot be changed with this method.
 */
- (BOOL)setConfiguration:(SLRRTCConfiguration *)configuration;

/** Terminate all media and close the transport. */
- (void)close;

/** Provide a remote candidate to the ICE Agent. */
- (void)addIceCandidate:(SLRRTCIceCandidate *)candidate;

/** Remove a group of remote candidates from the ICE Agent. */
- (void)removeIceCandidates:(NSArray<SLRRTCIceCandidate *> *)candidates;

/** Add a new media stream to be sent on this peer connection.
 *  This method is not supported with SLRRTCSdpSemanticsUnifiedPlan. Please use
 *  addTrack instead.
 */
- (void)addStream:(SLRRTCMediaStream *)stream;

/** Remove the given media stream from this peer connection.
 *  This method is not supported with SLRRTCSdpSemanticsUnifiedPlan. Please use
 *  removeTrack instead.
 */
- (void)removeStream:(SLRRTCMediaStream *)stream;

/** Add a new media stream track to be sent on this peer connection, and return
 *  the newly created SLRRTCRtpSender. The SLRRTCRtpSender will be associated with
 *  the streams specified in the |streamIds| list.
 *
 *  Errors: If an error occurs, returns nil. An error can occur if:
 *  - A sender already exists for the track.
 *  - The peer connection is closed.
 */
- (SLRRTCRtpSender *)addTrack:(SLRRTCMediaStreamTrack *)track streamIds:(NSArray<NSString *> *)streamIds;

/** With PlanB semantics, removes an SLRRTCRtpSender from this peer connection.
 *
 *  With UnifiedPlan semantics, sets sender's track to null and removes the
 *  send component from the associated SLRRTCRtpTransceiver's direction.
 *
 *  Returns YES on success.
 */
- (BOOL)removeTrack:(SLRRTCRtpSender *)sender;

/** addTransceiver creates a new SLRRTCRtpTransceiver and adds it to the set of
 *  transceivers. Adding a transceiver will cause future calls to CreateOffer
 *  to add a media description for the corresponding transceiver.
 *
 *  The initial value of |mid| in the returned transceiver is nil. Setting a
 *  new session description may change it to a non-nil value.
 *
 *  https://w3c.github.io/webrtc-pc/#dom-rtcpeerconnection-addtransceiver
 *
 *  Optionally, an RtpTransceiverInit structure can be specified to configure
 *  the transceiver from construction. If not specified, the transceiver will
 *  default to having a direction of kSendRecv and not be part of any streams.
 *
 *  These methods are only available when Unified Plan is enabled (see
 *  SLRRTCConfiguration).
 */

/** Adds a transceiver with a sender set to transmit the given track. The kind
 *  of the transceiver (and sender/receiver) will be derived from the kind of
 *  the track.
 */
- (SLRRTCRtpTransceiver *)addTransceiverWithTrack:(SLRRTCMediaStreamTrack *)track;
- (SLRRTCRtpTransceiver *)addTransceiverWithTrack:(SLRRTCMediaStreamTrack *)track
                                          init:(SLRRTCRtpTransceiverInit *)init;

/** Adds a transceiver with the given kind. Can either be SLRRTCRtpMediaTypeAudio
 *  or SLRRTCRtpMediaTypeVideo.
 */
- (SLRRTCRtpTransceiver *)addTransceiverOfType:(SLRRTCRtpMediaType)mediaType;
- (SLRRTCRtpTransceiver *)addTransceiverOfType:(SLRRTCRtpMediaType)mediaType
                                       init:(SLRRTCRtpTransceiverInit *)init;

/** Generate an SDP offer. */
- (void)offerForConstraints:(SLRRTCMediaConstraints *)constraints
          completionHandler:(nullable void (^)(SLRRTCSessionDescription *_Nullable sdp,
                                               NSError *_Nullable error))completionHandler;

/** Generate an SDP answer. */
- (void)answerForConstraints:(SLRRTCMediaConstraints *)constraints
           completionHandler:(nullable void (^)(SLRRTCSessionDescription *_Nullable sdp,
                                                NSError *_Nullable error))completionHandler;

/** Apply the supplied SLRRTCSessionDescription as the local description. */
- (void)setLocalDescription:(SLRRTCSessionDescription *)sdp
          completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

/** Apply the supplied SLRRTCSessionDescription as the remote description. */
- (void)setRemoteDescription:(SLRRTCSessionDescription *)sdp
           completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

/** Limits the bandwidth allocated for all RTP streams sent by this
 *  PeerConnection. Nil parameters will be unchanged. Setting
 * |currentBitrateBps| will force the available bitrate estimate to the given
 *  value. Returns YES if the parameters were successfully updated.
 */
- (BOOL)setBweMinBitrateBps:(nullable NSNumber *)minBitrateBps
          currentBitrateBps:(nullable NSNumber *)currentBitrateBps
              maxBitrateBps:(nullable NSNumber *)maxBitrateBps;

/** Start or stop recording an Rtc EventLog. */
- (BOOL)startRtcEventLogWithFilePath:(NSString *)filePath maxSizeInBytes:(int64_t)maxSizeInBytes;
- (void)stopRtcEventLog;

@end

@interface SLRRTCPeerConnection (Media)

/** Create an SLRRTCRtpSender with the specified kind and media stream ID.
 *  See SLRRTCMediaStreamTrack.h for available kinds.
 *  This method is not supported with SLRRTCSdpSemanticsUnifiedPlan. Please use
 *  addTransceiver instead.
 */
- (SLRRTCRtpSender *)senderWithKind:(NSString *)kind streamId:(NSString *)streamId;

@end

@interface SLRRTCPeerConnection (DataChannel)

/** Create a new data channel with the given label and configuration. */
- (nullable SLRRTCDataChannel *)dataChannelForLabel:(NSString *)label
                                   configuration:(SLRRTCDataChannelConfiguration *)configuration;

@end

typedef void (^SLRRTCStatisticsCompletionHandler)(SLRRTCStatisticsReport *);

@interface SLRRTCPeerConnection (Stats)

/** Gather stats for the given SLRRTCMediaStreamTrack. If |mediaStreamTrack| is nil
 *  statistics are gathered for all tracks.
 */
- (void)statsForTrack:(nullable SLRRTCMediaStreamTrack *)mediaStreamTrack
     statsOutputLevel:(SLRRTCStatsOutputLevel)statsOutputLevel
    completionHandler:(nullable void (^)(NSArray<SLRRTCLegacyStatsReport *> *stats))completionHandler;

/** Gather statistic through the v2 statistics API. */
- (void)statisticsWithCompletionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler;

/** Spec-compliant getStats() performing the stats selection algorithm with the
 *  sender.
 */
- (void)statisticsForSender:(SLRRTCRtpSender *)sender
          completionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler;

/** Spec-compliant getStats() performing the stats selection algorithm with the
 *  receiver.
 */
- (void)statisticsForReceiver:(SLRRTCRtpReceiver *)receiver
            completionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
