/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMediaStreamTrack.h"

#include "api/media_stream_interface.h"

typedef NS_ENUM(NSInteger, SLRRTCMediaStreamTrackType) {
  SLRRTCMediaStreamTrackTypeAudio,
  SLRRTCMediaStreamTrackTypeVideo,
};

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCPeerConnectionFactory;

@interface SLRRTCMediaStreamTrack ()

@property(nonatomic, readonly) SLRRTCPeerConnectionFactory *factory;

/**
 * The native MediaStreamTrackInterface passed in or created during
 * construction.
 */
@property(nonatomic, readonly) rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> nativeTrack;

/**
 * Initialize an SLRRTCMediaStreamTrack from a native MediaStreamTrackInterface.
 */
- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                    nativeTrack:(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack
                           type:(SLRRTCMediaStreamTrackType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                    nativeTrack:(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack;

- (BOOL)isEqualToTrack:(SLRRTCMediaStreamTrack *)track;

+ (webrtc::MediaStreamTrackInterface::TrackState)nativeTrackStateForState:
        (SLRRTCMediaStreamTrackState)state;

+ (SLRRTCMediaStreamTrackState)trackStateForNativeState:
        (webrtc::MediaStreamTrackInterface::TrackState)nativeState;

+ (NSString *)stringForState:(SLRRTCMediaStreamTrackState)state;

+ (SLRRTCMediaStreamTrack *)mediaTrackForNativeTrack:
                             (rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)nativeTrack
                                          factory:(SLRRTCPeerConnectionFactory *)factory;

@end

NS_ASSUME_NONNULL_END
