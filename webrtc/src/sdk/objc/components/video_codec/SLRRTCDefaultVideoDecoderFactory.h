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

#import "SLRRTCMacros.h"
#import "SLRRTCVideoDecoderFactory.h"

NS_ASSUME_NONNULL_BEGIN

/** This decoder factory include support for all codecs bundled with WebRTC. If using custom
 *  codecs, create custom implementations of SLRRTCVideoEncoderFactory and SLRRTCVideoDecoderFactory.
 */
RTC_OBJC_EXPORT
@interface SLRRTCDefaultVideoDecoderFactory : NSObject <SLRRTCVideoDecoderFactory>
@end

NS_ASSUME_NONNULL_END
