/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#include <vector>

#include "rtc_base/gunit.h"

#import "api/peerconnection/SLRRTCConfiguration+Private.h"
#import "api/peerconnection/SLRRTCConfiguration.h"
#import "api/peerconnection/SLRRTCCryptoOptions.h"
#import "api/peerconnection/SLRRTCIceServer.h"
#import "api/peerconnection/SLRRTCMediaConstraints.h"
#import "api/peerconnection/SLRRTCPeerConnection.h"
#import "api/peerconnection/SLRRTCPeerConnectionFactory.h"
#import "helpers/NSString+StdString.h"

@interface SLRRTCPeerConnectionTest : NSObject
- (void)testConfigurationGetter;
@end

@implementation SLRRTCPeerConnectionTest

- (void)testConfigurationGetter {
  NSArray *urlStrings = @[ @"stun:stun1.example.net" ];
  SLRRTCIceServer *server = [[SLRRTCIceServer alloc] initWithURLStrings:urlStrings];

  SLRRTCConfiguration *config = [[SLRRTCConfiguration alloc] init];
  config.iceServers = @[ server ];
  config.iceTransportPolicy = SLRRTCIceTransportPolicyRelay;
  config.bundlePolicy = SLRRTCBundlePolicyMaxBundle;
  config.rtcpMuxPolicy = SLRRTCRtcpMuxPolicyNegotiate;
  config.tcpCandidatePolicy = SLRRTCTcpCandidatePolicyDisabled;
  config.candidateNetworkPolicy = SLRRTCCandidateNetworkPolicyLowCost;
  const int maxPackets = 60;
  const int timeout = 1500;
  const int interval = 2000;
  config.audioJitterBufferMaxPackets = maxPackets;
  config.audioJitterBufferFastAccelerate = YES;
  config.iceConnectionReceivingTimeout = timeout;
  config.iceBackupCandidatePairPingInterval = interval;
  config.continualGatheringPolicy =
      SLRRTCContinualGatheringPolicyGatherContinually;
  config.shouldPruneTurnPorts = YES;
  config.activeResetSrtpParams = YES;
  config.cryptoOptions = [[SLRRTCCryptoOptions alloc] initWithSrtpEnableGcmCryptoSuites:YES
                                                 srtpEnableAes128Sha1_32CryptoCipher:YES
                                              srtpEnableEncryptedRtpHeaderExtensions:NO
                                                        sframeRequireFrameEncryption:NO];

  SLRRTCMediaConstraints *contraints = [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{}
      optionalConstraints:nil];
  SLRRTCPeerConnectionFactory *factory = [[SLRRTCPeerConnectionFactory alloc] init];

  SLRRTCConfiguration *newConfig;
  @autoreleasepool {
    SLRRTCPeerConnection *peerConnection =
        [factory peerConnectionWithConfiguration:config constraints:contraints delegate:nil];
    newConfig = peerConnection.configuration;

    EXPECT_TRUE([peerConnection setBweMinBitrateBps:[NSNumber numberWithInt:100000]
                                  currentBitrateBps:[NSNumber numberWithInt:5000000]
                                      maxBitrateBps:[NSNumber numberWithInt:500000000]]);
    EXPECT_FALSE([peerConnection setBweMinBitrateBps:[NSNumber numberWithInt:2]
                                   currentBitrateBps:[NSNumber numberWithInt:1]
                                       maxBitrateBps:nil]);
  }

  EXPECT_EQ([config.iceServers count], [newConfig.iceServers count]);
  SLRRTCIceServer *newServer = newConfig.iceServers[0];
  SLRRTCIceServer *origServer = config.iceServers[0];
  std::string origUrl = origServer.urlStrings.firstObject.UTF8String;
  std::string url = newServer.urlStrings.firstObject.UTF8String;
  EXPECT_EQ(origUrl, url);

  EXPECT_EQ(config.iceTransportPolicy, newConfig.iceTransportPolicy);
  EXPECT_EQ(config.bundlePolicy, newConfig.bundlePolicy);
  EXPECT_EQ(config.rtcpMuxPolicy, newConfig.rtcpMuxPolicy);
  EXPECT_EQ(config.tcpCandidatePolicy, newConfig.tcpCandidatePolicy);
  EXPECT_EQ(config.candidateNetworkPolicy, newConfig.candidateNetworkPolicy);
  EXPECT_EQ(config.audioJitterBufferMaxPackets, newConfig.audioJitterBufferMaxPackets);
  EXPECT_EQ(config.audioJitterBufferFastAccelerate, newConfig.audioJitterBufferFastAccelerate);
  EXPECT_EQ(config.iceConnectionReceivingTimeout, newConfig.iceConnectionReceivingTimeout);
  EXPECT_EQ(config.iceBackupCandidatePairPingInterval,
            newConfig.iceBackupCandidatePairPingInterval);
  EXPECT_EQ(config.continualGatheringPolicy, newConfig.continualGatheringPolicy);
  EXPECT_EQ(config.shouldPruneTurnPorts, newConfig.shouldPruneTurnPorts);
  EXPECT_EQ(config.activeResetSrtpParams, newConfig.activeResetSrtpParams);
  EXPECT_EQ(config.cryptoOptions.srtpEnableGcmCryptoSuites,
            newConfig.cryptoOptions.srtpEnableGcmCryptoSuites);
  EXPECT_EQ(config.cryptoOptions.srtpEnableAes128Sha1_32CryptoCipher,
            newConfig.cryptoOptions.srtpEnableAes128Sha1_32CryptoCipher);
  EXPECT_EQ(config.cryptoOptions.srtpEnableEncryptedRtpHeaderExtensions,
            newConfig.cryptoOptions.srtpEnableEncryptedRtpHeaderExtensions);
  EXPECT_EQ(config.cryptoOptions.sframeRequireFrameEncryption,
            newConfig.cryptoOptions.sframeRequireFrameEncryption);
}

@end

TEST(SLRRTCPeerConnectionTest, ConfigurationGetterTest) {
  @autoreleasepool {
    SLRRTCPeerConnectionTest *test = [[SLRRTCPeerConnectionTest alloc] init];
    [test testConfigurationGetter];
  }
}
