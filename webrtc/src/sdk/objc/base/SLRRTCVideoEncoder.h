/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "SLRRTCCodecSpecificInfo.h"
#import "SLRRTCEncodedImage.h"
#import "SLRRTCMacros.h"
#import "SLRRTCRtpFragmentationHeader.h"
#import "SLRRTCVideoEncoderQpThresholds.h"
#import "SLRRTCVideoEncoderSettings.h"
#import "SLRRTCVideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

/** Callback block for encoder. */
typedef BOOL (^SLRRTCVideoEncoderCallback)(SLRRTCEncodedImage *frame,
                                        id<SLRRTCCodecSpecificInfo> info,
                                        SLRRTCRtpFragmentationHeader *header);

/** Protocol for encoder implementations. */
RTC_OBJC_EXPORT
@protocol SLRRTCVideoEncoder <NSObject>

- (void)setCallback:(SLRRTCVideoEncoderCallback)callback;
- (NSInteger)startEncodeWithSettings:(SLRRTCVideoEncoderSettings *)settings
                       numberOfCores:(int)numberOfCores;
- (NSInteger)releaseEncoder;
- (NSInteger)encode:(SLRRTCVideoFrame *)frame
    codecSpecificInfo:(nullable id<SLRRTCCodecSpecificInfo>)info
           frameTypes:(NSArray<NSNumber *> *)frameTypes;
- (int)setBitrate:(uint32_t)bitrateKbit framerate:(uint32_t)framerate;
- (NSString *)implementationName;

/** Returns QP scaling settings for encoder. The quality scaler adjusts the resolution in order to
 *  keep the QP from the encoded images within the given range. Returning nil from this function
 *  disables quality scaling. */
- (nullable SLRRTCVideoEncoderQpThresholds *)scalingSettings;

@end

NS_ASSUME_NONNULL_END
