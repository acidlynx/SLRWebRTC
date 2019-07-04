/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "base/SLRRTCVideoFrame.h"

RTC_EXTERN const char kRTCVertexShaderSource[];

RTC_EXTERN GLuint SLRRTCCreateShader(GLenum type, const GLchar* source);
RTC_EXTERN GLuint SLRRTCCreateProgram(GLuint vertexShader, GLuint fragmentShader);
RTC_EXTERN GLuint
SLRRTCCreateProgramFromFragmentSource(const char fragmentShaderSource[]);
RTC_EXTERN BOOL SLRRTCCreateVertexBuffer(GLuint* vertexBuffer,
                                      GLuint* vertexArray);
RTC_EXTERN void SLRRTCSetVertexData(SLRRTCVideoRotation rotation);
