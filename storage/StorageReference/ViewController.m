//
//  Copyright (c) 2017 Google Inc.
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

#import "ViewController.h"

@import Firebase;

@import FirebaseUI;

@interface ViewController ()

@property (nonatomic) FIRStorage *root;
@property (nonatomic) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];

  NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:@"GoogleService-Info.plist"];

  // [START firstorage_storage]
  // Get a reference to the storage service using the default Firebase App
  FIRStorage *storage = [FIRStorage storage];

  // Create a storage reference from our storage service
  FIRStorageReference *storageRef = [storage reference];
  // [END firstorage_storage]

  // [START firstorage_child]
  // Create a child reference
  // imagesRef now points to "images"
  FIRStorageReference *imagesRef = [storageRef child:@"images"];

  // Child references can also take paths delimited by '/'
  // spaceRef now points to "images/space.jpg"
  // imagesRef still points to "images"
  FIRStorageReference *spaceRef = [storageRef child:@"images/space.jpg"];

  // This is equivalent to creating the full reference
  spaceRef = [storage referenceForURL:@"gs://<your-firebase-storage-bucket>/images/space.jpg"];
  // [END firstorage_child]

  // [START firstorage_parent]
  // Parent allows us to move to the parent of a reference
  // imagesRef now points to 'images'
  imagesRef = [spaceRef parent];

  // Root allows us to move all the way back to the top of our bucket
  // rootRef now points to the root
  FIRStorageReference *rootRef = [spaceRef root];
  // [END firstorage_parent]

  // [START firstorage_chain]
  // References can be chained together multiple times
  // earthRef points to "images/earth.jpg"
  FIRStorageReference *earthRef = [[spaceRef parent] child:@"earth.jpg"];

  // nilRef is nil, since the parent of root is nil
  FIRStorageReference *nilRef = [[spaceRef root] parent];
  // [END firstorage_chain]
}

- (void)storageReferencePropertiesExample {
  // [START firstorage_start]
  FIRStorage *storage = [FIRStorage storage];
  // [END firstorage_start]

  FIRStorageReference *spaceRef = [storage referenceForURL:@"gs://<your-firebase-storage-bucket>/images/space.jpg"];

  // [START firstorage_properties]
  // Reference's path is: "images/space.jpg"
  // This is analogous to a file path on disk
  spaceRef.fullPath;

  // Reference's name is the last segment of the full path: "space.jpg"
  // This is analogous to the file name
  spaceRef.name;

  // Reference's bucket is the name of the storage bucket where files are stored
  spaceRef.bucket;
  // [END firstorage_properties]
}

- (void)storageReferenceCombinedExample {
  // [START firstorage_combined]
  // Points to the root reference
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // Points to "images"
  FIRStorageReference *imagesRef = [storageRef child:@"images"];

  // Points to "images/space.jpg"
  // Note that you can use variables to create child values
  NSString *fileName = @"space.jpg";
  FIRStorageReference *spaceRef = [imagesRef child:fileName];

  // File path is "images/space.jpg"
  NSString *path = spaceRef.fullPath;

  // File name is "space.jpg"
  NSString *name = spaceRef.name;

  // Points to "images"
  imagesRef = [spaceRef parent];
  // [END firstorage_combined]
}

- (void)storageUploadExample {
  FIRStorage *storage = [FIRStorage storage];

  // [START firstorage_upload]
  // Create a root reference
  FIRStorageReference *storageRef = [storage reference];

  // Create a reference to "mountains.jpg"
  FIRStorageReference *mountainsRef = [storageRef child:@"mountains.jpg"];

  // Create a reference to 'images/mountains.jpg'
  FIRStorageReference *mountainImagesRef = [storageRef child:@"images/mountains.jpg"];

  // While the file names are the same, the references point to different files
  [mountainsRef.name isEqualToString:mountainImagesRef.name];         // true
  [mountainsRef.fullPath isEqualToString:mountainImagesRef.fullPath]; // false
  // [END firstorage_upload]
}

- (void)storageInMemoryUploadExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_memory]
  // Data in memory
  NSData *data = [NSData dataWithContentsOfFile:@"rivers.jpg"];

  // Create a reference to the file you want to upload
  FIRStorageReference *riversRef = [storageRef child:@"images/rivers.jpg"];

  // Upload the file to the path "images/rivers.jpg"
  FIRStorageUploadTask *uploadTask = [riversRef putData:data
                                               metadata:nil
                                             completion:^(FIRStorageMetadata *metadata,
                                                          NSError *error) {
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Metadata contains file metadata such as size, content-type, and download URL.
      int size = metadata.size;
      // You can also access to download URL after upload.
      [riversRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        if (error != nil) {
          // Uh-oh, an error occurred!
        } else {
          NSURL *downloadURL = URL;
        }
      }];
    }
  }];
  // [END firstorage_memory]
}

- (void)storageFromDiskUploadExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_disk]
  // File located on disk
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  // Create a reference to the file you want to upload
  FIRStorageReference *riversRef = [storageRef child:@"images/rivers.jpg"];

  // Upload the file to the path "images/rivers.jpg"
  FIRStorageUploadTask *uploadTask = [riversRef putFile:localFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Metadata contains file metadata such as size, content-type, and download URL.
      int size = metadata.size;
      // You can also access to download URL after upload.
      [riversRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        if (error != nil) {
          // Uh-oh, an error occurred!
        } else {
          NSURL *downloadURL = URL;
        }
      }];
    }
  }];
  // [END firstorage_disk]
}

- (void)storageMetadataUploadExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSData *data = [NSData data];
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  // [START firstorage_metadata]
  // Create storage reference
  FIRStorageReference *mountainsRef = [storageRef child:@"images/mountains.jpg"];

  // Create file metadata including the content type
  FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
  metadata.contentType = @"image/jpeg";

  // Upload data and metadata
  FIRStorageUploadTask *uploadTask = [mountainsRef putData:data metadata:metadata];

  // Upload file and metadata
  uploadTask = [mountainsRef putFile:localFile metadata:metadata];
  // [END firstorage_metadata]
}

- (void)storagePauseExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  // [START firstorage_pause]
  // Start uploading a file
  FIRStorageUploadTask *uploadTask = [storageRef putFile:localFile];

  // Pause the upload
  [uploadTask pause];

  // Resume the upload
  [uploadTask resume];

  // Cancel the upload
  [uploadTask cancel];
  // [END firstorage_pause]

  // [START firstorage_progress]
  // Add a progress observer to an upload task
  FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                  // A progress event occurred
                                                }];
  // [END firstorage_progress]
}

- (void)storageTaskExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  FIRStorageUploadTask *uploadTask = [storageRef putFile:localFile];

  // [START firstorage_task]
  // Create a task listener handle
  FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                  // A progress event occurred
                                                }];

  // Remove an individual observer
  [uploadTask removeObserverWithHandle:observer];

  // Remove all observers of a particular status
  [uploadTask removeAllObserversForStatus:FIRStorageTaskStatusProgress];

  // Remove all observers
  [uploadTask removeAllObservers];
  // [END firstorage_task]
}

- (void)storageUploadCombinedExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_upload_combined]
  // Local file you want to upload
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  // Create the file metadata
  FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
  metadata.contentType = @"image/jpeg";

  // Upload file and metadata to the object 'images/mountains.jpg'
  FIRStorageUploadTask *uploadTask = [storageRef putFile:localFile metadata:metadata];

  // Listen for state changes, errors, and completion of the upload.
  [uploadTask observeStatus:FIRStorageTaskStatusResume handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Upload resumed, also fires when the upload starts
  }];

  [uploadTask observeStatus:FIRStorageTaskStatusPause handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Upload paused
  }];

  [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Upload reported progress
    double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
  }];

  [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Upload completed successfully
  }];

  // Errors only occur in the "Failure" case
  [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
    if (snapshot.error != nil) {
      switch (snapshot.error.code) {
        case FIRStorageErrorCodeObjectNotFound:
          // File doesn't exist
          break;

        case FIRStorageErrorCodeUnauthorized:
          // User doesn't have permission to access file
          break;

        case FIRStorageErrorCodeCancelled:
          // User canceled the upload
          break;

        /* ... */

        case FIRStorageErrorCodeUnknown:
          // Unknown error occurred, inspect the server response
          break;
      }
    }
  }];
  // [END firstorage_upload_combined]
}

- (void)storageReferenceExample {
  FIRStorage *storage = [FIRStorage storage];

  // [START firstorage_reference]
  // Create a reference with an initial file path and name
  FIRStorageReference *pathReference = [storage referenceWithPath:@"images/stars.jpg"];

  // Create a reference from a Google Cloud Storage URI
  FIRStorageReference *gsReference = [storage referenceForURL:@"gs://<your-firebase-storage-bucket>/images/stars.jpg"];

  // Create a reference from an HTTPS URL
  // Note that in the URL, characters are URL escaped!
  FIRStorageReference *httpsReference = [storage referenceForURL:@"https://firebasestorage.googleapis.com/b/bucket/o/images%20stars.jpg"];
  // [END firstorage_reference]
}

- (void)storageDownloadExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_download]
  // Create a reference to the file you want to download
  FIRStorageReference *islandRef = [storageRef child:@"images/island.jpg"];

  // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
  [islandRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Data for "images/island.jpg" is returned
      UIImage *islandImage = [UIImage imageWithData:data];
    }
  }];
  // [END firstorage_download]
}

- (void)storageDownloadToDiskExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_download_disk]
  // Create a reference to the file you want to download
  FIRStorageReference *islandRef = [storageRef child:@"images/island.jpg"];

  // Create local filesystem URL
  NSURL *localURL = [NSURL URLWithString:@"path/to/image"];

  // Download to the local filesystem
  FIRStorageDownloadTask *downloadTask = [islandRef writeToFile:localURL completion:^(NSURL *URL, NSError *error){
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Local file URL for "images/island.jpg" is returned
    }
  }];
  // [END firstorage_download_disk]
}

- (void)storageDownloadURLExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_download_url]
  // Create a reference to the file you want to download
  FIRStorageReference *starsRef = [storageRef child:@"images/stars.jpg"];

  // Fetch the download URL
  [starsRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
    if (error != nil) {
      // Handle any errors
    } else {
      // Get the download URL for 'images/stars.jpg'
    }
  }];
  // [END firstorage_download_url]
}

- (void)storageFirebaseUIExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_firebaseui]
  // Reference to an image file in Firebase Storage
  FIRStorageReference *reference = [storageRef child:@"images/stars.jpg"];

  // UIImageView in your ViewController
  UIImageView *imageView = self.imageView;

  // Placeholder image
  UIImage *placeholderImage;

  // Load the image using SDWebImage
  [imageView sd_setImageWithStorageReference:reference placeholderImage:placeholderImage];
  // [END firstorage_firebaseui]
}

- (void)storageDownloadPauseExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];

  // [START firstorage_download_pause]
  // Start downloading a file
  FIRStorageDownloadTask *downloadTask = [[storageRef child:@"images/mountains.jpg"] writeToFile:localFile];

  // Pause the download
  [downloadTask pause];

  // Resume the download
  [downloadTask resume];

  // Cancel the download
  [downloadTask cancel];
  // [END firstorage_download_pause]

  // [START firstorage_download_observe]
  // Add a progress observer to a download task
  FIRStorageHandle observer = [downloadTask observeStatus:FIRStorageTaskStatusProgress
                                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                    // A progress event occurred
                                                  }];
  // [END firstorage_download_observe]
}

- (void)storageHandleObserverExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSURL *localFile = [NSURL URLWithString:@"path/to/image"];
  FIRStorageDownloadTask *downloadTask = [[storageRef child:@"images/mountains.jpg"] writeToFile:localFile];

  // [START firstorage_handle_observer]
  // Create a task listener handle
  FIRStorageHandle observer = [downloadTask observeStatus:FIRStorageTaskStatusProgress
                                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                    // A progress event occurred
                                                  }];

  // Remove an individual observer
  [downloadTask removeObserverWithHandle:observer];

  // Remove all observers of a particular status
  [downloadTask removeAllObserversForStatus:FIRStorageTaskStatusProgress];

  // Remove all observers
  [downloadTask removeAllObservers];
  // [END firstorage_handle_observer]
}

- (void)storageDownloadCombinedExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  NSURL *localURL = [NSURL URLWithString:@"path/to/image"];

  // [START firstorage_download_combined]
  // Create a reference to the file we want to download
  FIRStorageReference *starsRef = [storageRef child:@"images/stars.jpg"];

  // Start the download (in this case writing to a file)
  FIRStorageDownloadTask *downloadTask = [storageRef writeToFile:localURL];

  // Observe changes in status
  [downloadTask observeStatus:FIRStorageTaskStatusResume handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Download resumed, also fires when the download starts
  }];

  [downloadTask observeStatus:FIRStorageTaskStatusPause handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Download paused
  }];

  [downloadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Download reported progress
    double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
  }];

  [downloadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
    // Download completed successfully
  }];

  // Errors only occur in the "Failure" case
  [downloadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
    if (snapshot.error != nil) {
      switch (snapshot.error.code) {
        case FIRStorageErrorCodeObjectNotFound:
          // File doesn't exist
          break;

        case FIRStorageErrorCodeUnauthorized:
          // User doesn't have permission to access file
          break;

        case FIRStorageErrorCodeCancelled:
          // User canceled the upload
          break;

        /* ... */

        case FIRStorageErrorCodeUnknown:
          // Unknown error occurred, inspect the server response
          break;
      }
    }
  }];
  // [END firstorage_download_combined]
}

- (void)storageGetMetadataExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_get_metadata]
  // Create reference to the file whose metadata we want to retrieve
  FIRStorageReference *forestRef = [storageRef child:@"images/forest.jpg"];

  // Get metadata properties
  [forestRef metadataWithCompletion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Metadata now contains the metadata for 'images/forest.jpg'
    }
  }];
  // [END firstorage_get_metadata]
}

- (void)storageChangeMetadataExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_change_metadata]
  // Create reference to the file whose metadata we want to change
  FIRStorageReference *forestRef = [storageRef child:@"images/forest.jpg"];

  // Create file metadata to update
  FIRStorageMetadata *newMetadata = [[FIRStorageMetadata alloc] init];
  newMetadata.cacheControl = @"public,max-age=300";
  newMetadata.contentType = @"image/jpeg";

  // Update metadata properties
  [forestRef updateMetadata:newMetadata completion:^(FIRStorageMetadata *metadata, NSError *error){
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // Updated metadata for 'images/forest.jpg' is returned
    }
  }];
  // [END firstorage_change_metadata]
}

- (void)storageDeleteMetadataExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];
  FIRStorageReference *forestRef = [storageRef child:@"images/forest.jpg"];

  // [START firstorage_delete_metadata]
  FIRStorageMetadata *newMetadata = [[FIRStorageMetadata alloc] init];
  newMetadata.contentType = @"";

  // Delete the metadata property
  [forestRef updateMetadata:newMetadata completion:^(FIRStorageMetadata *metadata, NSError *error){
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // metadata.contentType should be nil
    }
  }];
  // [END firstorage_delete_metadata]
}

- (void)storageCustomMetadata {
  // [START firstorage_custom_metadata]
  NSDictionary *metadata = @{
    @"customMetadata": @{
      @"location": @"Yosemite, CA, USA",
      @"activity": @"Hiking"
    }
  };
  // [END firstorage_custom_metadata]
}

- (void)storageDeleteFileExample {
  FIRStorageReference *storageRef = [[FIRStorage storage] reference];

  // [START firstorage_delete]
  // Create a reference to the file to delete
  FIRStorageReference *desertRef = [storageRef child:@"images/desert.jpg"];

  // Delete the file
  [desertRef deleteWithCompletion:^(NSError *error){
    if (error != nil) {
      // Uh-oh, an error occurred!
    } else {
      // File deleted successfully
    }
  }];
  // [END firstorage_delete]
}

- (void)listAllFiles {
  FIRStorage *storage = [FIRStorage storage];
  // [START storage_list_all]
  FIRStorageReference *storageReference = [storage reference];
  [storageReference listAllWithCompletion:^(FIRStorageListResult *result, NSError *error) {
    if (error != nil) {
      // ...
    }

    for (FIRStorageReference *prefix in result.prefixes) {
      // All the prefixes under storageReference.
      // You may call listAllWithCompletion: recursively on them.
    }
    for (FIRStorageReference *item in result.items) {
      // All items under storageReference.
    }
  }];
  // [END storage_list_all]
}

// [START storage_list_paginated]
- (void)paginateFilesAtReference:(FIRStorageReference *)reference
                       pageToken:(nullable NSString *)pageToken {
  void (^pageHandler)(FIRStorageListResult *_Nonnull, NSError *_Nullable) =
      ^(FIRStorageListResult *result, NSError *error) {
        if (error != nil) {
          // ...
        }
        NSArray *prefixes = result.prefixes;
        NSArray *items = result.items;

        // ...

        // Process next page
        if (result.pageToken != nil) {
          [self paginateFilesAtReference:reference pageToken:result.pageToken];
        }
  };

  if (pageToken != nil) {
    [reference listWithMaxResults:100 pageToken:pageToken completion:pageHandler];
  } else {
    [reference listWithMaxResults:100 completion:pageHandler];
  }
}
// [END storage_list_paginated]


@end
