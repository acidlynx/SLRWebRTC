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

#import "SLRRTCDtmfSender.h"
#import "SLRRTCMacros.h"
#import "SLRRTCMediaStreamTrack.h"
#import "SLRRTCRtpParameters.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@protocol SLRRTCRtpSender <NSObject>

/** A unique identifier for this sender. */
@property(nonatomic, readonly) NSString *senderId;

/** The currently active SLRRTCRtpParameters, as defined in
 *  https://www.w3.org/TR/webrtc/#idl-def-SLRRTCRtpParameters.
 */
@property(nonatomic, copy) SLRRTCRtpParameters *parameters;

/** The SLRRTCMediaStreamTrack associated with the sender.
 *  Note: reading this property returns a new instance of
 *  SLRRTCMediaStreamTrack. Use isEqual: instead of == to compare
 *  SLRRTCMediaStreamTrack instances.
 */
@property(nonatomic, copy, nullable) SLRRTCMediaStreamTrack *track;

/** The SLRRTCDtmfSender accociated with the RTP sender. */
@property(nonatomic, readonly, nullable) id<SLRRTCDtmfSender> dtmfSender;

@end

RTC_OBJC_EXPORT
@interface SLRRTCRtpSender : NSObject <SLRRTCRtpSender>

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
