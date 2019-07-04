/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCVideoFrame.h"

#import "SLRRTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class SLRRTCVideoCapturer;

RTC_OBJC_EXPORT
@protocol SLRRTCVideoCapturerDelegate <NSObject>
- (void)capturer:(SLRRTCVideoCapturer *)capturer didCaptureVideoFrame:(SLRRTCVideoFrame *)frame;
@end

RTC_OBJC_EXPORT
@interface SLRRTCVideoCapturer : NSObject

@property(nonatomic, weak) id<SLRRTCVideoCapturerDelegate> delegate;

- (instancetype)initWithDelegate:(id<SLRRTCVideoCapturerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
