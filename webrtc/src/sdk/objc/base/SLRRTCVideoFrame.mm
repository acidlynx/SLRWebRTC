/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCVideoFrame.h"

#import "SLRRTCI420Buffer.h"
#import "SLRRTCVideoFrameBuffer.h"

@implementation SLRRTCVideoFrame {
  SLRRTCVideoRotation _rotation;
  int64_t _timeStampNs;
}

@synthesize buffer = _buffer;
@synthesize timeStamp;

- (int)width {
  return _buffer.width;
}

- (int)height {
  return _buffer.height;
}

- (SLRRTCVideoRotation)rotation {
  return _rotation;
}

- (int64_t)timeStampNs {
  return _timeStampNs;
}

- (SLRRTCVideoFrame *)newI420VideoFrame {
  return [[SLRRTCVideoFrame alloc] initWithBuffer:[_buffer toI420]
                                      rotation:_rotation
                                   timeStampNs:_timeStampNs];
}

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                           rotation:(SLRRTCVideoRotation)rotation
                        timeStampNs:(int64_t)timeStampNs {
  // Deprecated.
  return nil;
}

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                        scaledWidth:(int)scaledWidth
                       scaledHeight:(int)scaledHeight
                          cropWidth:(int)cropWidth
                         cropHeight:(int)cropHeight
                              cropX:(int)cropX
                              cropY:(int)cropY
                           rotation:(SLRRTCVideoRotation)rotation
                        timeStampNs:(int64_t)timeStampNs {
  // Deprecated.
  return nil;
}

- (instancetype)initWithBuffer:(id<SLRRTCVideoFrameBuffer>)buffer
                      rotation:(SLRRTCVideoRotation)rotation
                   timeStampNs:(int64_t)timeStampNs {
  if (self = [super init]) {
    _buffer = buffer;
    _rotation = rotation;
    _timeStampNs = timeStampNs;
  }

  return self;
}

@end
