#!/bin/bash

cd ./src/tools_webrtc/ios
find . -name 'generate_umbrella_header*' | xargs perl -pi -e 's/<WebRTC/<SLRWebRTC/g'
find . -name "build_ios_libs*" | xargs perl -pi -e 's/'WebRTC'/'SLRWebRTC'/g'
find . -name "build_ios_libs*" | xargs perl -pi -e 's/BuildSLRWebRTC/BuildWebRTC/g'

cd ../../sdk/objc

find . -name "RTC*.mm" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "RTC*.m" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "RTC*.h" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "UIDevice*" -exec rename 's|RTC|SLRRTC|' {} +

find . -name "SLRWebRTC" -type d | rm -Rf  ./Framework/Headers/SLRWebRTC 
find . -name "WebRTC" -type d | mv ./Framework/Headers/WebRTC ./Framework/Headers/SLRWebRTC 

cd ./Framework/Headers/SLRWebRTC/
find . -name "RTC*.h" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "UIDevice*" -exec rename 's|RTC|SLRRTC|' {} +

cd ../../../

find . -name "*.plist" | xargs perl -pi -e 's/(WebRTC)/SLRWebRTC/g'
find . -name "*.h" | xargs perl -pi -e 's/(RTC)/SLRRTC/g'
find . -name "*.m" | xargs perl -pi -e 's/(RTC)/SLRRTC/g'
find . -name "*.mm" | xargs perl -pi -e 's/(RTC)/SLRRTC/g'

cd ../

find . -name "BUILD.gn" | xargs perl -pi -e 's/(RTC)/SLRRTC/g'


find . -name "*.h" | xargs perl -pi -e 's/(SLRRTC_)/RTC_/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTC_)/RTC_/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTC_)/RTC_/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRRTCCertificate)/RTCCertificate/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTCCertificate)/RTCCertificate/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTCCertificate)/RTCCertificate/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRRTCStats)/RTCStats/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTCStats)/RTCStats/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTCStats)/RTCStats/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRRTCConfiguration)/RTCConfiguration/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTCConfiguration)/RTCConfiguration/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTCConfiguration)/RTCConfiguration/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRRTCError)/RTCError/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTCError)/RTCError/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTCError)/RTCError/g'

find . -name "*.h" | xargs perl -pi -e 's/(RTCConfiguration.h)/SLRRTCConfiguration.h/g'
find . -name "*.m" | xargs perl -pi -e 's/(RTCConfiguration.h)/SLRRTCConfiguration.h/g'
find . -name "*.mm" | xargs perl -pi -e 's/(RTCConfiguration.h)/SLRRTCConfiguration.h/g'

find . -name "*.h" | xargs perl -pi -e 's/(RTCCertificate.h)/SLRRTCCertificate.h/g'
find . -name "*.m" | xargs perl -pi -e 's/(RTCCertificate.h)/SLRRTCCertificate.h/g'
find . -name "*.mm" | xargs perl -pi -e 's/(RTCCertificate.h)/SLRRTCCertificate.h/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRRTCOfferAnswerOptions)/RTCOfferAnswerOptions/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRRTCOfferAnswerOptions)/RTCOfferAnswerOptions/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRRTCOfferAnswerOptions)/RTCOfferAnswerOptions/g'

find . -name "*.h" | xargs perl -pi -e 's/(SLRSLRRTCCertificate.h)/SLRRTCCertificate.h/g'
find . -name "*.m" | xargs perl -pi -e 's/(SLRSLRRTCCertificate.h)/SLRRTCCertificate.h/g'
find . -name "*.mm" | xargs perl -pi -e 's/(SLRSLRRTCCertificate.h)/SLRRTCCertificate.h/g'

find . -name "*.h" | xargs perl -pi -e 's/"RTCConfiguration/"SLRRTCConfiguration/g'
find . -name "*.m" | xargs perl -pi -e 's/"RTCConfiguration/"SLRRTCConfiguration/g'
find . -name "*.mm" | xargs perl -pi -e 's/"RTCConfiguration/"SLRRTCConfiguration/g'


find . -name "BUILD.gn" | xargs perl -pi -e 's/(WebSLRRTC)/SLRWebRTC/g'
