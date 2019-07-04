/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCDataChannel+Private.h"

#import "helpers/NSString+StdString.h"

#include <memory>

namespace webrtc {

class DataChannelDelegateAdapter : public DataChannelObserver {
 public:
  DataChannelDelegateAdapter(SLRRTCDataChannel *channel) { channel_ = channel; }

  void OnStateChange() override {
    [channel_.delegate dataChannelDidChangeState:channel_];
  }

  void OnMessage(const DataBuffer& buffer) override {
    SLRRTCDataBuffer *data_buffer =
        [[SLRRTCDataBuffer alloc] initWithNativeBuffer:buffer];
    [channel_.delegate dataChannel:channel_
       didReceiveMessageWithBuffer:data_buffer];
  }

  void OnBufferedAmountChange(uint64_t previousAmount) override {
    id<SLRRTCDataChannelDelegate> delegate = channel_.delegate;
    SEL sel = @selector(dataChannel:didChangeBufferedAmount:);
    if ([delegate respondsToSelector:sel]) {
      [delegate dataChannel:channel_ didChangeBufferedAmount:previousAmount];
    }
  }

 private:
  __weak SLRRTCDataChannel *channel_;
};
}


@implementation SLRRTCDataBuffer {
  std::unique_ptr<webrtc::DataBuffer> _dataBuffer;
}

- (instancetype)initWithData:(NSData *)data isBinary:(BOOL)isBinary {
  NSParameterAssert(data);
  if (self = [super init]) {
    rtc::CopyOnWriteBuffer buffer(
        reinterpret_cast<const uint8_t*>(data.bytes), data.length);
    _dataBuffer.reset(new webrtc::DataBuffer(buffer, isBinary));
  }
  return self;
}

- (NSData *)data {
  return [NSData dataWithBytes:_dataBuffer->data.data()
                        length:_dataBuffer->data.size()];
}

- (BOOL)isBinary {
  return _dataBuffer->binary;
}

#pragma mark - Private

- (instancetype)initWithNativeBuffer:(const webrtc::DataBuffer&)nativeBuffer {
  if (self = [super init]) {
    _dataBuffer.reset(new webrtc::DataBuffer(nativeBuffer));
  }
  return self;
}

- (const webrtc::DataBuffer *)nativeDataBuffer {
  return _dataBuffer.get();
}

@end


@implementation SLRRTCDataChannel {
  SLRRTCPeerConnectionFactory *_factory;
  rtc::scoped_refptr<webrtc::DataChannelInterface> _nativeDataChannel;
  std::unique_ptr<webrtc::DataChannelDelegateAdapter> _observer;
  BOOL _isObserverRegistered;
}

@synthesize delegate = _delegate;

- (void)dealloc {
  // Handles unregistering the observer properly. We need to do this because
  // there may still be other references to the underlying data channel.
  _nativeDataChannel->UnregisterObserver();
}

- (NSString *)label {
  return [NSString stringForStdString:_nativeDataChannel->label()];
}

- (BOOL)isReliable {
  return _nativeDataChannel->reliable();
}

- (BOOL)isOrdered {
  return _nativeDataChannel->ordered();
}

- (NSUInteger)maxRetransmitTime {
  return self.maxPacketLifeTime;
}

- (uint16_t)maxPacketLifeTime {
  return _nativeDataChannel->maxRetransmitTime();
}

- (uint16_t)maxRetransmits {
  return _nativeDataChannel->maxRetransmits();
}

- (NSString *)protocol {
  return [NSString stringForStdString:_nativeDataChannel->protocol()];
}

- (BOOL)isNegotiated {
  return _nativeDataChannel->negotiated();
}

- (NSInteger)streamId {
  return self.channelId;
}

- (int)channelId {
  return _nativeDataChannel->id();
}

- (SLRRTCDataChannelState)readyState {
  return [[self class] dataChannelStateForNativeState:
      _nativeDataChannel->state()];
}

- (uint64_t)bufferedAmount {
  return _nativeDataChannel->buffered_amount();
}

- (void)close {
  _nativeDataChannel->Close();
}

- (BOOL)sendData:(SLRRTCDataBuffer *)data {
  return _nativeDataChannel->Send(*data.nativeDataBuffer);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCDataChannel:\n%ld\n%@\n%@",
                                    (long)self.channelId,
                                    self.label,
                                    [[self class]
                                        stringForState:self.readyState]];
}

#pragma mark - Private

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeDataChannel:
                  (rtc::scoped_refptr<webrtc::DataChannelInterface>)nativeDataChannel {
  NSParameterAssert(nativeDataChannel);
  if (self = [super init]) {
    _factory = factory;
    _nativeDataChannel = nativeDataChannel;
    _observer.reset(new webrtc::DataChannelDelegateAdapter(self));
    _nativeDataChannel->RegisterObserver(_observer.get());
  }
  return self;
}

+ (webrtc::DataChannelInterface::DataState)
    nativeDataChannelStateForState:(SLRRTCDataChannelState)state {
  switch (state) {
    case SLRRTCDataChannelStateConnecting:
      return webrtc::DataChannelInterface::DataState::kConnecting;
    case SLRRTCDataChannelStateOpen:
      return webrtc::DataChannelInterface::DataState::kOpen;
    case SLRRTCDataChannelStateClosing:
      return webrtc::DataChannelInterface::DataState::kClosing;
    case SLRRTCDataChannelStateClosed:
      return webrtc::DataChannelInterface::DataState::kClosed;
  }
}

+ (SLRRTCDataChannelState)dataChannelStateForNativeState:
    (webrtc::DataChannelInterface::DataState)nativeState {
  switch (nativeState) {
    case webrtc::DataChannelInterface::DataState::kConnecting:
      return SLRRTCDataChannelStateConnecting;
    case webrtc::DataChannelInterface::DataState::kOpen:
      return SLRRTCDataChannelStateOpen;
    case webrtc::DataChannelInterface::DataState::kClosing:
      return SLRRTCDataChannelStateClosing;
    case webrtc::DataChannelInterface::DataState::kClosed:
      return SLRRTCDataChannelStateClosed;
  }
}

+ (NSString *)stringForState:(SLRRTCDataChannelState)state {
  switch (state) {
    case SLRRTCDataChannelStateConnecting:
      return @"Connecting";
    case SLRRTCDataChannelStateOpen:
      return @"Open";
    case SLRRTCDataChannelStateClosing:
      return @"Closing";
    case SLRRTCDataChannelStateClosed:
      return @"Closed";
  }
}

@end