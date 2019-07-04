/*
 *  Copyright 2018 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "api/logging/SLRRTCCallbackLogger.h"

#import <XCTest/XCTest.h>

@interface SLRRTCCallbackLoggerTests : XCTestCase

@property(nonatomic, strong) SLRRTCCallbackLogger *logger;

@end

@implementation SLRRTCCallbackLoggerTests

@synthesize logger;

- (void)setUp {
  self.logger = [[SLRRTCCallbackLogger alloc] init];
}

- (void)tearDown {
  self.logger = nil;
}

- (void)testDefaultSeverityLevel {
  XCTAssertEqual(self.logger.severity, SLRRTCLoggingSeverityInfo);
}

- (void)testCallbackGetsCalledForAppropriateLevel {
  self.logger.severity = SLRRTCLoggingSeverityWarning;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"callbackWarning"];

  [self.logger start:^(NSString *message) {
    XCTAssertTrue([message hasSuffix:@"Horrible error\n"]);
    [callbackExpectation fulfill];
  }];

  SLRRTCLogError("Horrible error");

  [self waitForExpectations:@[ callbackExpectation ] timeout:10.0];
}

- (void)testCallbackWithSeverityGetsCalledForAppropriateLevel {
  self.logger.severity = SLRRTCLoggingSeverityWarning;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"callbackWarning"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity severity) {
        XCTAssertTrue([message hasSuffix:@"Horrible error\n"]);
        XCTAssertEqual(severity, SLRRTCLoggingSeverityError);
        [callbackExpectation fulfill];
      }];

  SLRRTCLogError("Horrible error");

  [self waitForExpectations:@[ callbackExpectation ] timeout:10.0];
}

- (void)testCallbackDoesNotGetCalledForOtherLevels {
  self.logger.severity = SLRRTCLoggingSeverityError;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"callbackError"];

  [self.logger start:^(NSString *message) {
    XCTAssertTrue([message hasSuffix:@"Horrible error\n"]);
    [callbackExpectation fulfill];
  }];

  SLRRTCLogInfo("Just some info");
  SLRRTCLogWarning("Warning warning");
  SLRRTCLogError("Horrible error");

  [self waitForExpectations:@[ callbackExpectation ] timeout:10.0];
}

- (void)testCallbackWithSeverityDoesNotGetCalledForOtherLevels {
  self.logger.severity = SLRRTCLoggingSeverityError;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"callbackError"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity severity) {
        XCTAssertTrue([message hasSuffix:@"Horrible error\n"]);
        XCTAssertEqual(severity, SLRRTCLoggingSeverityError);
        [callbackExpectation fulfill];
      }];

  SLRRTCLogInfo("Just some info");
  SLRRTCLogWarning("Warning warning");
  SLRRTCLogError("Horrible error");

  [self waitForExpectations:@[ callbackExpectation ] timeout:10.0];
}

- (void)testCallbackDoesNotgetCalledForSeverityNone {
  self.logger.severity = SLRRTCLoggingSeverityNone;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"unexpectedCallback"];

  [self.logger start:^(NSString *message) {
    [callbackExpectation fulfill];
    XCTAssertTrue(false);
  }];

  SLRRTCLogInfo("Just some info");
  SLRRTCLogWarning("Warning warning");
  SLRRTCLogError("Horrible error");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testCallbackWithSeverityDoesNotgetCalledForSeverityNone {
  self.logger.severity = SLRRTCLoggingSeverityNone;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"unexpectedCallback"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity severity) {
        [callbackExpectation fulfill];
        XCTAssertTrue(false);
      }];

  SLRRTCLogInfo("Just some info");
  SLRRTCLogWarning("Warning warning");
  SLRRTCLogError("Horrible error");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testStartingWithNilCallbackDoesNotCrash {
  [self.logger start:nil];

  SLRRTCLogError("Horrible error");
}

- (void)testStartingWithNilCallbackWithSeverityDoesNotCrash {
  [self.logger startWithMessageAndSeverityHandler:nil];

  SLRRTCLogError("Horrible error");
}

- (void)testStopCallbackLogger {
  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"stopped"];

  [self.logger start:^(NSString *message) {
    [callbackExpectation fulfill];
  }];

  [self.logger stop];

  SLRRTCLogInfo("Just some info");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testStopCallbackWithSeverityLogger {
  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"stopped"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity loggingServerity) {
        [callbackExpectation fulfill];
      }];

  [self.logger stop];

  SLRRTCLogInfo("Just some info");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testDestroyingCallbackLogger {
  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"destroyed"];

  [self.logger start:^(NSString *message) {
    [callbackExpectation fulfill];
  }];

  self.logger = nil;

  SLRRTCLogInfo("Just some info");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testDestroyingCallbackWithSeverityLogger {
  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"destroyed"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity loggingServerity) {
        [callbackExpectation fulfill];
      }];

  self.logger = nil;

  SLRRTCLogInfo("Just some info");

  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ callbackExpectation ] timeout:1.0];
  XCTAssertEqual(result, XCTWaiterResultTimedOut);
}

- (void)testCallbackWithSeverityLoggerCannotStartTwice {
  self.logger.severity = SLRRTCLoggingSeverityWarning;

  XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"callbackWarning"];

  [self.logger
      startWithMessageAndSeverityHandler:^(NSString *message, SLRRTCLoggingSeverity loggingServerity) {
        XCTAssertTrue([message hasSuffix:@"Horrible error\n"]);
        XCTAssertEqual(loggingServerity, SLRRTCLoggingSeverityError);
        [callbackExpectation fulfill];
      }];

  [self.logger start:^(NSString *message) {
    [callbackExpectation fulfill];
    XCTAssertTrue(false);
  }];

  SLRRTCLogError("Horrible error");

  [self waitForExpectations:@[ callbackExpectation ] timeout:10.0];
}

@end
