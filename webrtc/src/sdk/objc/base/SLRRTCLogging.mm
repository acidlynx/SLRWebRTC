/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCLogging.h"

#include "rtc_base/logging.h"

rtc::LoggingSeverity SLRRTCGetNativeLoggingSeverity(SLRRTCLoggingSeverity severity) {
  switch (severity) {
    case SLRRTCLoggingSeverityVerbose:
      return rtc::LS_VERBOSE;
    case SLRRTCLoggingSeverityInfo:
      return rtc::LS_INFO;
    case SLRRTCLoggingSeverityWarning:
      return rtc::LS_WARNING;
    case SLRRTCLoggingSeverityError:
      return rtc::LS_ERROR;
    case SLRRTCLoggingSeverityNone:
      return rtc::LS_NONE;
  }
}

void SLRRTCLogEx(SLRRTCLoggingSeverity severity, NSString* log_string) {
  if (log_string.length) {
    const char* utf8_string = log_string.UTF8String;
    RTC_LOG_V(SLRRTCGetNativeLoggingSeverity(severity)) << utf8_string;
  }
}

void SLRRTCSetMinDebugLogLevel(SLRRTCLoggingSeverity severity) {
  rtc::LogMessage::LogToDebug(SLRRTCGetNativeLoggingSeverity(severity));
}

NSString* SLRRTCFileName(const char* file_path) {
  NSString* ns_file_path =
      [[NSString alloc] initWithBytesNoCopy:const_cast<char*>(file_path)
                                     length:strlen(file_path)
                                   encoding:NSUTF8StringEncoding
                               freeWhenDone:NO];
  return ns_file_path.lastPathComponent;
}
