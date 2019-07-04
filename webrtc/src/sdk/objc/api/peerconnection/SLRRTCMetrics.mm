/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMetrics.h"

#import "SLRRTCMetricsSampleInfo+Private.h"

void SLRRTCEnableMetrics(void) {
  webrtc::metrics::Enable();
}

NSArray<SLRRTCMetricsSampleInfo *> *SLRRTCGetAndResetMetrics(void) {
  std::map<std::string, std::unique_ptr<webrtc::metrics::SampleInfo>>
      histograms;
  webrtc::metrics::GetAndReset(&histograms);

  NSMutableArray *metrics =
      [NSMutableArray arrayWithCapacity:histograms.size()];
  for (auto const &histogram : histograms) {
    SLRRTCMetricsSampleInfo *metric = [[SLRRTCMetricsSampleInfo alloc]
        initWithNativeSampleInfo:*histogram.second];
    [metrics addObject:metric];
  }
  return metrics;
}