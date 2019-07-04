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
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "SLRRTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCVideoFrame;

RTC_OBJC_EXPORT
@protocol SLRRTCVideoRenderer <NSObject>

/** The size of the frame. */
- (void)setSize:(CGSize)size;

/** The frame to be displayed. */
- (void)renderFrame:(nullable SLRRTCVideoFrame *)frame;

@end

RTC_OBJC_EXPORT
@protocol SLRRTCVideoViewDelegate

- (void)videoView:(id<SLRRTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
