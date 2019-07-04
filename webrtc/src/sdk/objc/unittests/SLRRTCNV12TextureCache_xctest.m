/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <XCTest/XCTest.h>

#import "base/SLRRTCVideoFrame.h"
#import "base/SLRRTCVideoFrameBuffer.h"
#import "components/renderer/opengl/SLRRTCNV12TextureCache.h"
#import "components/video_frame_buffer/SLRRTCCVPixelBuffer.h"

@interface SLRRTCNV12TextureCacheTests : XCTestCase
@end

@implementation SLRRTCNV12TextureCacheTests {
  EAGLContext *_glContext;
  SLRRTCNV12TextureCache *_nv12TextureCache;
}

- (void)setUp {
  [super setUp];
  _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
  if (!_glContext) {
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  }
  _nv12TextureCache = [[SLRRTCNV12TextureCache alloc] initWithContext:_glContext];
}

- (void)tearDown {
  _nv12TextureCache = nil;
  _glContext = nil;
  [super tearDown];
}

- (void)testNV12TextureCacheDoesNotCrashOnEmptyFrame {
  CVPixelBufferRef nullPixelBuffer = NULL;
  SLRRTCCVPixelBuffer *badFrameBuffer = [[SLRRTCCVPixelBuffer alloc] initWithPixelBuffer:nullPixelBuffer];
  SLRRTCVideoFrame *badFrame = [[SLRRTCVideoFrame alloc] initWithBuffer:badFrameBuffer
                                                         rotation:SLRRTCVideoRotation_0
                                                      timeStampNs:0];
  [_nv12TextureCache uploadFrameToTextures:badFrame];
}

@end
