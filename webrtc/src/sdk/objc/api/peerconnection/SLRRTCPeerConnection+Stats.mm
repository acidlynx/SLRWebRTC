/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCPeerConnection+Private.h"

#import "SLRRTCLegacyStatsReport+Private.h"
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCRtpReceiver+Private.h"
#import "SLRRTCRtpSender+Private.h"
#import "SLRRTCStatisticsReport+Private.h"
#import "helpers/NSString+StdString.h"

#include "rtc_base/checks.h"

namespace webrtc {

class StatsCollectorCallbackAdapter : public RTCStatsCollectorCallback {
 public:
  StatsCollectorCallbackAdapter(SLRRTCStatisticsCompletionHandler completion_handler)
      : completion_handler_(completion_handler) {}

  void OnStatsDelivered(const rtc::scoped_refptr<const RTCStatsReport> &report) override {
    RTC_DCHECK(completion_handler_);
    SLRRTCStatisticsReport *statisticsReport = [[SLRRTCStatisticsReport alloc] initWithReport:*report];
    completion_handler_(statisticsReport);
    completion_handler_ = nil;
  }

 private:
  SLRRTCStatisticsCompletionHandler completion_handler_;
};

class StatsObserverAdapter : public StatsObserver {
 public:
  StatsObserverAdapter(void (^completionHandler)
      (NSArray<SLRRTCLegacyStatsReport *> *stats)) {
    completion_handler_ = completionHandler;
  }

  ~StatsObserverAdapter() override { completion_handler_ = nil; }

  void OnComplete(const StatsReports& reports) override {
    RTC_DCHECK(completion_handler_);
    NSMutableArray *stats = [NSMutableArray arrayWithCapacity:reports.size()];
    for (const auto* report : reports) {
      SLRRTCLegacyStatsReport *statsReport =
          [[SLRRTCLegacyStatsReport alloc] initWithNativeReport:*report];
      [stats addObject:statsReport];
    }
    completion_handler_(stats);
    completion_handler_ = nil;
  }

 private:
  void (^completion_handler_)(NSArray<SLRRTCLegacyStatsReport *> *stats);
};
}  // namespace webrtc

@implementation SLRRTCPeerConnection (Stats)

- (void)statisticsForSender:(SLRRTCRtpSender *)sender
          completionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler {
  rtc::scoped_refptr<webrtc::StatsCollectorCallbackAdapter> collector(
      new rtc::RefCountedObject<webrtc::StatsCollectorCallbackAdapter>(completionHandler));
  self.nativePeerConnection->GetStats(sender.nativeRtpSender, collector);
}

- (void)statisticsForReceiver:(SLRRTCRtpReceiver *)receiver
            completionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler {
  rtc::scoped_refptr<webrtc::StatsCollectorCallbackAdapter> collector(
      new rtc::RefCountedObject<webrtc::StatsCollectorCallbackAdapter>(completionHandler));
  self.nativePeerConnection->GetStats(receiver.nativeRtpReceiver, collector);
}

- (void)statisticsWithCompletionHandler:(SLRRTCStatisticsCompletionHandler)completionHandler {
  rtc::scoped_refptr<webrtc::StatsCollectorCallbackAdapter> collector(
      new rtc::RefCountedObject<webrtc::StatsCollectorCallbackAdapter>(completionHandler));
  self.nativePeerConnection->GetStats(collector);
}

- (void)statsForTrack:(SLRRTCMediaStreamTrack *)mediaStreamTrack
     statsOutputLevel:(SLRRTCStatsOutputLevel)statsOutputLevel
    completionHandler:
    (void (^)(NSArray<SLRRTCLegacyStatsReport *> *stats))completionHandler {
  rtc::scoped_refptr<webrtc::StatsObserverAdapter> observer(
      new rtc::RefCountedObject<webrtc::StatsObserverAdapter>
          (completionHandler));
  webrtc::PeerConnectionInterface::StatsOutputLevel nativeOutputLevel =
      [[self class] nativeStatsOutputLevelForLevel:statsOutputLevel];
  self.nativePeerConnection->GetStats(
      observer, mediaStreamTrack.nativeTrack, nativeOutputLevel);
}

@end
