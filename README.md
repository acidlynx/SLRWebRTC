Instruction:

Before build, remove previous version of WebRTC

1. Install depot tools

cd <somewhere>
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
cd depot_tools
export PATH=<somewhere>/depot_tools:"$PATH"

2. Fetch Stable WebRTC source

mkdir webrtc-checkout
cd webrtc-checkout
fetch --nohooks webrtc
git branch -r
git chekout branch-heads/<last version>
gclient sync

3. Install support tools

brew install rename
brew install gnu-sed

4. Rename all files 

cd src/
cd ./tools_webrtc/ios

find . -name "generate_umbrella_header*" | xargs perl -pi -e 's/<WebRTC/<SLRWebRTC/g'
find . -name "build_ios_libs*" | xargs perl -pi -e 's/'WebRTC'/'SLRWebRTC'/g'
find . -name "build_ios_libs*" | xargs perl -pi -e 's/BuildSLRWebRTC/BuildWebRTC/g'


cd ../../sdk/objc

find . -name "RTC*.mm" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "RTC*.m" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "RTC*.h" -exec rename 's|RTC|SLRRTC|' {} +
find . -name "UIDevice*" -exec rename 's|RTC|SLRRTC|' {} +

mv ./Framework/Headers/WebRTC ./Framework/Headers/SLRWebRTC
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

5. Build Framework

cd ./tools_webrtc/ios
sh build_ios_libs.sh

