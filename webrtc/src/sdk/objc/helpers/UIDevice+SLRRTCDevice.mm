/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "UIDevice+SLRRTCDevice.h"

#import <sys/utsname.h>
#include <memory>

@implementation UIDevice (SLRRTCDevice)

+ (SLRRTCDeviceType)deviceType {
  NSDictionary *machineNameToType = @{
    @"iPhone1,1" : @(SLRRTCDeviceTypeIPhone1G),
    @"iPhone1,2" : @(SLRRTCDeviceTypeIPhone3G),
    @"iPhone2,1" : @(SLRRTCDeviceTypeIPhone3GS),
    @"iPhone3,1" : @(SLRRTCDeviceTypeIPhone4),
    @"iPhone3,2" : @(SLRRTCDeviceTypeIPhone4),
    @"iPhone3,3" : @(SLRRTCDeviceTypeIPhone4Verizon),
    @"iPhone4,1" : @(SLRRTCDeviceTypeIPhone4S),
    @"iPhone5,1" : @(SLRRTCDeviceTypeIPhone5GSM),
    @"iPhone5,2" : @(SLRRTCDeviceTypeIPhone5GSM_CDMA),
    @"iPhone5,3" : @(SLRRTCDeviceTypeIPhone5CGSM),
    @"iPhone5,4" : @(SLRRTCDeviceTypeIPhone5CGSM_CDMA),
    @"iPhone6,1" : @(SLRRTCDeviceTypeIPhone5SGSM),
    @"iPhone6,2" : @(SLRRTCDeviceTypeIPhone5SGSM_CDMA),
    @"iPhone7,1" : @(SLRRTCDeviceTypeIPhone6Plus),
    @"iPhone7,2" : @(SLRRTCDeviceTypeIPhone6),
    @"iPhone8,1" : @(SLRRTCDeviceTypeIPhone6S),
    @"iPhone8,2" : @(SLRRTCDeviceTypeIPhone6SPlus),
    @"iPhone8,4" : @(SLRRTCDeviceTypeIPhoneSE),
    @"iPhone9,1" : @(SLRRTCDeviceTypeIPhone7),
    @"iPhone9,2" : @(SLRRTCDeviceTypeIPhone7Plus),
    @"iPhone9,3" : @(SLRRTCDeviceTypeIPhone7),
    @"iPhone9,4" : @(SLRRTCDeviceTypeIPhone7Plus),
    @"iPhone10,1" : @(SLRRTCDeviceTypeIPhone8),
    @"iPhone10,2" : @(SLRRTCDeviceTypeIPhone8Plus),
    @"iPhone10,3" : @(SLRRTCDeviceTypeIPhoneX),
    @"iPhone10,4" : @(SLRRTCDeviceTypeIPhone8),
    @"iPhone10,5" : @(SLRRTCDeviceTypeIPhone8Plus),
    @"iPhone10,6" : @(SLRRTCDeviceTypeIPhoneX),
    @"iPhone11,2" : @(SLRRTCDeviceTypeIPhoneXS),
    @"iPhone11,4" : @(SLRRTCDeviceTypeIPhoneXSMax),
    @"iPhone11,6" : @(SLRRTCDeviceTypeIPhoneXSMax),
    @"iPhone11,8" : @(SLRRTCDeviceTypeIPhoneXR),
    @"iPod1,1" : @(SLRRTCDeviceTypeIPodTouch1G),
    @"iPod2,1" : @(SLRRTCDeviceTypeIPodTouch2G),
    @"iPod3,1" : @(SLRRTCDeviceTypeIPodTouch3G),
    @"iPod4,1" : @(SLRRTCDeviceTypeIPodTouch4G),
    @"iPod5,1" : @(SLRRTCDeviceTypeIPodTouch5G),
    @"iPod7,1" : @(SLRRTCDeviceTypeIPodTouch6G),
    @"iPad1,1" : @(SLRRTCDeviceTypeIPad),
    @"iPad2,1" : @(SLRRTCDeviceTypeIPad2Wifi),
    @"iPad2,2" : @(SLRRTCDeviceTypeIPad2GSM),
    @"iPad2,3" : @(SLRRTCDeviceTypeIPad2CDMA),
    @"iPad2,4" : @(SLRRTCDeviceTypeIPad2Wifi2),
    @"iPad2,5" : @(SLRRTCDeviceTypeIPadMiniWifi),
    @"iPad2,6" : @(SLRRTCDeviceTypeIPadMiniGSM),
    @"iPad2,7" : @(SLRRTCDeviceTypeIPadMiniGSM_CDMA),
    @"iPad3,1" : @(SLRRTCDeviceTypeIPad3Wifi),
    @"iPad3,2" : @(SLRRTCDeviceTypeIPad3GSM_CDMA),
    @"iPad3,3" : @(SLRRTCDeviceTypeIPad3GSM),
    @"iPad3,4" : @(SLRRTCDeviceTypeIPad4Wifi),
    @"iPad3,5" : @(SLRRTCDeviceTypeIPad4GSM),
    @"iPad3,6" : @(SLRRTCDeviceTypeIPad4GSM_CDMA),
    @"iPad4,1" : @(SLRRTCDeviceTypeIPadAirWifi),
    @"iPad4,2" : @(SLRRTCDeviceTypeIPadAirCellular),
    @"iPad4,3" : @(SLRRTCDeviceTypeIPadAirWifiCellular),
    @"iPad4,4" : @(SLRRTCDeviceTypeIPadMini2GWifi),
    @"iPad4,5" : @(SLRRTCDeviceTypeIPadMini2GCellular),
    @"iPad4,6" : @(SLRRTCDeviceTypeIPadMini2GWifiCellular),
    @"iPad4,7" : @(SLRRTCDeviceTypeIPadMini3),
    @"iPad4,8" : @(SLRRTCDeviceTypeIPadMini3),
    @"iPad4,9" : @(SLRRTCDeviceTypeIPadMini3),
    @"iPad5,1" : @(SLRRTCDeviceTypeIPadMini4),
    @"iPad5,2" : @(SLRRTCDeviceTypeIPadMini4),
    @"iPad5,3" : @(SLRRTCDeviceTypeIPadAir2),
    @"iPad5,4" : @(SLRRTCDeviceTypeIPadAir2),
    @"iPad6,3" : @(SLRRTCDeviceTypeIPadPro9Inch),
    @"iPad6,4" : @(SLRRTCDeviceTypeIPadPro9Inch),
    @"iPad6,7" : @(SLRRTCDeviceTypeIPadPro12Inch),
    @"iPad6,8" : @(SLRRTCDeviceTypeIPadPro12Inch),
    @"iPad6,11" : @(SLRRTCDeviceTypeIPad5),
    @"iPad6,12" : @(SLRRTCDeviceTypeIPad5),
    @"iPad7,1" : @(SLRRTCDeviceTypeIPadPro12Inch2),
    @"iPad7,2" : @(SLRRTCDeviceTypeIPadPro12Inch2),
    @"iPad7,3" : @(SLRRTCDeviceTypeIPadPro10Inch),
    @"iPad7,4" : @(SLRRTCDeviceTypeIPadPro10Inch),
    @"iPad7,5" : @(SLRRTCDeviceTypeIPad6),
    @"iPad7,6" : @(SLRRTCDeviceTypeIPad6),
    @"i386" : @(SLRRTCDeviceTypeSimulatori386),
    @"x86_64" : @(SLRRTCDeviceTypeSimulatorx86_64),
  };

  SLRRTCDeviceType deviceType = SLRRTCDeviceTypeUnknown;
  NSNumber *typeNumber = machineNameToType[[self machineName]];
  if (typeNumber) {
    deviceType = static_cast<SLRRTCDeviceType>(typeNumber.integerValue);
  }
  return deviceType;
}

+ (NSString *)machineName {
  struct utsname systemInfo;
  uname(&systemInfo);
  return [[NSString alloc] initWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
}

+ (double)currentDeviceSystemVersion {
  return [self currentDevice].systemVersion.doubleValue;
}

+ (BOOL)isIOS11OrLater {
  return [self currentDeviceSystemVersion] >= 11.0;
}

@end
