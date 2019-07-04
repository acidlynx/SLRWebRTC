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

#import "SLRRTCConfiguration+Private.h"
#import "SLRRTCDataChannel+Private.h"
#import "SLRRTCIceCandidate+Private.h"
#import "SLRRTCLegacyStatsReport+Private.h"
#import "SLRRTCMediaConstraints+Private.h"
#import "SLRRTCMediaStream+Private.h"
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCPeerConnection+Native.h"
#import "SLRRTCPeerConnectionFactory+Private.h"
#import "SLRRTCRtpReceiver+Private.h"
#import "SLRRTCRtpSender+Private.h"
#import "SLRRTCRtpTransceiver+Private.h"
#import "SLRRTCSessionDescription+Private.h"
#import "base/SLRRTCLogging.h"
#import "helpers/NSString+StdString.h"

#include <memory>

#include "api/jsep_ice_candidate.h"
#include "api/media_transport_interface.h"
#include "rtc_base/checks.h"

NSString * const kRTCPeerConnectionErrorDomain =
    @"org.webrtc.SLRRTCPeerConnection";
int const kRTCPeerConnnectionSessionDescriptionError = -1;

namespace webrtc {

class CreateSessionDescriptionObserverAdapter
    : public CreateSessionDescriptionObserver {
 public:
  CreateSessionDescriptionObserverAdapter(
      void (^completionHandler)(SLRRTCSessionDescription *sessionDescription,
                                NSError *error)) {
    completion_handler_ = completionHandler;
  }

  ~CreateSessionDescriptionObserverAdapter() override { completion_handler_ = nil; }

  void OnSuccess(SessionDescriptionInterface *desc) override {
    RTC_DCHECK(completion_handler_);
    std::unique_ptr<webrtc::SessionDescriptionInterface> description =
        std::unique_ptr<webrtc::SessionDescriptionInterface>(desc);
    SLRRTCSessionDescription* session =
        [[SLRRTCSessionDescription alloc] initWithNativeDescription:
            description.get()];
    completion_handler_(session, nil);
    completion_handler_ = nil;
  }

  void OnFailure(RTCError error) override {
    RTC_DCHECK(completion_handler_);
    // TODO(hta): Add handling of error.type()
    NSString *str = [NSString stringForStdString:error.message()];
    NSError* err =
        [NSError errorWithDomain:kRTCPeerConnectionErrorDomain
                            code:kRTCPeerConnnectionSessionDescriptionError
                        userInfo:@{ NSLocalizedDescriptionKey : str }];
    completion_handler_(nil, err);
    completion_handler_ = nil;
  }

 private:
  void (^completion_handler_)
      (SLRRTCSessionDescription *sessionDescription, NSError *error);
};

class SetSessionDescriptionObserverAdapter :
    public SetSessionDescriptionObserver {
 public:
  SetSessionDescriptionObserverAdapter(void (^completionHandler)
      (NSError *error)) {
    completion_handler_ = completionHandler;
  }

  ~SetSessionDescriptionObserverAdapter() override { completion_handler_ = nil; }

  void OnSuccess() override {
    RTC_DCHECK(completion_handler_);
    completion_handler_(nil);
    completion_handler_ = nil;
  }

  void OnFailure(RTCError error) override {
    RTC_DCHECK(completion_handler_);
    // TODO(hta): Add handling of error.type()
    NSString *str = [NSString stringForStdString:error.message()];
    NSError* err =
        [NSError errorWithDomain:kRTCPeerConnectionErrorDomain
                            code:kRTCPeerConnnectionSessionDescriptionError
                        userInfo:@{ NSLocalizedDescriptionKey : str }];
    completion_handler_(err);
    completion_handler_ = nil;
  }

 private:
  void (^completion_handler_)(NSError *error);
};

PeerConnectionDelegateAdapter::PeerConnectionDelegateAdapter(
    SLRRTCPeerConnection *peerConnection) {
  peer_connection_ = peerConnection;
}

PeerConnectionDelegateAdapter::~PeerConnectionDelegateAdapter() {
  peer_connection_ = nil;
}

void PeerConnectionDelegateAdapter::OnSignalingChange(
    PeerConnectionInterface::SignalingState new_state) {
  SLRRTCSignalingState state =
      [[SLRRTCPeerConnection class] signalingStateForNativeState:new_state];
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  [peer_connection.delegate peerConnection:peer_connection
                   didChangeSignalingState:state];
}

void PeerConnectionDelegateAdapter::OnAddStream(
    rtc::scoped_refptr<MediaStreamInterface> stream) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  SLRRTCMediaStream *mediaStream =
      [[SLRRTCMediaStream alloc] initWithFactory:peer_connection.factory nativeMediaStream:stream];
  [peer_connection.delegate peerConnection:peer_connection
                              didAddStream:mediaStream];
}

void PeerConnectionDelegateAdapter::OnRemoveStream(
    rtc::scoped_refptr<MediaStreamInterface> stream) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  SLRRTCMediaStream *mediaStream =
      [[SLRRTCMediaStream alloc] initWithFactory:peer_connection.factory nativeMediaStream:stream];

  [peer_connection.delegate peerConnection:peer_connection
                           didRemoveStream:mediaStream];
}

void PeerConnectionDelegateAdapter::OnTrack(
    rtc::scoped_refptr<RtpTransceiverInterface> nativeTransceiver) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  SLRRTCRtpTransceiver *transceiver =
      [[SLRRTCRtpTransceiver alloc] initWithFactory:peer_connection.factory
                            nativeRtpTransceiver:nativeTransceiver];
  if ([peer_connection.delegate
          respondsToSelector:@selector(peerConnection:didStartReceivingOnTransceiver:)]) {
    [peer_connection.delegate peerConnection:peer_connection
              didStartReceivingOnTransceiver:transceiver];
  }
}

void PeerConnectionDelegateAdapter::OnDataChannel(
    rtc::scoped_refptr<DataChannelInterface> data_channel) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  SLRRTCDataChannel *dataChannel = [[SLRRTCDataChannel alloc] initWithFactory:peer_connection.factory
                                                      nativeDataChannel:data_channel];
  [peer_connection.delegate peerConnection:peer_connection
                        didOpenDataChannel:dataChannel];
}

void PeerConnectionDelegateAdapter::OnRenegotiationNeeded() {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  [peer_connection.delegate peerConnectionShouldNegotiate:peer_connection];
}

void PeerConnectionDelegateAdapter::OnIceConnectionChange(
    PeerConnectionInterface::IceConnectionState new_state) {
  SLRRTCIceConnectionState state = [SLRRTCPeerConnection iceConnectionStateForNativeState:new_state];
  [peer_connection_.delegate peerConnection:peer_connection_ didChangeIceConnectionState:state];
}

void PeerConnectionDelegateAdapter::OnConnectionChange(
    PeerConnectionInterface::PeerConnectionState new_state) {
  if ([peer_connection_.delegate
          respondsToSelector:@selector(peerConnection:didChangeConnectionState:)]) {
    SLRRTCPeerConnectionState state = [SLRRTCPeerConnection connectionStateForNativeState:new_state];
    [peer_connection_.delegate peerConnection:peer_connection_ didChangeConnectionState:state];
  }
}

void PeerConnectionDelegateAdapter::OnIceGatheringChange(
    PeerConnectionInterface::IceGatheringState new_state) {
  SLRRTCIceGatheringState state =
      [[SLRRTCPeerConnection class] iceGatheringStateForNativeState:new_state];
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  [peer_connection.delegate peerConnection:peer_connection
                didChangeIceGatheringState:state];
}

void PeerConnectionDelegateAdapter::OnIceCandidate(
    const IceCandidateInterface *candidate) {
  SLRRTCIceCandidate *iceCandidate =
      [[SLRRTCIceCandidate alloc] initWithNativeCandidate:candidate];
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  [peer_connection.delegate peerConnection:peer_connection
                   didGenerateIceCandidate:iceCandidate];
}

void PeerConnectionDelegateAdapter::OnIceCandidatesRemoved(
    const std::vector<cricket::Candidate>& candidates) {
  NSMutableArray* ice_candidates =
      [NSMutableArray arrayWithCapacity:candidates.size()];
  for (const auto& candidate : candidates) {
    std::unique_ptr<JsepIceCandidate> candidate_wrapper(
        new JsepIceCandidate(candidate.transport_name(), -1, candidate));
    SLRRTCIceCandidate* ice_candidate = [[SLRRTCIceCandidate alloc]
        initWithNativeCandidate:candidate_wrapper.get()];
    [ice_candidates addObject:ice_candidate];
  }
  SLRRTCPeerConnection* peer_connection = peer_connection_;
  [peer_connection.delegate peerConnection:peer_connection
                    didRemoveIceCandidates:ice_candidates];
}

void PeerConnectionDelegateAdapter::OnAddTrack(
    rtc::scoped_refptr<RtpReceiverInterface> receiver,
    const std::vector<rtc::scoped_refptr<MediaStreamInterface>>& streams) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  if ([peer_connection.delegate
          respondsToSelector:@selector(peerConnection:didAddReceiver:streams:)]) {
    NSMutableArray *mediaStreams = [NSMutableArray arrayWithCapacity:streams.size()];
    for (const auto& nativeStream : streams) {
      SLRRTCMediaStream *mediaStream = [[SLRRTCMediaStream alloc] initWithFactory:peer_connection.factory
                                                          nativeMediaStream:nativeStream];
      [mediaStreams addObject:mediaStream];
    }
    SLRRTCRtpReceiver *rtpReceiver =
        [[SLRRTCRtpReceiver alloc] initWithFactory:peer_connection.factory nativeRtpReceiver:receiver];

    [peer_connection.delegate peerConnection:peer_connection
                              didAddReceiver:rtpReceiver
                                     streams:mediaStreams];
  }
}

void PeerConnectionDelegateAdapter::OnRemoveTrack(
    rtc::scoped_refptr<RtpReceiverInterface> receiver) {
  SLRRTCPeerConnection *peer_connection = peer_connection_;
  if ([peer_connection.delegate respondsToSelector:@selector(peerConnection:didRemoveReceiver:)]) {
    SLRRTCRtpReceiver *rtpReceiver =
        [[SLRRTCRtpReceiver alloc] initWithFactory:peer_connection.factory nativeRtpReceiver:receiver];
    [peer_connection.delegate peerConnection:peer_connection didRemoveReceiver:rtpReceiver];
  }
}

}  // namespace webrtc


@implementation SLRRTCPeerConnection {
  SLRRTCPeerConnectionFactory *_factory;
  NSMutableArray<SLRRTCMediaStream *> *_localStreams;
  std::unique_ptr<webrtc::PeerConnectionDelegateAdapter> _observer;
  rtc::scoped_refptr<webrtc::PeerConnectionInterface> _peerConnection;
  std::unique_ptr<webrtc::MediaConstraints> _nativeConstraints;
  BOOL _hasStartedRtcEventLog;
}

@synthesize delegate = _delegate;
@synthesize factory = _factory;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                  configuration:(SLRRTCConfiguration *)configuration
                    constraints:(SLRRTCMediaConstraints *)constraints
                       delegate:(id<SLRRTCPeerConnectionDelegate>)delegate {
  NSParameterAssert(factory);
  std::unique_ptr<webrtc::PeerConnectionInterface::RTCConfiguration> config(
      [configuration createNativeConfiguration]);
  if (!config) {
    return nil;
  }
  if (self = [super init]) {
    _observer.reset(new webrtc::PeerConnectionDelegateAdapter(self));
    _nativeConstraints = constraints.nativeConstraints;
    CopyConstraintsIntoRtcConfiguration(_nativeConstraints.get(),
                                        config.get());
    _peerConnection =
        factory.nativeFactory->CreatePeerConnection(*config,
                                                    nullptr,
                                                    nullptr,
                                                    _observer.get());
    if (!_peerConnection) {
      return nil;
    }
    _factory = factory;
    _localStreams = [[NSMutableArray alloc] init];
    _delegate = delegate;
  }
  return self;
}

- (NSArray<SLRRTCMediaStream *> *)localStreams {
  return [_localStreams copy];
}

- (SLRRTCSessionDescription *)localDescription {
  const webrtc::SessionDescriptionInterface *description =
      _peerConnection->local_description();
  return description ?
      [[SLRRTCSessionDescription alloc] initWithNativeDescription:description]
          : nil;
}

- (SLRRTCSessionDescription *)remoteDescription {
  const webrtc::SessionDescriptionInterface *description =
      _peerConnection->remote_description();
  return description ?
      [[SLRRTCSessionDescription alloc] initWithNativeDescription:description]
          : nil;
}

- (SLRRTCSignalingState)signalingState {
  return [[self class]
      signalingStateForNativeState:_peerConnection->signaling_state()];
}

- (SLRRTCIceConnectionState)iceConnectionState {
  return [[self class] iceConnectionStateForNativeState:
      _peerConnection->ice_connection_state()];
}

- (SLRRTCPeerConnectionState)connectionState {
  return [[self class] connectionStateForNativeState:_peerConnection->peer_connection_state()];
}

- (SLRRTCIceGatheringState)iceGatheringState {
  return [[self class] iceGatheringStateForNativeState:
      _peerConnection->ice_gathering_state()];
}

- (BOOL)setConfiguration:(SLRRTCConfiguration *)configuration {
  std::unique_ptr<webrtc::PeerConnectionInterface::RTCConfiguration> config(
      [configuration createNativeConfiguration]);
  if (!config) {
    return NO;
  }
  CopyConstraintsIntoRtcConfiguration(_nativeConstraints.get(),
                                      config.get());
  return _peerConnection->SetConfiguration(*config);
}

- (SLRRTCConfiguration *)configuration {
  webrtc::PeerConnectionInterface::RTCConfiguration config =
    _peerConnection->GetConfiguration();
  return [[SLRRTCConfiguration alloc] initWithNativeConfiguration:config];
}

- (void)close {
  _peerConnection->Close();
}

- (void)addIceCandidate:(SLRRTCIceCandidate *)candidate {
  std::unique_ptr<const webrtc::IceCandidateInterface> iceCandidate(
      candidate.nativeCandidate);
  _peerConnection->AddIceCandidate(iceCandidate.get());
}

- (void)removeIceCandidates:(NSArray<SLRRTCIceCandidate *> *)iceCandidates {
  std::vector<cricket::Candidate> candidates;
  for (SLRRTCIceCandidate *iceCandidate in iceCandidates) {
    std::unique_ptr<const webrtc::IceCandidateInterface> candidate(
        iceCandidate.nativeCandidate);
    if (candidate) {
      candidates.push_back(candidate->candidate());
      // Need to fill the transport name from the sdp_mid.
      candidates.back().set_transport_name(candidate->sdp_mid());
    }
  }
  if (!candidates.empty()) {
    _peerConnection->RemoveIceCandidates(candidates);
  }
}

- (void)addStream:(SLRRTCMediaStream *)stream {
  if (!_peerConnection->AddStream(stream.nativeMediaStream)) {
    SLRRTCLogError(@"Failed to add stream: %@", stream);
    return;
  }
  [_localStreams addObject:stream];
}

- (void)removeStream:(SLRRTCMediaStream *)stream {
  _peerConnection->RemoveStream(stream.nativeMediaStream);
  [_localStreams removeObject:stream];
}

- (SLRRTCRtpSender *)addTrack:(SLRRTCMediaStreamTrack *)track streamIds:(NSArray<NSString *> *)streamIds {
  std::vector<std::string> nativeStreamIds;
  for (NSString *streamId in streamIds) {
    nativeStreamIds.push_back([streamId UTF8String]);
  }
  webrtc::RTCErrorOr<rtc::scoped_refptr<webrtc::RtpSenderInterface>> nativeSenderOrError =
      _peerConnection->AddTrack(track.nativeTrack, nativeStreamIds);
  if (!nativeSenderOrError.ok()) {
    SLRRTCLogError(@"Failed to add track %@: %s", track, nativeSenderOrError.error().message());
    return nil;
  }
  return [[SLRRTCRtpSender alloc] initWithFactory:self.factory
                               nativeRtpSender:nativeSenderOrError.MoveValue()];
}

- (BOOL)removeTrack:(SLRRTCRtpSender *)sender {
  bool result = _peerConnection->RemoveTrack(sender.nativeRtpSender);
  if (!result) {
    SLRRTCLogError(@"Failed to remote track %@", sender);
  }
  return result;
}

- (SLRRTCRtpTransceiver *)addTransceiverWithTrack:(SLRRTCMediaStreamTrack *)track {
  return [self addTransceiverWithTrack:track init:[[SLRRTCRtpTransceiverInit alloc] init]];
}

- (SLRRTCRtpTransceiver *)addTransceiverWithTrack:(SLRRTCMediaStreamTrack *)track
                                          init:(SLRRTCRtpTransceiverInit *)init {
  webrtc::RTCErrorOr<rtc::scoped_refptr<webrtc::RtpTransceiverInterface>> nativeTransceiverOrError =
      _peerConnection->AddTransceiver(track.nativeTrack, init.nativeInit);
  if (!nativeTransceiverOrError.ok()) {
    SLRRTCLogError(
        @"Failed to add transceiver %@: %s", track, nativeTransceiverOrError.error().message());
    return nil;
  }
  return [[SLRRTCRtpTransceiver alloc] initWithFactory:self.factory
                               nativeRtpTransceiver:nativeTransceiverOrError.MoveValue()];
}

- (SLRRTCRtpTransceiver *)addTransceiverOfType:(SLRRTCRtpMediaType)mediaType {
  return [self addTransceiverOfType:mediaType init:[[SLRRTCRtpTransceiverInit alloc] init]];
}

- (SLRRTCRtpTransceiver *)addTransceiverOfType:(SLRRTCRtpMediaType)mediaType
                                       init:(SLRRTCRtpTransceiverInit *)init {
  webrtc::RTCErrorOr<rtc::scoped_refptr<webrtc::RtpTransceiverInterface>> nativeTransceiverOrError =
      _peerConnection->AddTransceiver([SLRRTCRtpReceiver nativeMediaTypeForMediaType:mediaType],
                                      init.nativeInit);
  if (!nativeTransceiverOrError.ok()) {
    SLRRTCLogError(@"Failed to add transceiver %@: %s",
                [SLRRTCRtpReceiver stringForMediaType:mediaType],
                nativeTransceiverOrError.error().message());
    return nil;
  }
  return [[SLRRTCRtpTransceiver alloc] initWithFactory:self.factory
                               nativeRtpTransceiver:nativeTransceiverOrError.MoveValue()];
}

- (void)offerForConstraints:(SLRRTCMediaConstraints *)constraints
          completionHandler:
    (void (^)(SLRRTCSessionDescription *sessionDescription,
              NSError *error))completionHandler {
  rtc::scoped_refptr<webrtc::CreateSessionDescriptionObserverAdapter>
      observer(new rtc::RefCountedObject
          <webrtc::CreateSessionDescriptionObserverAdapter>(completionHandler));
  webrtc::PeerConnectionInterface::RTCOfferAnswerOptions options;
  CopyConstraintsIntoOfferAnswerOptions(constraints.nativeConstraints.get(), &options);

  _peerConnection->CreateOffer(observer, options);
}

- (void)answerForConstraints:(SLRRTCMediaConstraints *)constraints
           completionHandler:
    (void (^)(SLRRTCSessionDescription *sessionDescription,
              NSError *error))completionHandler {
  rtc::scoped_refptr<webrtc::CreateSessionDescriptionObserverAdapter>
      observer(new rtc::RefCountedObject
          <webrtc::CreateSessionDescriptionObserverAdapter>(completionHandler));
  webrtc::PeerConnectionInterface::RTCOfferAnswerOptions options;
  CopyConstraintsIntoOfferAnswerOptions(constraints.nativeConstraints.get(), &options);

  _peerConnection->CreateAnswer(observer, options);
}

- (void)setLocalDescription:(SLRRTCSessionDescription *)sdp
          completionHandler:(void (^)(NSError *error))completionHandler {
  rtc::scoped_refptr<webrtc::SetSessionDescriptionObserverAdapter> observer(
      new rtc::RefCountedObject<webrtc::SetSessionDescriptionObserverAdapter>(
          completionHandler));
  _peerConnection->SetLocalDescription(observer, sdp.nativeDescription);
}

- (void)setRemoteDescription:(SLRRTCSessionDescription *)sdp
           completionHandler:(void (^)(NSError *error))completionHandler {
  rtc::scoped_refptr<webrtc::SetSessionDescriptionObserverAdapter> observer(
      new rtc::RefCountedObject<webrtc::SetSessionDescriptionObserverAdapter>(
          completionHandler));
  _peerConnection->SetRemoteDescription(observer, sdp.nativeDescription);
}

- (BOOL)setBweMinBitrateBps:(nullable NSNumber *)minBitrateBps
          currentBitrateBps:(nullable NSNumber *)currentBitrateBps
              maxBitrateBps:(nullable NSNumber *)maxBitrateBps {
  webrtc::PeerConnectionInterface::BitrateParameters params;
  if (minBitrateBps != nil) {
    params.min_bitrate_bps = absl::optional<int>(minBitrateBps.intValue);
  }
  if (currentBitrateBps != nil) {
    params.current_bitrate_bps = absl::optional<int>(currentBitrateBps.intValue);
  }
  if (maxBitrateBps != nil) {
    params.max_bitrate_bps = absl::optional<int>(maxBitrateBps.intValue);
  }
  return _peerConnection->SetBitrate(params).ok();
}

- (void)setBitrateAllocationStrategy:
        (std::unique_ptr<rtc::BitrateAllocationStrategy>)bitrateAllocationStrategy {
  _peerConnection->SetBitrateAllocationStrategy(std::move(bitrateAllocationStrategy));
}

- (BOOL)startRtcEventLogWithFilePath:(NSString *)filePath
                      maxSizeInBytes:(int64_t)maxSizeInBytes {
  RTC_DCHECK(filePath.length);
  RTC_DCHECK_GT(maxSizeInBytes, 0);
  RTC_DCHECK(!_hasStartedRtcEventLog);
  if (_hasStartedRtcEventLog) {
    SLRRTCLogError(@"Event logging already started.");
    return NO;
  }
  int fd = open(filePath.UTF8String, O_WRONLY | O_CREAT | O_TRUNC,
                S_IRUSR | S_IWUSR);
  if (fd < 0) {
    SLRRTCLogError(@"Error opening file: %@. Error: %d", filePath, errno);
    return NO;
  }
  _hasStartedRtcEventLog =
      _peerConnection->StartRtcEventLog(fd, maxSizeInBytes);
  return _hasStartedRtcEventLog;
}

- (void)stopRtcEventLog {
  _peerConnection->StopRtcEventLog();
  _hasStartedRtcEventLog = NO;
}

- (SLRRTCRtpSender *)senderWithKind:(NSString *)kind
                        streamId:(NSString *)streamId {
  std::string nativeKind = [NSString stdStringForString:kind];
  std::string nativeStreamId = [NSString stdStringForString:streamId];
  rtc::scoped_refptr<webrtc::RtpSenderInterface> nativeSender(
      _peerConnection->CreateSender(nativeKind, nativeStreamId));
  return nativeSender ?
      [[SLRRTCRtpSender alloc] initWithFactory:self.factory nativeRtpSender:nativeSender] :
      nil;
}

- (NSArray<SLRRTCRtpSender *> *)senders {
  std::vector<rtc::scoped_refptr<webrtc::RtpSenderInterface>> nativeSenders(
      _peerConnection->GetSenders());
  NSMutableArray *senders = [[NSMutableArray alloc] init];
  for (const auto &nativeSender : nativeSenders) {
    SLRRTCRtpSender *sender =
        [[SLRRTCRtpSender alloc] initWithFactory:self.factory nativeRtpSender:nativeSender];
    [senders addObject:sender];
  }
  return senders;
}

- (NSArray<SLRRTCRtpReceiver *> *)receivers {
  std::vector<rtc::scoped_refptr<webrtc::RtpReceiverInterface>> nativeReceivers(
      _peerConnection->GetReceivers());
  NSMutableArray *receivers = [[NSMutableArray alloc] init];
  for (const auto &nativeReceiver : nativeReceivers) {
    SLRRTCRtpReceiver *receiver =
        [[SLRRTCRtpReceiver alloc] initWithFactory:self.factory nativeRtpReceiver:nativeReceiver];
    [receivers addObject:receiver];
  }
  return receivers;
}

- (NSArray<SLRRTCRtpTransceiver *> *)transceivers {
  std::vector<rtc::scoped_refptr<webrtc::RtpTransceiverInterface>> nativeTransceivers(
      _peerConnection->GetTransceivers());
  NSMutableArray *transceivers = [[NSMutableArray alloc] init];
  for (const auto &nativeTransceiver : nativeTransceivers) {
    SLRRTCRtpTransceiver *transceiver = [[SLRRTCRtpTransceiver alloc] initWithFactory:self.factory
                                                           nativeRtpTransceiver:nativeTransceiver];
    [transceivers addObject:transceiver];
  }
  return transceivers;
}

#pragma mark - Private

+ (webrtc::PeerConnectionInterface::SignalingState)nativeSignalingStateForState:
    (SLRRTCSignalingState)state {
  switch (state) {
    case SLRRTCSignalingStateStable:
      return webrtc::PeerConnectionInterface::kStable;
    case SLRRTCSignalingStateHaveLocalOffer:
      return webrtc::PeerConnectionInterface::kHaveLocalOffer;
    case SLRRTCSignalingStateHaveLocalPrAnswer:
      return webrtc::PeerConnectionInterface::kHaveLocalPrAnswer;
    case SLRRTCSignalingStateHaveRemoteOffer:
      return webrtc::PeerConnectionInterface::kHaveRemoteOffer;
    case SLRRTCSignalingStateHaveRemotePrAnswer:
      return webrtc::PeerConnectionInterface::kHaveRemotePrAnswer;
    case SLRRTCSignalingStateClosed:
      return webrtc::PeerConnectionInterface::kClosed;
  }
}

+ (SLRRTCSignalingState)signalingStateForNativeState:
    (webrtc::PeerConnectionInterface::SignalingState)nativeState {
  switch (nativeState) {
    case webrtc::PeerConnectionInterface::kStable:
      return SLRRTCSignalingStateStable;
    case webrtc::PeerConnectionInterface::kHaveLocalOffer:
      return SLRRTCSignalingStateHaveLocalOffer;
    case webrtc::PeerConnectionInterface::kHaveLocalPrAnswer:
      return SLRRTCSignalingStateHaveLocalPrAnswer;
    case webrtc::PeerConnectionInterface::kHaveRemoteOffer:
      return SLRRTCSignalingStateHaveRemoteOffer;
    case webrtc::PeerConnectionInterface::kHaveRemotePrAnswer:
      return SLRRTCSignalingStateHaveRemotePrAnswer;
    case webrtc::PeerConnectionInterface::kClosed:
      return SLRRTCSignalingStateClosed;
  }
}

+ (NSString *)stringForSignalingState:(SLRRTCSignalingState)state {
  switch (state) {
    case SLRRTCSignalingStateStable:
      return @"STABLE";
    case SLRRTCSignalingStateHaveLocalOffer:
      return @"HAVE_LOCAL_OFFER";
    case SLRRTCSignalingStateHaveLocalPrAnswer:
      return @"HAVE_LOCAL_PRANSWER";
    case SLRRTCSignalingStateHaveRemoteOffer:
      return @"HAVE_REMOTE_OFFER";
    case SLRRTCSignalingStateHaveRemotePrAnswer:
      return @"HAVE_REMOTE_PRANSWER";
    case SLRRTCSignalingStateClosed:
      return @"CLOSED";
  }
}

+ (webrtc::PeerConnectionInterface::PeerConnectionState)nativeConnectionStateForState:
        (SLRRTCPeerConnectionState)state {
  switch (state) {
    case SLRRTCPeerConnectionStateNew:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kNew;
    case SLRRTCPeerConnectionStateConnecting:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kConnecting;
    case SLRRTCPeerConnectionStateConnected:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kConnected;
    case SLRRTCPeerConnectionStateFailed:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kFailed;
    case SLRRTCPeerConnectionStateDisconnected:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kDisconnected;
    case SLRRTCPeerConnectionStateClosed:
      return webrtc::PeerConnectionInterface::PeerConnectionState::kClosed;
  }
}

+ (SLRRTCPeerConnectionState)connectionStateForNativeState:
        (webrtc::PeerConnectionInterface::PeerConnectionState)nativeState {
  switch (nativeState) {
    case webrtc::PeerConnectionInterface::PeerConnectionState::kNew:
      return SLRRTCPeerConnectionStateNew;
    case webrtc::PeerConnectionInterface::PeerConnectionState::kConnecting:
      return SLRRTCPeerConnectionStateConnecting;
    case webrtc::PeerConnectionInterface::PeerConnectionState::kConnected:
      return SLRRTCPeerConnectionStateConnected;
    case webrtc::PeerConnectionInterface::PeerConnectionState::kFailed:
      return SLRRTCPeerConnectionStateFailed;
    case webrtc::PeerConnectionInterface::PeerConnectionState::kDisconnected:
      return SLRRTCPeerConnectionStateDisconnected;
    case webrtc::PeerConnectionInterface::PeerConnectionState::kClosed:
      return SLRRTCPeerConnectionStateClosed;
  }
}

+ (NSString *)stringForConnectionState:(SLRRTCPeerConnectionState)state {
  switch (state) {
    case SLRRTCPeerConnectionStateNew:
      return @"NEW";
    case SLRRTCPeerConnectionStateConnecting:
      return @"CONNECTING";
    case SLRRTCPeerConnectionStateConnected:
      return @"CONNECTED";
    case SLRRTCPeerConnectionStateFailed:
      return @"FAILED";
    case SLRRTCPeerConnectionStateDisconnected:
      return @"DISCONNECTED";
    case SLRRTCPeerConnectionStateClosed:
      return @"CLOSED";
  }
}

+ (webrtc::PeerConnectionInterface::IceConnectionState)
    nativeIceConnectionStateForState:(SLRRTCIceConnectionState)state {
  switch (state) {
    case SLRRTCIceConnectionStateNew:
      return webrtc::PeerConnectionInterface::kIceConnectionNew;
    case SLRRTCIceConnectionStateChecking:
      return webrtc::PeerConnectionInterface::kIceConnectionChecking;
    case SLRRTCIceConnectionStateConnected:
      return webrtc::PeerConnectionInterface::kIceConnectionConnected;
    case SLRRTCIceConnectionStateCompleted:
      return webrtc::PeerConnectionInterface::kIceConnectionCompleted;
    case SLRRTCIceConnectionStateFailed:
      return webrtc::PeerConnectionInterface::kIceConnectionFailed;
    case SLRRTCIceConnectionStateDisconnected:
      return webrtc::PeerConnectionInterface::kIceConnectionDisconnected;
    case SLRRTCIceConnectionStateClosed:
      return webrtc::PeerConnectionInterface::kIceConnectionClosed;
    case SLRRTCIceConnectionStateCount:
      return webrtc::PeerConnectionInterface::kIceConnectionMax;
  }
}

+ (SLRRTCIceConnectionState)iceConnectionStateForNativeState:
    (webrtc::PeerConnectionInterface::IceConnectionState)nativeState {
  switch (nativeState) {
    case webrtc::PeerConnectionInterface::kIceConnectionNew:
      return SLRRTCIceConnectionStateNew;
    case webrtc::PeerConnectionInterface::kIceConnectionChecking:
      return SLRRTCIceConnectionStateChecking;
    case webrtc::PeerConnectionInterface::kIceConnectionConnected:
      return SLRRTCIceConnectionStateConnected;
    case webrtc::PeerConnectionInterface::kIceConnectionCompleted:
      return SLRRTCIceConnectionStateCompleted;
    case webrtc::PeerConnectionInterface::kIceConnectionFailed:
      return SLRRTCIceConnectionStateFailed;
    case webrtc::PeerConnectionInterface::kIceConnectionDisconnected:
      return SLRRTCIceConnectionStateDisconnected;
    case webrtc::PeerConnectionInterface::kIceConnectionClosed:
      return SLRRTCIceConnectionStateClosed;
    case webrtc::PeerConnectionInterface::kIceConnectionMax:
      return SLRRTCIceConnectionStateCount;
  }
}

+ (NSString *)stringForIceConnectionState:(SLRRTCIceConnectionState)state {
  switch (state) {
    case SLRRTCIceConnectionStateNew:
      return @"NEW";
    case SLRRTCIceConnectionStateChecking:
      return @"CHECKING";
    case SLRRTCIceConnectionStateConnected:
      return @"CONNECTED";
    case SLRRTCIceConnectionStateCompleted:
      return @"COMPLETED";
    case SLRRTCIceConnectionStateFailed:
      return @"FAILED";
    case SLRRTCIceConnectionStateDisconnected:
      return @"DISCONNECTED";
    case SLRRTCIceConnectionStateClosed:
      return @"CLOSED";
    case SLRRTCIceConnectionStateCount:
      return @"COUNT";
  }
}

+ (webrtc::PeerConnectionInterface::IceGatheringState)
    nativeIceGatheringStateForState:(SLRRTCIceGatheringState)state {
  switch (state) {
    case SLRRTCIceGatheringStateNew:
      return webrtc::PeerConnectionInterface::kIceGatheringNew;
    case SLRRTCIceGatheringStateGathering:
      return webrtc::PeerConnectionInterface::kIceGatheringGathering;
    case SLRRTCIceGatheringStateComplete:
      return webrtc::PeerConnectionInterface::kIceGatheringComplete;
  }
}

+ (SLRRTCIceGatheringState)iceGatheringStateForNativeState:
    (webrtc::PeerConnectionInterface::IceGatheringState)nativeState {
  switch (nativeState) {
    case webrtc::PeerConnectionInterface::kIceGatheringNew:
      return SLRRTCIceGatheringStateNew;
    case webrtc::PeerConnectionInterface::kIceGatheringGathering:
      return SLRRTCIceGatheringStateGathering;
    case webrtc::PeerConnectionInterface::kIceGatheringComplete:
      return SLRRTCIceGatheringStateComplete;
  }
}

+ (NSString *)stringForIceGatheringState:(SLRRTCIceGatheringState)state {
  switch (state) {
    case SLRRTCIceGatheringStateNew:
      return @"NEW";
    case SLRRTCIceGatheringStateGathering:
      return @"GATHERING";
    case SLRRTCIceGatheringStateComplete:
      return @"COMPLETE";
  }
}

+ (webrtc::PeerConnectionInterface::StatsOutputLevel)
    nativeStatsOutputLevelForLevel:(SLRRTCStatsOutputLevel)level {
  switch (level) {
    case SLRRTCStatsOutputLevelStandard:
      return webrtc::PeerConnectionInterface::kStatsOutputLevelStandard;
    case SLRRTCStatsOutputLevelDebug:
      return webrtc::PeerConnectionInterface::kStatsOutputLevelDebug;
  }
}

- (rtc::scoped_refptr<webrtc::PeerConnectionInterface>)nativePeerConnection {
  return _peerConnection;
}

@end
