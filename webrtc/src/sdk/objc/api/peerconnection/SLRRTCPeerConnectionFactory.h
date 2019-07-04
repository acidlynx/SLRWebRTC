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

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCAudioSource;
@class SLRRTCAudioTrack;
@class SLRRTCConfiguration;
@class SLRRTCMediaConstraints;
@class SLRRTCMediaStream;
@class SLRRTCPeerConnection;
@class SLRRTCVideoSource;
@class SLRRTCVideoTrack;
@class SLRRTCPeerConnectionFactoryOptions;
@protocol SLRRTCPeerConnectionDelegate;
@protocol SLRRTCVideoDecoderFactory;
@protocol SLRRTCVideoEncoderFactory;

RTC_OBJC_EXPORT
@interface SLRRTCPeerConnectionFactory : NSObject

/* Initialize object with default H264 video encoder/decoder factories */
- (instancetype)init;

/* Initialize object with injectable video encoder/decoder factories */
- (instancetype)initWithEncoderFactory:(nullable id<SLRRTCVideoEncoderFactory>)encoderFactory
                        decoderFactory:(nullable id<SLRRTCVideoDecoderFactory>)decoderFactory;

/** Initialize an SLRRTCAudioSource with constraints. */
- (SLRRTCAudioSource *)audioSourceWithConstraints:(nullable SLRRTCMediaConstraints *)constraints;

/** Initialize an SLRRTCAudioTrack with an id. Convenience ctor to use an audio source with no
 *  constraints.
 */
- (SLRRTCAudioTrack *)audioTrackWithTrackId:(NSString *)trackId;

/** Initialize an SLRRTCAudioTrack with a source and an id. */
- (SLRRTCAudioTrack *)audioTrackWithSource:(SLRRTCAudioSource *)source trackId:(NSString *)trackId;

/** Initialize a generic SLRRTCVideoSource. The SLRRTCVideoSource should be passed to a SLRRTCVideoCapturer
 *  implementation, e.g. SLRRTCCameraVideoCapturer, in order to produce frames.
 */
- (SLRRTCVideoSource *)videoSource;

/** Initialize an SLRRTCVideoTrack with a source and an id. */
- (SLRRTCVideoTrack *)videoTrackWithSource:(SLRRTCVideoSource *)source trackId:(NSString *)trackId;

/** Initialize an SLRRTCMediaStream with an id. */
- (SLRRTCMediaStream *)mediaStreamWithStreamId:(NSString *)streamId;

/** Initialize an SLRRTCPeerConnection with a configuration, constraints, and
 *  delegate.
 */
- (SLRRTCPeerConnection *)peerConnectionWithConfiguration:(SLRRTCConfiguration *)configuration
                                           constraints:(SLRRTCMediaConstraints *)constraints
                                              delegate:
                                                  (nullable id<SLRRTCPeerConnectionDelegate>)delegate;

/** Set the options to be used for subsequently created SLRRTCPeerConnections */
- (void)setOptions:(nonnull SLRRTCPeerConnectionFactoryOptions *)options;

/** Start an AecDump recording. This API call will likely change in the future. */
- (BOOL)startAecDumpWithFilePath:(NSString *)filePath maxSizeInBytes:(int64_t)maxSizeInBytes;

/* Stop an active AecDump recording */
- (void)stopAecDump;

@end

NS_ASSUME_NONNULL_END
