//
//  Copyright (c) 2019 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@import Firebase;

@interface ImagePreparation : NSObject

- (FIRVisionImage *)createImageWithUIImage:(UIImage *)uiImage;
- (FIRVisionDetectorImageOrientation)
    imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
                           cameraPosition:(AVCaptureDevicePosition)cameraPosition;
- (FIRVisionImage *)createImageWithBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@implementation ImagePreparation

- (FIRVisionImage *)createImageWithUIImage:(UIImage *)uiImage {
  // [START create_image_with_uiimage]
  FIRVisionImage *image = [[FIRVisionImage alloc] initWithImage:uiImage];
  // [END create_image_with_uiimage]
  return image;
}

// [START image_orientation_from_device_orientation]
- (FIRVisionDetectorImageOrientation)
    imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
                           cameraPosition:(AVCaptureDevicePosition)cameraPosition {
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      if (cameraPosition == AVCaptureDevicePositionFront) {
        return FIRVisionDetectorImageOrientationLeftTop;
      } else {
        return FIRVisionDetectorImageOrientationRightTop;
      }
    case UIDeviceOrientationLandscapeLeft:
      if (cameraPosition == AVCaptureDevicePositionFront) {
        return FIRVisionDetectorImageOrientationBottomLeft;
      } else {
        return FIRVisionDetectorImageOrientationTopLeft;
      }
    case UIDeviceOrientationPortraitUpsideDown:
      if (cameraPosition == AVCaptureDevicePositionFront) {
        return FIRVisionDetectorImageOrientationRightBottom;
      } else {
        return FIRVisionDetectorImageOrientationLeftBottom;
      }
    case UIDeviceOrientationLandscapeRight:
      if (cameraPosition == AVCaptureDevicePositionFront) {
        return FIRVisionDetectorImageOrientationTopRight;
      } else {
        return FIRVisionDetectorImageOrientationBottomRight;
      }
    default:
      return FIRVisionDetectorImageOrientationTopLeft;
  }
}
// [END image_orientation_from_device_orientation]

- (FIRVisionImage *)createImageWithBuffer:(CMSampleBufferRef)sampleBuffer {
  // [START create_image_metadata]
  FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
  AVCaptureDevicePosition cameraPosition =
      AVCaptureDevicePositionBack;  // Set to the capture device you used.
  metadata.orientation =
      [self imageOrientationFromDeviceOrientation:UIDevice.currentDevice.orientation
                                   cameraPosition:cameraPosition];
  // [END create_image_metadata]
    
  // [START create_image_with_buffer]
  FIRVisionImage *image = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
  image.metadata = metadata;
  // [END create_image_with_buffer]

  return image;
}

@end
