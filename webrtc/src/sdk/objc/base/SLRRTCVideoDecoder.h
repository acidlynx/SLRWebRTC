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
#import "SLRRTCVideoEncoderSettings.h"
#import "SLRRTCVideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

/** Callback block for decoder. */
typedef void (^SLRRTCVideoDecoderCallback)(SLRRTCVideoFrame *frame);

/** Protocol for decoder implementations. */
RTC_OBJC_EXPORT
@protocol SLRRTCVideoDecoder <NSObject>

- (void)setCallback:(SLRRTCVideoDecoderCallback)callback;
- (NSInteger)startDecodeWithSettings:(SLRRTCVideoEncoderSettings *)settings
                       numberOfCores:(int)numberOfCores
    DEPRECATED_MSG_ATTRIBUTE("use startDecodeWithNumberOfCores: instead");
- (NSInteger)releaseDecoder;
- (NSInteger)decode:(SLRRTCEncodedImage *)encodedImage
        missingFrames:(BOOL)missingFrames
    codecSpecificInfo:(nullable id<SLRRTCCodecSpecificInfo>)info
         renderTimeMs:(int64_t)renderTimeMs;
- (NSString *)implementationName;

// TODO(andersc): Make non-optional when `startDecodeWithSettings:numberOfCores:` is removed.
@optional
- (NSInteger)startDecodeWithNumberOfCores:(int)numberOfCores;

@end

NS_ASSUME_NONNULL_END
