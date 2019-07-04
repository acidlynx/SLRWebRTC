/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCVideoSource.h"

#import "SLRRTCMediaSource+Private.h"

#include "api/media_stream_interface.h"
#include "rtc_base/thread.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLRRTCVideoSource ()

/**
 * The VideoTrackSourceInterface object passed to this SLRRTCVideoSource during
 * construction.
 */
@property(nonatomic, readonly) rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>
    nativeVideoSource;

/** Initialize an SLRRTCVideoSource from a native VideoTrackSourceInterface. */
- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeVideoSource:
                  (rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>)nativeVideoSource
    NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeMediaSource:(rtc::scoped_refptr<webrtc::MediaSourceInterface>)nativeMediaSource
                           type:(SLRRTCMediaSourceType)type NS_UNAVAILABLE;

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                signalingThread:(rtc::Thread *)signalingThread
                   workerThread:(rtc::Thread *)workerThread;

@end

NS_ASSUME_NONNULL_END
