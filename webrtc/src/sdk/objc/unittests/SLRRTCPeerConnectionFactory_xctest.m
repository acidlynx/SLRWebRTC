/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "api/peerconnection/SLRRTCAudioSource.h"
#import "api/peerconnection/SLRRTCConfiguration.h"
#import "api/peerconnection/SLRRTCDataChannel.h"
#import "api/peerconnection/SLRRTCDataChannelConfiguration.h"
#import "api/peerconnection/SLRRTCMediaConstraints.h"
#import "api/peerconnection/SLRRTCMediaStreamTrack.h"
#import "api/peerconnection/SLRRTCPeerConnection.h"
#import "api/peerconnection/SLRRTCPeerConnectionFactory.h"
#import "api/peerconnection/SLRRTCRtpReceiver.h"
#import "api/peerconnection/SLRRTCRtpSender.h"
#import "api/peerconnection/SLRRTCRtpTransceiver.h"
#import "api/peerconnection/SLRRTCVideoSource.h"

#import <XCTest/XCTest.h>

@interface SLRRTCPeerConnectionFactoryTests : XCTestCase
@end

@implementation SLRRTCPeerConnectionFactoryTests

- (void)testPeerConnectionLifetime {
  @autoreleasepool {
    SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];

    SLRRTCMediaConstraints *constraints =
        [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];

    SLRRTCPeerConnectionFactory *factory;
    SLRRTCPeerConnection *peerConnection;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      peerConnection =
          [factory peerConnectionWithConfiguration:config constraints:constraints delegate:nil];
      [peerConnection close];
      factory = nil;
    }
    peerConnection = nil;
  }

  XCTAssertTrue(true, @"Expect test does not crash");
}

- (void)testMediaStreamLifetime {
  @autoreleasepool {
    SLRRTCPeerConnectionFactory *factory;
    SLRRTCMediaStream *mediaStream;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      mediaStream = [factory mediaStreamWithStreamId:@"mediaStream"];
      factory = nil;
    }
    mediaStream = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testDataChannelLifetime {
  @autoreleasepool {
    SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];
    SLRRTCMediaConstraints *constraints =
        [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];
    SLRRTCDataChannelConfiguration *dataChannelConfig = [[SLRRTCDataChannelConfiguration alloc] init];

    SLRRTCPeerConnectionFactory *factory;
    SLRRTCPeerConnection *peerConnection;
    SLRRTCDataChannel *dataChannel;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      peerConnection =
          [factory peerConnectionWithConfiguration:config constraints:constraints delegate:nil];
      dataChannel =
          [peerConnection dataChannelForLabel:@"test_channel" configuration:dataChannelConfig];
      XCTAssertNotNil(dataChannel);
      [peerConnection close];
      peerConnection = nil;
      factory = nil;
    }
    dataChannel = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testRTCRtpTransceiverLifetime {
  @autoreleasepool {
    SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];
    config.sdpSemantics = SLRRTCSdpSemanticsUnifiedPlan;
    SLRRTCMediaConstraints *contraints =
        [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];
    SLRRTCRtpTransceiverInit *init = [[SLRRTCRtpTransceiverInit alloc] init];

    SLRRTCPeerConnectionFactory *factory;
    SLRRTCPeerConnection *peerConnection;
    SLRRTCRtpTransceiver *tranceiver;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      peerConnection =
          [factory peerConnectionWithConfiguration:config constraints:contraints delegate:nil];
      tranceiver = [peerConnection addTransceiverOfType:SLRRTCRtpMediaTypeAudio init:init];
      XCTAssertNotNil(tranceiver);
      [peerConnection close];
      peerConnection = nil;
      factory = nil;
    }
    tranceiver = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testRTCRtpSenderLifetime {
  @autoreleasepool {
    SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];
    SLRRTCMediaConstraints *constraints =
        [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];

    SLRRTCPeerConnectionFactory *factory;
    SLRRTCPeerConnection *peerConnection;
    SLRRTCRtpSender *sender;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      peerConnection =
          [factory peerConnectionWithConfiguration:config constraints:constraints delegate:nil];
      sender = [peerConnection senderWithKind:kRTCMediaStreamTrackKindVideo streamId:@"stream"];
      XCTAssertNotNil(sender);
      [peerConnection close];
      peerConnection = nil;
      factory = nil;
    }
    sender = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testRTCRtpReceiverLifetime {
  @autoreleasepool {
    SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];
    SLRRTCMediaConstraints *constraints =
        [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];

    SLRRTCPeerConnectionFactory *factory;
    SLRRTCPeerConnection *pc1;
    SLRRTCPeerConnection *pc2;

    NSArray<SLRRTCRtpReceiver *> *receivers1;
    NSArray<SLRRTCRtpReceiver *> *receivers2;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      pc1 = [factory peerConnectionWithConfiguration:config constraints:constraints delegate:nil];
      [pc1 senderWithKind:kRTCMediaStreamTrackKindAudio streamId:@"stream"];

      pc2 = [factory peerConnectionWithConfiguration:config constraints:constraints delegate:nil];
      [pc2 senderWithKind:kRTCMediaStreamTrackKindAudio streamId:@"stream"];

      NSTimeInterval negotiationTimeout = 15;
      XCTAssertTrue([self negotiatePeerConnection:pc1
                               withPeerConnection:pc2
                               negotiationTimeout:negotiationTimeout]);

      XCTAssertEqual(pc1.signalingState, SLRRTCSignalingStateStable);
      XCTAssertEqual(pc2.signalingState, SLRRTCSignalingStateStable);

      receivers1 = pc1.receivers;
      receivers2 = pc2.receivers;
      XCTAssertTrue(receivers1.count > 0);
      XCTAssertTrue(receivers2.count > 0);
      [pc1 close];
      [pc2 close];
      pc1 = nil;
      pc2 = nil;
      factory = nil;
    }
    receivers1 = nil;
    receivers2 = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testAudioSourceLifetime {
  @autoreleasepool {
    SLRRTCPeerConnectionFactory *factory;
    SLRRTCAudioSource *audioSource;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      audioSource = [factory audioSourceWithConstraints:nil];
      XCTAssertNotNil(audioSource);
      factory = nil;
    }
    audioSource = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testVideoSourceLifetime {
  @autoreleasepool {
    SLRRTCPeerConnectionFactory *factory;
    SLRRTCVideoSource *videoSource;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      videoSource = [factory videoSource];
      XCTAssertNotNil(videoSource);
      factory = nil;
    }
    videoSource = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testAudioTrackLifetime {
  @autoreleasepool {
    SLRRTCPeerConnectionFactory *factory;
    SLRRTCAudioTrack *audioTrack;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      audioTrack = [factory audioTrackWithTrackId:@"audioTrack"];
      XCTAssertNotNil(audioTrack);
      factory = nil;
    }
    audioTrack = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (void)testVideoTrackLifetime {
  @autoreleasepool {
    SLRRTCPeerConnectionFactory *factory;
    SLRRTCVideoTrack *videoTrack;

    @autoreleasepool {
      factory = [[SLRRTCPeerConnectionFactory alloc] init];
      videoTrack = [factory videoTrackWithSource:[factory videoSource] trackId:@"videoTrack"];
      XCTAssertNotNil(videoTrack);
      factory = nil;
    }
    videoTrack = nil;
  }

  XCTAssertTrue(true, "Expect test does not crash");
}

- (bool)negotiatePeerConnection:(SLRRTCPeerConnection *)pc1
             withPeerConnection:(SLRRTCPeerConnection *)pc2
             negotiationTimeout:(NSTimeInterval)timeout {
  __weak SLRRTCPeerConnection *weakPC1 = pc1;
  __weak SLRRTCPeerConnection *weakPC2 = pc2;
  SLRRTCMediaConstraints *sdpConstraints =
      [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{
        kRTCMediaConstraintsOfferToReceiveAudio : kRTCMediaConstraintsValueTrue
      }
                                            optionalConstraints:nil];

  dispatch_semaphore_t negotiatedSem = dispatch_semaphore_create(0);
  [weakPC1 offerForConstraints:sdpConstraints
             completionHandler:^(SLRRTCSessionDescription *offer, NSError *error) {
               XCTAssertNil(error);
               XCTAssertNotNil(offer);
               [weakPC1
                   setLocalDescription:offer
                     completionHandler:^(NSError *error) {
                       XCTAssertNil(error);
                       [weakPC2
                           setRemoteDescription:offer
                              completionHandler:^(NSError *error) {
                                XCTAssertNil(error);
                                [weakPC2
                                    answerForConstraints:sdpConstraints
                                       completionHandler:^(SLRRTCSessionDescription *answer,
                                                           NSError *error) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(answer);
                                         [weakPC2
                                             setLocalDescription:answer
                                               completionHandler:^(NSError *error) {
                                                 XCTAssertNil(error);
                                                 [weakPC1
                                                     setRemoteDescription:answer
                                                        completionHandler:^(NSError *error) {
                                                          XCTAssertNil(error);
                                                          dispatch_semaphore_signal(negotiatedSem);
                                                        }];
                                               }];
                                       }];
                              }];
                     }];
             }];

  return 0 ==
      dispatch_semaphore_wait(negotiatedSem,
                              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
}

@end
