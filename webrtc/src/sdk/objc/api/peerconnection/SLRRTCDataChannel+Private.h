/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCDataChannel.h"

#include "api/data_channel_interface.h"
#include "api/scoped_refptr.h"

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCPeerConnectionFactory;

@interface SLRRTCDataBuffer ()

/**
 * The native DataBuffer representation of this SLRRTCDatabuffer object. This is
 * needed to pass to the underlying C++ APIs.
 */
@property(nonatomic, readonly) const webrtc::DataBuffer *nativeDataBuffer;

/** Initialize an SLRRTCDataBuffer from a native DataBuffer. */
- (instancetype)initWithNativeBuffer:(const webrtc::DataBuffer &)nativeBuffer;

@end

@interface SLRRTCDataChannel ()

/** Initialize an SLRRTCDataChannel from a native DataChannelInterface. */
- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeDataChannel:(rtc::scoped_refptr<webrtc::DataChannelInterface>)nativeDataChannel
    NS_DESIGNATED_INITIALIZER;

+ (webrtc::DataChannelInterface::DataState)nativeDataChannelStateForState:
        (SLRRTCDataChannelState)state;

+ (SLRRTCDataChannelState)dataChannelStateForNativeState:
        (webrtc::DataChannelInterface::DataState)nativeState;

+ (NSString *)stringForState:(SLRRTCDataChannelState)state;

@end

NS_ASSUME_NONNULL_END
