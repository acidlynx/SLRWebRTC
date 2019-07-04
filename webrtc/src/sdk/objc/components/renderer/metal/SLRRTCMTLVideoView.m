/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "SLRRTCMTLVideoView.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#import "base/SLRRTCLogging.h"
#import "base/SLRRTCVideoFrame.h"
#import "base/SLRRTCVideoFrameBuffer.h"
#import "components/video_frame_buffer/SLRRTCCVPixelBuffer.h"

#import "SLRRTCMTLI420Renderer.h"
#import "SLRRTCMTLNV12Renderer.h"
#import "SLRRTCMTLRGBRenderer.h"

// To avoid unreconized symbol linker errors, we're taking advantage of the objc runtime.
// Linking errors occur when compiling for architectures that don't support Metal.
#define MTKViewClass NSClassFromString(@"MTKView")
#define SLRRTCMTLNV12RendererClass NSClassFromString(@"SLRRTCMTLNV12Renderer")
#define SLRRTCMTLI420RendererClass NSClassFromString(@"SLRRTCMTLI420Renderer")
#define SLRRTCMTLRGBRendererClass NSClassFromString(@"SLRRTCMTLRGBRenderer")

@interface SLRRTCMTLVideoView () <MTKViewDelegate>
@property(nonatomic) SLRRTCMTLI420Renderer *rendererI420;
@property(nonatomic) SLRRTCMTLNV12Renderer *rendererNV12;
@property(nonatomic) SLRRTCMTLRGBRenderer *rendererRGB;
@property(nonatomic) MTKView *metalView;
@property(atomic) SLRRTCVideoFrame *videoFrame;
@property(nonatomic) CGSize videoFrameSize;
@property(nonatomic) int64_t lastFrameTimeNs;
@end

@implementation SLRRTCMTLVideoView

@synthesize delegate = _delegate;
@synthesize rendererI420 = _rendererI420;
@synthesize rendererNV12 = _rendererNV12;
@synthesize rendererRGB = _rendererRGB;
@synthesize metalView = _metalView;
@synthesize videoFrame = _videoFrame;
@synthesize videoFrameSize = _videoFrameSize;
@synthesize lastFrameTimeNs = _lastFrameTimeNs;
@synthesize rotationOverride = _rotationOverride;

- (instancetype)initWithFrame:(CGRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self configure];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aCoder {
  self = [super initWithCoder:aCoder];
  if (self) {
    [self configure];
  }
  return self;
}

- (BOOL)isEnabled {
  return !self.metalView.paused;
}

- (void)setEnabled:(BOOL)enabled {
  self.metalView.paused = !enabled;
}

- (UIViewContentMode)videoContentMode {
  return self.metalView.contentMode;
}

- (void)setVideoContentMode:(UIViewContentMode)mode {
  self.metalView.contentMode = mode;
}

#pragma mark - Private

+ (BOOL)isMetalAvailable {
#if defined(RTC_SUPPORTS_METAL)
  return MTLCreateSystemDefaultDevice() != nil;
#else
  return NO;
#endif
}

+ (MTKView *)createMetalView:(CGRect)frame {
  return [[MTKViewClass alloc] initWithFrame:frame];
}

+ (SLRRTCMTLNV12Renderer *)createNV12Renderer {
  return [[SLRRTCMTLNV12RendererClass alloc] init];
}

+ (SLRRTCMTLI420Renderer *)createI420Renderer {
  return [[SLRRTCMTLI420RendererClass alloc] init];
}

+ (SLRRTCMTLRGBRenderer *)createRGBRenderer {
  return [[SLRRTCMTLRGBRenderer alloc] init];
}

- (void)configure {
  NSAssert([SLRRTCMTLVideoView isMetalAvailable], @"Metal not availiable on this device");

  self.metalView = [SLRRTCMTLVideoView createMetalView:self.bounds];
  self.metalView.delegate = self;
  self.metalView.contentMode = UIViewContentModeScaleAspectFill;
  [self addSubview:self.metalView];
  self.videoFrameSize = CGSizeZero;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect bounds = self.bounds;
  self.metalView.frame = bounds;
  if (!CGSizeEqualToSize(self.videoFrameSize, CGSizeZero)) {
    self.metalView.drawableSize = [self drawableSize];
  } else {
    self.metalView.drawableSize = bounds.size;
  }
}

#pragma mark - MTKViewDelegate methods

- (void)drawInMTKView:(nonnull MTKView *)view {
  NSAssert(view == self.metalView, @"Receiving draw callbacks from foreign instance.");
  SLRRTCVideoFrame *videoFrame = self.videoFrame;
  // Skip rendering if we've already rendered this frame.
  if (!videoFrame || videoFrame.timeStampNs == self.lastFrameTimeNs) {
    return;
  }

  if (CGRectIsEmpty(view.bounds)) {
    return;
  }

  SLRRTCMTLRenderer *renderer;
  if ([videoFrame.buffer isKindOfClass:[SLRRTCCVPixelBuffer class]]) {
    SLRRTCCVPixelBuffer *buffer = (SLRRTCCVPixelBuffer*)videoFrame.buffer;
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(buffer.pixelBuffer);
    if (pixelFormat == kCVPixelFormatType_32BGRA || pixelFormat == kCVPixelFormatType_32ARGB) {
      if (!self.rendererRGB) {
        self.rendererRGB = [SLRRTCMTLVideoView createRGBRenderer];
        if (![self.rendererRGB addRenderingDestination:self.metalView]) {
          self.rendererRGB = nil;
          SLRRTCLogError(@"Failed to create RGB renderer");
          return;
        }
      }
      renderer = self.rendererRGB;
    } else {
      if (!self.rendererNV12) {
        self.rendererNV12 = [SLRRTCMTLVideoView createNV12Renderer];
        if (![self.rendererNV12 addRenderingDestination:self.metalView]) {
          self.rendererNV12 = nil;
          SLRRTCLogError(@"Failed to create NV12 renderer");
          return;
        }
      }
      renderer = self.rendererNV12;
    }
  } else {
    if (!self.rendererI420) {
      self.rendererI420 = [SLRRTCMTLVideoView createI420Renderer];
      if (![self.rendererI420 addRenderingDestination:self.metalView]) {
        self.rendererI420 = nil;
        SLRRTCLogError(@"Failed to create I420 renderer");
        return;
      }
    }
    renderer = self.rendererI420;
  }

  renderer.rotationOverride = self.rotationOverride;

  [renderer drawFrame:videoFrame];
  self.lastFrameTimeNs = videoFrame.timeStampNs;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}

#pragma mark -

- (void)setRotationOverride:(NSValue *)rotationOverride {
  _rotationOverride = rotationOverride;

  self.metalView.drawableSize = [self drawableSize];
  [self setNeedsLayout];
}

- (SLRRTCVideoRotation)frameRotation {
  if (self.rotationOverride) {
    SLRRTCVideoRotation rotation;
    if (@available(iOS 11, *)) {
      [self.rotationOverride getValue:&rotation size:sizeof(rotation)];
    } else {
      [self.rotationOverride getValue:&rotation];
    }
    return rotation;
  }

  return self.videoFrame.rotation;
}

- (CGSize)drawableSize {
  // Flip width/height if the rotations are not the same.
  CGSize videoFrameSize = self.videoFrameSize;
  SLRRTCVideoRotation frameRotation = [self frameRotation];

  BOOL useLandscape =
      (frameRotation == SLRRTCVideoRotation_0) || (frameRotation == SLRRTCVideoRotation_180);
  BOOL sizeIsLandscape = (self.videoFrame.rotation == SLRRTCVideoRotation_0) ||
      (self.videoFrame.rotation == SLRRTCVideoRotation_180);

  if (useLandscape == sizeIsLandscape) {
    return videoFrameSize;
  } else {
    return CGSizeMake(videoFrameSize.height, videoFrameSize.width);
  }
}

#pragma mark - SLRRTCVideoRenderer

- (void)setSize:(CGSize)size {
  __weak SLRRTCMTLVideoView *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    SLRRTCMTLVideoView *strongSelf = weakSelf;

    strongSelf.videoFrameSize = size;
    CGSize drawableSize = [strongSelf drawableSize];

    strongSelf.metalView.drawableSize = drawableSize;
    [strongSelf setNeedsLayout];
    [strongSelf.delegate videoView:self didChangeVideoSize:size];
  });
}

- (void)renderFrame:(nullable SLRRTCVideoFrame *)frame {
  if (!self.isEnabled) {
    return;
  }

  if (frame == nil) {
    SLRRTCLogInfo(@"Incoming frame is nil. Exiting render callback.");
    return;
  }
  self.videoFrame = frame;
}

@end
