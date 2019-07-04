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

#import "SLRRTCMacros.h"

// Subset of rtc::LoggingSeverity.
typedef NS_ENUM(NSInteger, SLRRTCLoggingSeverity) {
  SLRRTCLoggingSeverityVerbose,
  SLRRTCLoggingSeverityInfo,
  SLRRTCLoggingSeverityWarning,
  SLRRTCLoggingSeverityError,
  SLRRTCLoggingSeverityNone,
};

// Wrapper for C++ RTC_LOG(sev) macros.
// Logs the log string to the webrtc logstream for the given severity.
RTC_EXTERN void SLRRTCLogEx(SLRRTCLoggingSeverity severity, NSString* log_string);

// Wrapper for rtc::LogMessage::LogToDebug.
// Sets the minimum severity to be logged to console.
RTC_EXTERN void SLRRTCSetMinDebugLogLevel(SLRRTCLoggingSeverity severity);

// Returns the filename with the path prefix removed.
RTC_EXTERN NSString* SLRRTCFileName(const char* filePath);

// Some convenience macros.

#define SLRRTCLogString(format, ...)                                           \
  [NSString stringWithFormat:@"(%@:%d %s): " format, SLRRTCFileName(__FILE__), \
                             __LINE__, __FUNCTION__, ##__VA_ARGS__]

#define SLRRTCLogFormat(severity, format, ...)                     \
  do {                                                          \
    NSString* log_string = SLRRTCLogString(format, ##__VA_ARGS__); \
    SLRRTCLogEx(severity, log_string);                             \
  } while (false)

#define SLRRTCLogVerbose(format, ...) \
  SLRRTCLogFormat(SLRRTCLoggingSeverityVerbose, format, ##__VA_ARGS__)

#define SLRRTCLogInfo(format, ...) \
  SLRRTCLogFormat(SLRRTCLoggingSeverityInfo, format, ##__VA_ARGS__)

#define SLRRTCLogWarning(format, ...) \
  SLRRTCLogFormat(SLRRTCLoggingSeverityWarning, format, ##__VA_ARGS__)

#define SLRRTCLogError(format, ...) \
  SLRRTCLogFormat(SLRRTCLoggingSeverityError, format, ##__VA_ARGS__)

#if !defined(NDEBUG)
#define SLRRTCLogDebug(format, ...) SLRRTCLogInfo(format, ##__VA_ARGS__)
#else
#define SLRRTCLogDebug(format, ...) \
  do {                           \
  } while (false)
#endif

#define SLRRTCLog(format, ...) SLRRTCLogInfo(format, ##__VA_ARGS__)
