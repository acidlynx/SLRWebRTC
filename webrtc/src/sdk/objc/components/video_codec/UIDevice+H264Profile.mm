/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "UIDevice+H264Profile.h"
#import "helpers/UIDevice+SLRRTCDevice.h"

#include <algorithm>

namespace {

using namespace webrtc::H264;

struct SupportedH264Profile {
  const SLRRTCDeviceType deviceType;
  const ProfileLevelId profile;
};

constexpr SupportedH264Profile kH264MaxSupportedProfiles[] = {
    // iPhones with at least iOS 9
    {SLRRTCDeviceTypeIPhoneXS, {kProfileHigh, kLevel5_2}},      // https://support.apple.com/kb/SP779
    {SLRRTCDeviceTypeIPhoneXSMax, {kProfileHigh, kLevel5_2}},   // https://support.apple.com/kb/SP780
    {SLRRTCDeviceTypeIPhoneXR, {kProfileHigh, kLevel5_2}},      // https://support.apple.com/kb/SP781
    {SLRRTCDeviceTypeIPhoneX, {kProfileHigh, kLevel5_2}},       // https://support.apple.com/kb/SP770
    {SLRRTCDeviceTypeIPhone8, {kProfileHigh, kLevel5_2}},       // https://support.apple.com/kb/SP767
    {SLRRTCDeviceTypeIPhone8Plus, {kProfileHigh, kLevel5_2}},   // https://support.apple.com/kb/SP768
    {SLRRTCDeviceTypeIPhone7, {kProfileHigh, kLevel5_1}},       // https://support.apple.com/kb/SP743
    {SLRRTCDeviceTypeIPhone7Plus, {kProfileHigh, kLevel5_1}},   // https://support.apple.com/kb/SP744
    {SLRRTCDeviceTypeIPhoneSE, {kProfileHigh, kLevel4_2}},      // https://support.apple.com/kb/SP738
    {SLRRTCDeviceTypeIPhone6S, {kProfileHigh, kLevel4_2}},      // https://support.apple.com/kb/SP726
    {SLRRTCDeviceTypeIPhone6SPlus, {kProfileHigh, kLevel4_2}},  // https://support.apple.com/kb/SP727
    {SLRRTCDeviceTypeIPhone6, {kProfileHigh, kLevel4_2}},       // https://support.apple.com/kb/SP705
    {SLRRTCDeviceTypeIPhone6Plus, {kProfileHigh, kLevel4_2}},   // https://support.apple.com/kb/SP706
    {SLRRTCDeviceTypeIPhone5SGSM, {kProfileHigh, kLevel4_2}},   // https://support.apple.com/kb/SP685
    {SLRRTCDeviceTypeIPhone5SGSM_CDMA,
     {kProfileHigh, kLevel4_2}},                           // https://support.apple.com/kb/SP685
    {SLRRTCDeviceTypeIPhone5GSM, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP655
    {SLRRTCDeviceTypeIPhone5GSM_CDMA,
     {kProfileHigh, kLevel4_1}},                            // https://support.apple.com/kb/SP655
    {SLRRTCDeviceTypeIPhone5CGSM, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP684
    {SLRRTCDeviceTypeIPhone5CGSM_CDMA,
     {kProfileHigh, kLevel4_1}},                         // https://support.apple.com/kb/SP684
    {SLRRTCDeviceTypeIPhone4S, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP643

    // iPods with at least iOS 9
    {SLRRTCDeviceTypeIPodTouch6G, {kProfileMain, kLevel4_1}},  // https://support.apple.com/kb/SP720
    {SLRRTCDeviceTypeIPodTouch5G, {kProfileMain, kLevel3_1}},  // https://support.apple.com/kb/SP657

    // iPads with at least iOS 9
    {SLRRTCDeviceTypeIPad2Wifi, {kProfileHigh, kLevel4_1}},     // https://support.apple.com/kb/SP622
    {SLRRTCDeviceTypeIPad2GSM, {kProfileHigh, kLevel4_1}},      // https://support.apple.com/kb/SP622
    {SLRRTCDeviceTypeIPad2CDMA, {kProfileHigh, kLevel4_1}},     // https://support.apple.com/kb/SP622
    {SLRRTCDeviceTypeIPad2Wifi2, {kProfileHigh, kLevel4_1}},    // https://support.apple.com/kb/SP622
    {SLRRTCDeviceTypeIPadMiniWifi, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP661
    {SLRRTCDeviceTypeIPadMiniGSM, {kProfileHigh, kLevel4_1}},   // https://support.apple.com/kb/SP661
    {SLRRTCDeviceTypeIPadMiniGSM_CDMA,
     {kProfileHigh, kLevel4_1}},                              // https://support.apple.com/kb/SP661
    {SLRRTCDeviceTypeIPad3Wifi, {kProfileHigh, kLevel4_1}},      // https://support.apple.com/kb/SP647
    {SLRRTCDeviceTypeIPad3GSM_CDMA, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP647
    {SLRRTCDeviceTypeIPad3GSM, {kProfileHigh, kLevel4_1}},       // https://support.apple.com/kb/SP647
    {SLRRTCDeviceTypeIPad4Wifi, {kProfileHigh, kLevel4_1}},      // https://support.apple.com/kb/SP662
    {SLRRTCDeviceTypeIPad4GSM, {kProfileHigh, kLevel4_1}},       // https://support.apple.com/kb/SP662
    {SLRRTCDeviceTypeIPad4GSM_CDMA, {kProfileHigh, kLevel4_1}},  // https://support.apple.com/kb/SP662
    {SLRRTCDeviceTypeIPad5, {kProfileHigh, kLevel4_2}},          // https://support.apple.com/kb/SP751
    {SLRRTCDeviceTypeIPad6, {kProfileHigh, kLevel4_2}},          // https://support.apple.com/kb/SP774
    {SLRRTCDeviceTypeIPadAirWifi, {kProfileHigh, kLevel4_2}},    // https://support.apple.com/kb/SP692
    {SLRRTCDeviceTypeIPadAirCellular,
     {kProfileHigh, kLevel4_2}},  // https://support.apple.com/kb/SP692
    {SLRRTCDeviceTypeIPadAirWifiCellular,
     {kProfileHigh, kLevel4_2}},                               // https://support.apple.com/kb/SP692
    {SLRRTCDeviceTypeIPadAir2, {kProfileHigh, kLevel4_2}},        // https://support.apple.com/kb/SP708
    {SLRRTCDeviceTypeIPadMini2GWifi, {kProfileHigh, kLevel4_2}},  // https://support.apple.com/kb/SP693
    {SLRRTCDeviceTypeIPadMini2GCellular,
     {kProfileHigh, kLevel4_2}},  // https://support.apple.com/kb/SP693
    {SLRRTCDeviceTypeIPadMini2GWifiCellular,
     {kProfileHigh, kLevel4_2}},                               // https://support.apple.com/kb/SP693
    {SLRRTCDeviceTypeIPadMini3, {kProfileHigh, kLevel4_2}},       // https://support.apple.com/kb/SP709
    {SLRRTCDeviceTypeIPadMini4, {kProfileHigh, kLevel4_2}},       // https://support.apple.com/kb/SP725
    {SLRRTCDeviceTypeIPadPro9Inch, {kProfileHigh, kLevel4_2}},    // https://support.apple.com/kb/SP739
    {SLRRTCDeviceTypeIPadPro12Inch, {kProfileHigh, kLevel4_2}},   // https://support.apple.com/kb/sp723
    {SLRRTCDeviceTypeIPadPro12Inch2, {kProfileHigh, kLevel4_2}},  // https://support.apple.com/kb/SP761
    {SLRRTCDeviceTypeIPadPro10Inch, {kProfileHigh, kLevel4_2}},   // https://support.apple.com/kb/SP762
};

absl::optional<ProfileLevelId> FindMaxSupportedProfileForDevice(SLRRTCDeviceType deviceType) {
  const auto* result = std::find_if(std::begin(kH264MaxSupportedProfiles),
                                    std::end(kH264MaxSupportedProfiles),
                                    [deviceType](const SupportedH264Profile& supportedProfile) {
                                      return supportedProfile.deviceType == deviceType;
                                    });
  if (result != std::end(kH264MaxSupportedProfiles)) {
    return result->profile;
  }
  return absl::nullopt;
}

}  // namespace

@implementation UIDevice (H264Profile)

+ (absl::optional<webrtc::H264::ProfileLevelId>)maxSupportedH264Profile {
  return FindMaxSupportedProfileForDevice([self deviceType]);
}

@end
