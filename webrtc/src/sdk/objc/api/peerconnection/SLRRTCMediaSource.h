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

typedef NS_ENUM(NSInteger, SLRRTCSourceState) {
  SLRRTCSourceStateInitializing,
  SLRRTCSourceStateLive,
  SLRRTCSourceStateEnded,
  SLRRTCSourceStateMuted,
};

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface SLRRTCMediaSource : NSObject

/** The current state of the SLRRTCMediaSource. */
@property(nonatomic, readonly) SLRRTCSourceState state;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
