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

@class SLRRTCAudioTrack;
@class SLRRTCPeerConnectionFactory;
@class SLRRTCVideoTrack;

RTC_OBJC_EXPORT
@interface SLRRTCMediaStream : NSObject

/** The audio tracks in this stream. */
@property(nonatomic, strong, readonly) NSArray<SLRRTCAudioTrack *> *audioTracks;

/** The video tracks in this stream. */
@property(nonatomic, strong, readonly) NSArray<SLRRTCVideoTrack *> *videoTracks;

/** An identifier for this media stream. */
@property(nonatomic, readonly) NSString *streamId;

- (instancetype)init NS_UNAVAILABLE;

/** Adds the given audio track to this media stream. */
- (void)addAudioTrack:(SLRRTCAudioTrack *)audioTrack;

/** Adds the given video track to this media stream. */
- (void)addVideoTrack:(SLRRTCVideoTrack *)videoTrack;

/** Removes the given audio track to this media stream. */
- (void)removeAudioTrack:(SLRRTCAudioTrack *)audioTrack;

/** Removes the given video track to this media stream. */
- (void)removeVideoTrack:(SLRRTCVideoTrack *)videoTrack;

@end

NS_ASSUME_NONNULL_END
