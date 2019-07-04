/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMediaStream+Private.h"

#include <vector>

#import "SLRRTCAudioTrack+Private.h"
#import "SLRRTCMediaStreamTrack+Private.h"
#import "SLRRTCPeerConnectionFactory+Private.h"
#import "SLRRTCVideoTrack+Private.h"
#import "helpers/NSString+StdString.h"

@implementation SLRRTCMediaStream {
  SLRRTCPeerConnectionFactory *_factory;
  NSMutableArray *_audioTracks;
  NSMutableArray *_videoTracks;
  rtc::scoped_refptr<webrtc::MediaStreamInterface> _nativeMediaStream;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
                       streamId:(NSString *)streamId {
  NSParameterAssert(factory);
  NSParameterAssert(streamId.length);
  std::string nativeId = [NSString stdStringForString:streamId];
  rtc::scoped_refptr<webrtc::MediaStreamInterface> stream =
      factory.nativeFactory->CreateLocalMediaStream(nativeId);
  return [self initWithFactory:factory nativeMediaStream:stream];
}

- (NSArray<SLRRTCAudioTrack *> *)audioTracks {
  return [_audioTracks copy];
}

- (NSArray<SLRRTCVideoTrack *> *)videoTracks {
  return [_videoTracks copy];
}

- (NSString *)streamId {
  return [NSString stringForStdString:_nativeMediaStream->id()];
}

- (void)addAudioTrack:(SLRRTCAudioTrack *)audioTrack {
  if (_nativeMediaStream->AddTrack(audioTrack.nativeAudioTrack)) {
    [_audioTracks addObject:audioTrack];
  }
}

- (void)addVideoTrack:(SLRRTCVideoTrack *)videoTrack {
  if (_nativeMediaStream->AddTrack(videoTrack.nativeVideoTrack)) {
    [_videoTracks addObject:videoTrack];
  }
}

- (void)removeAudioTrack:(SLRRTCAudioTrack *)audioTrack {
  NSUInteger index = [_audioTracks indexOfObjectIdenticalTo:audioTrack];
  NSAssert(index != NSNotFound,
           @"|removeAudioTrack| called on unexpected SLRRTCAudioTrack");
  if (index != NSNotFound &&
      _nativeMediaStream->RemoveTrack(audioTrack.nativeAudioTrack)) {
    [_audioTracks removeObjectAtIndex:index];
  }
}

- (void)removeVideoTrack:(SLRRTCVideoTrack *)videoTrack {
  NSUInteger index = [_videoTracks indexOfObjectIdenticalTo:videoTrack];
  NSAssert(index != NSNotFound,
           @"|removeVideoTrack| called on unexpected SLRRTCVideoTrack");
  if (index != NSNotFound &&
      _nativeMediaStream->RemoveTrack(videoTrack.nativeVideoTrack)) {
    [_videoTracks removeObjectAtIndex:index];
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"SLRRTCMediaStream:\n%@\nA=%lu\nV=%lu",
                                    self.streamId,
                                    (unsigned long)self.audioTracks.count,
                                    (unsigned long)self.videoTracks.count];
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::MediaStreamInterface>)nativeMediaStream {
  return _nativeMediaStream;
}

- (instancetype)initWithFactory:(SLRRTCPeerConnectionFactory *)factory
              nativeMediaStream:
                  (rtc::scoped_refptr<webrtc::MediaStreamInterface>)nativeMediaStream {
  NSParameterAssert(nativeMediaStream);
  if (self = [super init]) {
    _factory = factory;

    webrtc::AudioTrackVector audioTracks = nativeMediaStream->GetAudioTracks();
    webrtc::VideoTrackVector videoTracks = nativeMediaStream->GetVideoTracks();

    _audioTracks = [NSMutableArray arrayWithCapacity:audioTracks.size()];
    _videoTracks = [NSMutableArray arrayWithCapacity:videoTracks.size()];
    _nativeMediaStream = nativeMediaStream;

    for (auto &track : audioTracks) {
      SLRRTCMediaStreamTrackType type = SLRRTCMediaStreamTrackTypeAudio;
      SLRRTCAudioTrack *audioTrack =
          [[SLRRTCAudioTrack alloc] initWithFactory:_factory nativeTrack:track type:type];
      [_audioTracks addObject:audioTrack];
    }

    for (auto &track : videoTracks) {
      SLRRTCMediaStreamTrackType type = SLRRTCMediaStreamTrackTypeVideo;
      SLRRTCVideoTrack *videoTrack =
          [[SLRRTCVideoTrack alloc] initWithFactory:_factory nativeTrack:track type:type];
      [_videoTracks addObject:videoTrack];
    }
  }
  return self;
}

@end
