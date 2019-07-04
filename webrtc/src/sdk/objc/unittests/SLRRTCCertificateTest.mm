/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
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
#import "api/peerconnection/SLRRTCIceServer.h"
#import "api/peerconnection/SLRRTCMediaConstraints.h"
#import "api/peerconnection/SLRRTCPeerConnection.h"
#import "api/peerconnection/SLRRTCPeerConnectionFactory.h"
#import "helpers/NSString+StdString.h"

@interface SLRRTCCertificateTest : NSObject
- (void)testCertificateIsUsedInConfig;
@end

@implementation SLRRTCCertificateTest

- (void)testCertificateIsUsedInConfig {
  SLRRTCConfiguration *originalConfig = [[SLRRTCConfiguration alloc] init];

  NSArray *urlStrings = @[ @"stun:stun1.example.net" ];
  SLRRTCIceServer *server = [[SLRRTCIceServer alloc] initWithURLStrings:urlStrings];
  originalConfig.iceServers = @[ server ];

  // Generate a new certificate.
  SLRRTCCertificate *originalCertificate = [SLRRTCCertificate generateCertificateWithParams:@{
    @"expires" : @100000,
    @"name" : @"RSASSA-PKCS1-v1_5"
  }];

  // Store certificate in configuration.
  originalConfig.certificate = originalCertificate;

  SLRRTCMediaConstraints *contraints =
      [[SLRRTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:nil];
  SLRRTCPeerConnectionFactory *factory = [[SLRRTCPeerConnectionFactory alloc] init];

  // Create PeerConnection with this certificate.
  SLRRTCPeerConnection *peerConnection =
      [factory peerConnectionWithConfiguration:originalConfig constraints:contraints delegate:nil];

  // Retrieve certificate from the configuration.
  SLRRTCConfiguration *retrievedConfig = peerConnection.configuration;

  // Extract PEM strings from original certificate.
  std::string originalPrivateKeyField = [[originalCertificate private_key] UTF8String];
  std::string originalCertificateField = [[originalCertificate certificate] UTF8String];

  // Extract PEM strings from certificate retrieved from configuration.
  SLRRTCCertificate *retrievedCertificate = retrievedConfig.certificate;
  std::string retrievedPrivateKeyField = [[retrievedCertificate private_key] UTF8String];
  std::string retrievedCertificateField = [[retrievedCertificate certificate] UTF8String];

  // Check that the original certificate and retrieved certificate match.
  EXPECT_EQ(originalPrivateKeyField, retrievedPrivateKeyField);
  EXPECT_EQ(retrievedCertificateField, retrievedCertificateField);
}

@end

TEST(CertificateTest, DISABLED_CertificateIsUsedInConfig) {
  SLRRTCCertificateTest *test = [[SLRRTCCertificateTest alloc] init];
  [test testCertificateIsUsedInConfig];
}
