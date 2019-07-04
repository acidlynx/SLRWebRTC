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
#import "SLRRTCMetricsSampleInfo.h"

/**
 * Enables gathering of metrics (which can be fetched with
 * SLRRTCGetAndResetMetrics). Must be called before any other call into WebRTC.
 */
RTC_EXTERN void SLRRTCEnableMetrics(void);

/** Gets and clears native histograms. */
RTC_EXTERN NSArray<SLRRTCMetricsSampleInfo*>* SLRRTCGetAndResetMetrics(void);
