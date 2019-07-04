/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCPeerConnectionFactory+Native.h"
#import "SLRRTCPeerConnectionFactoryBuilder+DefaultComponents.h"

#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#import "components/video_codec/SLRRTCVideoDecoderFactoryH264.h"
#import "components/video_codec/SLRRTCVideoEncoderFactoryH264.h"
#include "sdk/objc/native/api/video_decoder_factory.h"
#include "sdk/objc/native/api/video_encoder_factory.h"

#if defined(WEBRTC_IOS)
#import "sdk/objc/native/api/audio_device_module.h"
#endif

@implementation SLRRTCPeerConnectionFactoryBuilder (DefaultComponents)

+ (SLRRTCPeerConnectionFactoryBuilder *)defaultBuilder {
  SLRRTCPeerConnectionFactoryBuilder *builder = [[SLRRTCPeerConnectionFactoryBuilder alloc] init];
  auto audioEncoderFactory = webrtc::CreateBuiltinAudioEncoderFactory();
  [builder setAudioEncoderFactory:audioEncoderFactory];

  auto audioDecoderFactory = webrtc::CreateBuiltinAudioDecoderFactory();
  [builder setAudioDecoderFactory:audioDecoderFactory];

  auto videoEncoderFactory =
      webrtc::ObjCToNativeVideoEncoderFactory([[SLRRTCVideoEncoderFactoryH264 alloc] init]);
  [builder setVideoEncoderFactory:std::move(videoEncoderFactory)];

  auto videoDecoderFactory =
      webrtc::ObjCToNativeVideoDecoderFactory([[SLRRTCVideoDecoderFactoryH264 alloc] init]);
  [builder setVideoDecoderFactory:std::move(videoDecoderFactory)];

#if defined(WEBRTC_IOS)
  [builder setAudioDeviceModule:webrtc::CreateAudioDeviceModule()];
#endif
  return builder;
}

@end
