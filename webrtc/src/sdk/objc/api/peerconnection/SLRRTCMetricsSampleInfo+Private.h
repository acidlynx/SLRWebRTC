/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMetricsSampleInfo.h"

#include "system_wrappers/include/metrics.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLRRTCMetricsSampleInfo ()

/** Initialize an SLRRTCMetricsSampleInfo object from native SampleInfo. */
- (instancetype)initWithNativeSampleInfo:(const webrtc::metrics::SampleInfo &)info;

@end

NS_ASSUME_NONNULL_END