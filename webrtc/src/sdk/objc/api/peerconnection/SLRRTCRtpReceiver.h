/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "SLRRTCMacros.h"
#import "SLRRTCMediaStreamTrack.h"
#import "SLRRTCRtpParameters.h"

NS_ASSUME_NONNULL_BEGIN

/** Represents the media type of the RtpReceiver. */
typedef NS_ENUM(NSInteger, SLRRTCRtpMediaType) {
  SLRRTCRtpMediaTypeAudio,
  SLRRTCRtpMediaTypeVideo,
  SLRRTCRtpMediaTypeData,
};

@class SLRRTCRtpReceiver;

RTC_OBJC_EXPORT
@protocol SLRRTCRtpReceiverDelegate <NSObject>

/** Called when the first RTP packet is received.
 *
 *  Note: Currently if there are multiple RtpReceivers of the same media type,
 *  they will all call OnFirstPacketReceived at once.
 *
 *  For example, if we create three audio receivers, A/B/C, they will listen to
 *  the same signal from the underneath network layer. Whenever the first audio packet
 *  is received, the underneath signal will be fired. All the receivers A/B/C will be
 *  notified and the callback of the receiver's delegate will be called.
 *
 *  The process is the same for video receivers.
 */
- (void)rtpReceiver:(SLRRTCRtpReceiver *)rtpReceiver
    didReceiveFirstPacketForMediaType:(SLRRTCRtpMediaType)mediaType;

@end

RTC_OBJC_EXPORT
@protocol SLRRTCRtpReceiver <NSObject>

/** A unique identifier for this receiver. */
@property(nonatomic, readonly) NSString *receiverId;

/** The currently active SLRRTCRtpParameters, as defined in
 *  https://www.w3.org/TR/webrtc/#idl-def-SLRRTCRtpParameters.
 *
 *  The WebRTC specification only defines SLRRTCRtpParameters in terms of senders,
 *  but this API also applies them to receivers, similar to ORTC:
 *  http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
 */
@property(nonatomic, readonly) SLRRTCRtpParameters *parameters;

/** The SLRRTCMediaStreamTrack associated with the receiver.
 *  Note: reading this property returns a new instance of
 *  SLRRTCMediaStreamTrack. Use isEqual: instead of == to compare
 *  SLRRTCMediaStreamTrack instances.
 */
@property(nonatomic, readonly, nullable) SLRRTCMediaStreamTrack *track;

/** The delegate for this RtpReceiver. */
@property(nonatomic, weak) id<SLRRTCRtpReceiverDelegate> delegate;

@end

RTC_OBJC_EXPORT
@interface SLRRTCRtpReceiver : NSObject <SLRRTCRtpReceiver>

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
