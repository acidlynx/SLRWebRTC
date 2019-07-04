/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>

#include "rtc_base/gunit.h"

#import "components/audio/SLRRTCAudioSession+Private.h"

#import "components/audio/SLRRTCAudioSession.h"
#import "components/audio/SLRRTCAudioSessionConfiguration.h"

@interface SLRRTCAudioSession (UnitTesting)

- (instancetype)initWithAudioSession:(id)audioSession;

@end

@interface MockAVAudioSession : NSObject

@property (nonatomic, readwrite, assign) float outputVolume;

@end

@implementation MockAVAudioSession
@synthesize outputVolume = _outputVolume;
@end

@interface SLRRTCAudioSessionTestDelegate : NSObject <SLRRTCAudioSessionDelegate>

@property (nonatomic, readonly) float outputVolume;

@end

@implementation SLRRTCAudioSessionTestDelegate

@synthesize outputVolume = _outputVolume;

- (instancetype)init {
  if (self = [super init]) {
    _outputVolume = -1;
  }
  return self;
}

- (void)audioSessionDidBeginInterruption:(SLRRTCAudioSession *)session {
}

- (void)audioSessionDidEndInterruption:(SLRRTCAudioSession *)session
                   shouldResumeSession:(BOOL)shouldResumeSession {
}

- (void)audioSessionDidChangeRoute:(SLRRTCAudioSession *)session
           reason:(AVAudioSessionRouteChangeReason)reason
    previousRoute:(AVAudioSessionRouteDescription *)previousRoute {
}

- (void)audioSessionMediaServerTerminated:(SLRRTCAudioSession *)session {
}

- (void)audioSessionMediaServerReset:(SLRRTCAudioSession *)session {
}

- (void)audioSessionShouldConfigure:(SLRRTCAudioSession *)session {
}

- (void)audioSessionShouldUnconfigure:(SLRRTCAudioSession *)session {
}

- (void)audioSession:(SLRRTCAudioSession *)audioSession
    didChangeOutputVolume:(float)outputVolume {
  _outputVolume = outputVolume;
}

@end

// A delegate that adds itself to the audio session on init and removes itself
// in its dealloc.
@interface SLRRTCTestRemoveOnDeallocDelegate : SLRRTCAudioSessionTestDelegate
@end

@implementation SLRRTCTestRemoveOnDeallocDelegate

- (instancetype)init {
  if (self = [super init]) {
    SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
    [session addDelegate:self];
  }
  return self;
}

- (void)dealloc {
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
  [session removeDelegate:self];
}

@end


@interface SLRRTCAudioSessionTest : NSObject

- (void)testLockForConfiguration;

@end

@implementation SLRRTCAudioSessionTest

- (void)testLockForConfiguration {
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];

  for (size_t i = 0; i < 2; i++) {
    [session lockForConfiguration];
    EXPECT_TRUE(session.isLocked);
  }
  for (size_t i = 0; i < 2; i++) {
    EXPECT_TRUE(session.isLocked);
    [session unlockForConfiguration];
  }
  EXPECT_FALSE(session.isLocked);
}

- (void)testAddAndRemoveDelegates {
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
  NSMutableArray *delegates = [NSMutableArray array];
  const size_t count = 5;
  for (size_t i = 0; i < count; ++i) {
    SLRRTCAudioSessionTestDelegate *delegate =
        [[SLRRTCAudioSessionTestDelegate alloc] init];
    [session addDelegate:delegate];
    [delegates addObject:delegate];
    EXPECT_EQ(i + 1, session.delegates.size());
  }
  [delegates enumerateObjectsUsingBlock:^(SLRRTCAudioSessionTestDelegate *obj,
                                          NSUInteger idx,
                                          BOOL *stop) {
    [session removeDelegate:obj];
  }];
  EXPECT_EQ(0u, session.delegates.size());
}

- (void)testPushDelegate {
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
  NSMutableArray *delegates = [NSMutableArray array];
  const size_t count = 2;
  for (size_t i = 0; i < count; ++i) {
    SLRRTCAudioSessionTestDelegate *delegate =
        [[SLRRTCAudioSessionTestDelegate alloc] init];
    [session addDelegate:delegate];
    [delegates addObject:delegate];
  }
  // Test that it gets added to the front of the list.
  SLRRTCAudioSessionTestDelegate *pushedDelegate =
      [[SLRRTCAudioSessionTestDelegate alloc] init];
  [session pushDelegate:pushedDelegate];
  EXPECT_TRUE(pushedDelegate == session.delegates[0]);

  // Test that it stays at the front of the list.
  for (size_t i = 0; i < count; ++i) {
    SLRRTCAudioSessionTestDelegate *delegate =
        [[SLRRTCAudioSessionTestDelegate alloc] init];
    [session addDelegate:delegate];
    [delegates addObject:delegate];
  }
  EXPECT_TRUE(pushedDelegate == session.delegates[0]);

  // Test that the next one goes to the front too.
  pushedDelegate = [[SLRRTCAudioSessionTestDelegate alloc] init];
  [session pushDelegate:pushedDelegate];
  EXPECT_TRUE(pushedDelegate == session.delegates[0]);
}

// Tests that delegates added to the audio session properly zero out. This is
// checking an implementation detail (that vectors of __weak work as expected).
- (void)testZeroingWeakDelegate {
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
  @autoreleasepool {
    // Add a delegate to the session. There should be one delegate at this
    // point.
    SLRRTCAudioSessionTestDelegate *delegate =
        [[SLRRTCAudioSessionTestDelegate alloc] init];
    [session addDelegate:delegate];
    EXPECT_EQ(1u, session.delegates.size());
    EXPECT_TRUE(session.delegates[0]);
  }
  // The previously created delegate should've de-alloced, leaving a nil ptr.
  EXPECT_FALSE(session.delegates[0]);
  SLRRTCAudioSessionTestDelegate *delegate =
      [[SLRRTCAudioSessionTestDelegate alloc] init];
  [session addDelegate:delegate];
  // On adding a new delegate, nil ptrs should've been cleared.
  EXPECT_EQ(1u, session.delegates.size());
  EXPECT_TRUE(session.delegates[0]);
}

// Tests that we don't crash when removing delegates in dealloc.
// Added as a regression test.
- (void)testRemoveDelegateOnDealloc {
  @autoreleasepool {
    SLRRTCTestRemoveOnDeallocDelegate *delegate =
        [[SLRRTCTestRemoveOnDeallocDelegate alloc] init];
    EXPECT_TRUE(delegate);
  }
  SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
  EXPECT_EQ(0u, session.delegates.size());
}

- (void)testAudioSessionActivation {
  SLRRTCAudioSession *audioSession = [SLRRTCAudioSession sharedInstance];
  EXPECT_EQ(0, audioSession.activationCount);
  [audioSession audioSessionDidActivate:[AVAudioSession sharedInstance]];
  EXPECT_EQ(1, audioSession.activationCount);
  [audioSession audioSessionDidDeactivate:[AVAudioSession sharedInstance]];
  EXPECT_EQ(0, audioSession.activationCount);
}

// Hack - fixes OCMVerify link error
// Link error is: Undefined symbols for architecture i386:
// "OCMMakeLocation(objc_object*, char const*, int)", referenced from:
// -[SLRRTCAudioSessionTest testConfigureWebRTCSession] in SLRRTCAudioSessionTest.o
// ld: symbol(s) not found for architecture i386
// REASON: https://github.com/erikdoe/ocmock/issues/238
OCMLocation *OCMMakeLocation(id testCase, const char *fileCString, int line){
  return [OCMLocation locationWithTestCase:testCase
                                      file:[NSString stringWithUTF8String:fileCString]
                                      line:line];
}

- (void)testConfigureWebRTCSession {
  NSError *error = nil;

  void (^setActiveBlock)(NSInvocation *invocation) = ^(NSInvocation *invocation) {
    __autoreleasing NSError **retError;
    [invocation getArgument:&retError atIndex:4];
    *retError = [NSError errorWithDomain:@"AVAudioSession"
                                    code:AVAudioSessionErrorInsufficientPriority
                                userInfo:nil];
    BOOL failure = NO;
    [invocation setReturnValue:&failure];
  };

  id mockAVAudioSession = OCMPartialMock([AVAudioSession sharedInstance]);
  OCMStub([[mockAVAudioSession ignoringNonObjectArgs]
      setActive:YES withOptions:0 error:((NSError __autoreleasing **)[OCMArg anyPointer])]).
      andDo(setActiveBlock);

  id mockAudioSession = OCMPartialMock([SLRRTCAudioSession sharedInstance]);
  OCMStub([mockAudioSession session]).andReturn(mockAVAudioSession);

  SLRRTCAudioSession *audioSession = mockAudioSession;
  EXPECT_EQ(0, audioSession.activationCount);
  [audioSession lockForConfiguration];
  EXPECT_TRUE([audioSession checkLock:nil]);
  // configureWebRTCSession is forced to fail in the above mock interface,
  // so activationCount should remain 0
  OCMExpect([[mockAVAudioSession ignoringNonObjectArgs]
      setActive:YES withOptions:0 error:((NSError __autoreleasing **)[OCMArg anyPointer])]).
      andDo(setActiveBlock);
  OCMExpect([mockAudioSession session]).andReturn(mockAVAudioSession);
  EXPECT_FALSE([audioSession configureWebRTCSession:&error]);
  EXPECT_EQ(0, audioSession.activationCount);

  id session = audioSession.session;
  EXPECT_EQ(session, mockAVAudioSession);
  EXPECT_EQ(NO, [mockAVAudioSession setActive:YES withOptions:0 error:&error]);
  [audioSession unlockForConfiguration];

  OCMVerify([mockAudioSession session]);
  OCMVerify([[mockAVAudioSession ignoringNonObjectArgs] setActive:YES withOptions:0 error:&error]);
  OCMVerify([[mockAVAudioSession ignoringNonObjectArgs] setActive:NO withOptions:0 error:&error]);

  [mockAVAudioSession stopMocking];
  [mockAudioSession stopMocking];
}

- (void)testAudioVolumeDidNotify {
  MockAVAudioSession *mockAVAudioSession = [[MockAVAudioSession alloc] init];
  SLRRTCAudioSession *session = [[SLRRTCAudioSession alloc] initWithAudioSession:mockAVAudioSession];
  SLRRTCAudioSessionTestDelegate *delegate =
      [[SLRRTCAudioSessionTestDelegate alloc] init];
  [session addDelegate:delegate];

  float expectedVolume = 0.75;
  mockAVAudioSession.outputVolume = expectedVolume;

  EXPECT_EQ(expectedVolume, delegate.outputVolume);
}

@end

namespace webrtc {

class AudioSessionTest : public ::testing::Test {
 protected:
  void TearDown() override {
    SLRRTCAudioSession *session = [SLRRTCAudioSession sharedInstance];
    for (id<SLRRTCAudioSessionDelegate> delegate : session.delegates) {
      [session removeDelegate:delegate];
    }
  }
};

TEST_F(AudioSessionTest, LockForConfiguration) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testLockForConfiguration];
}

TEST_F(AudioSessionTest, AddAndRemoveDelegates) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testAddAndRemoveDelegates];
}

TEST_F(AudioSessionTest, PushDelegate) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testPushDelegate];
}

TEST_F(AudioSessionTest, ZeroingWeakDelegate) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testZeroingWeakDelegate];
}

TEST_F(AudioSessionTest, RemoveDelegateOnDealloc) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testRemoveDelegateOnDealloc];
}

TEST_F(AudioSessionTest, AudioSessionActivation) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testAudioSessionActivation];
}

TEST_F(AudioSessionTest, ConfigureWebRTCSession) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testConfigureWebRTCSession];
}

TEST_F(AudioSessionTest, AudioVolumeDidNotify) {
  SLRRTCAudioSessionTest *test = [[SLRRTCAudioSessionTest alloc] init];
  [test testAudioVolumeDidNotify];
}

}  // namespace webrtc
