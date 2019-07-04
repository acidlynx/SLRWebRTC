/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SLRRTCDeviceType) {
  SLRRTCDeviceTypeUnknown,
  SLRRTCDeviceTypeIPhone1G,
  SLRRTCDeviceTypeIPhone3G,
  SLRRTCDeviceTypeIPhone3GS,
  SLRRTCDeviceTypeIPhone4,
  SLRRTCDeviceTypeIPhone4Verizon,
  SLRRTCDeviceTypeIPhone4S,
  SLRRTCDeviceTypeIPhone5GSM,
  SLRRTCDeviceTypeIPhone5GSM_CDMA,
  SLRRTCDeviceTypeIPhone5CGSM,
  SLRRTCDeviceTypeIPhone5CGSM_CDMA,
  SLRRTCDeviceTypeIPhone5SGSM,
  SLRRTCDeviceTypeIPhone5SGSM_CDMA,
  SLRRTCDeviceTypeIPhone6Plus,
  SLRRTCDeviceTypeIPhone6,
  SLRRTCDeviceTypeIPhone6S,
  SLRRTCDeviceTypeIPhone6SPlus,
  SLRRTCDeviceTypeIPhone7,
  SLRRTCDeviceTypeIPhone7Plus,
  SLRRTCDeviceTypeIPhoneSE,
  SLRRTCDeviceTypeIPhone8,
  SLRRTCDeviceTypeIPhone8Plus,
  SLRRTCDeviceTypeIPhoneX,
  SLRRTCDeviceTypeIPhoneXS,
  SLRRTCDeviceTypeIPhoneXSMax,
  SLRRTCDeviceTypeIPhoneXR,
  SLRRTCDeviceTypeIPodTouch1G,
  SLRRTCDeviceTypeIPodTouch2G,
  SLRRTCDeviceTypeIPodTouch3G,
  SLRRTCDeviceTypeIPodTouch4G,
  SLRRTCDeviceTypeIPodTouch5G,
  SLRRTCDeviceTypeIPodTouch6G,
  SLRRTCDeviceTypeIPad,
  SLRRTCDeviceTypeIPad2Wifi,
  SLRRTCDeviceTypeIPad2GSM,
  SLRRTCDeviceTypeIPad2CDMA,
  SLRRTCDeviceTypeIPad2Wifi2,
  SLRRTCDeviceTypeIPadMiniWifi,
  SLRRTCDeviceTypeIPadMiniGSM,
  SLRRTCDeviceTypeIPadMiniGSM_CDMA,
  SLRRTCDeviceTypeIPad3Wifi,
  SLRRTCDeviceTypeIPad3GSM_CDMA,
  SLRRTCDeviceTypeIPad3GSM,
  SLRRTCDeviceTypeIPad4Wifi,
  SLRRTCDeviceTypeIPad4GSM,
  SLRRTCDeviceTypeIPad4GSM_CDMA,
  SLRRTCDeviceTypeIPad5,
  SLRRTCDeviceTypeIPad6,
  SLRRTCDeviceTypeIPadAirWifi,
  SLRRTCDeviceTypeIPadAirCellular,
  SLRRTCDeviceTypeIPadAirWifiCellular,
  SLRRTCDeviceTypeIPadAir2,
  SLRRTCDeviceTypeIPadMini2GWifi,
  SLRRTCDeviceTypeIPadMini2GCellular,
  SLRRTCDeviceTypeIPadMini2GWifiCellular,
  SLRRTCDeviceTypeIPadMini3,
  SLRRTCDeviceTypeIPadMini4,
  SLRRTCDeviceTypeIPadPro9Inch,
  SLRRTCDeviceTypeIPadPro12Inch,
  SLRRTCDeviceTypeIPadPro12Inch2,
  SLRRTCDeviceTypeIPadPro10Inch,
  SLRRTCDeviceTypeSimulatori386,
  SLRRTCDeviceTypeSimulatorx86_64,
};

@interface UIDevice (SLRRTCDevice)

+ (SLRRTCDeviceType)deviceType;
+ (BOOL)isIOS11OrLater;

@end
