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

import UIKit

import Firebase
import FirebaseUI

class ViewController: UIViewController {

  var imageView: UIImageView!
  let your_firebase_storage_bucket = FirebaseOptions.defaultOptions()?.storageBucket ?? ""

  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageView = UIImageView(frame: self.view.frame)

    // [START firstorage_storage]
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()

    // Create a storage reference from our storage service
    let storageRef = storage.reference()
    // [END firstorage_storage]

    // [START firstorage_child]
    // Create a child reference
    // imagesRef now points to "images"
    let imagesRef = storageRef.child("images")

    // Child references can also take paths delimited by '/'
    // spaceRef now points to "images/space.jpg"
    // imagesRef still points to "images"
    var spaceRef = storageRef.child("images/space.jpg")

    // This is equivalent to creating the full reference
    let storagePath = "\(your_firebase_storage_bucket)/images/space.jpg"
    spaceRef = storage.reference(forURL: storagePath)
    // [END firstorage_child]
  }

  func storageParentExample() {
    let storageRef = Storage.storage().reference()
    let spaceRef = storageRef.child("images/space.jpg")

    // [START firstorage_parent]
    // Parent allows us to move to the parent of a reference
    // imagesRef now points to 'images'
    let imagesRef = spaceRef.parent()

    // Root allows us to move all the way back to the top of our bucket
    // rootRef now points to the root
    let rootRef = spaceRef.root()
    // [END firstorage_parent]

    // [START firstorage_chain]
    // References can be chained together multiple times
    // earthRef points to "images/earth.jpg"
    let earthRef = spaceRef.parent()?.child("earth.jpg")

    // nilRef is nil, since the parent of root is nil
    let nilRef = spaceRef.root().parent()
    // [END firstorage_chain]
  }

  func storageReferencePropertiesExample() {
    let storageRef = Storage.storage().reference()
    let spaceRef = storageRef.child("images/space.jpg")

    // [START firstorage_properties]
    // Reference's path is: "images/space.jpg"
    // This is analogous to a file path on disk
    spaceRef.fullPath

    // Reference's name is the last segment of the full path: "space.jpg"
    // This is analogous to the file name
    spaceRef.name

    // Reference's bucket is the name of the storage bucket where files are stored
    spaceRef.bucket
    // [END firstorage_properties]
  }

  func storageReferenceCombinedExample() {
    // [START firstorage_combined]
    // Points to the root reference
    let storageRef = Storage.storage().reference()

    // Points to "images"
    let imagesRef = storageRef.child("images")

    // Points to "images/space.jpg"
    // Note that you can use variables to create child values
    let fileName = "space.jpg"
    let spaceRef = imagesRef.child(fileName)

    // File path is "images/space.jpg"
    let path = spaceRef.fullPath;

    // File name is "space.jpg"
    let name = spaceRef.name;

    // Points to "images"
    let images = spaceRef.parent()
    // [END firstorage_combined]
  }

  func storageUploadExample() {
    let storage = Storage.storage()

    // [START firstorage_upload]
    // Create a root reference
    let storageRef = storage.reference()

    // Create a reference to "mountains.jpg"
    let mountainsRef = storageRef.child("mountains.jpg")

    // Create a reference to 'images/mountains.jpg'
    let mountainImagesRef = storageRef.child("images/mountains.jpg")

    // While the file names are the same, the references point to different files
    mountainsRef.name == mountainImagesRef.name;            // true
    mountainsRef.fullPath == mountainImagesRef.fullPath;    // false
    // [END firstorage_upload]
  }

  func storageInMemoryExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_memory]
    // Data in memory
    let data = Data()

    // Create a reference to the file you want to upload
    let riversRef = storageRef.child("images/rivers.jpg")

    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
      guard let metadata = metadata else {
        // Uh-oh, an error occurred!
        return
      }
      // Metadata contains file metadata such as size, content-type.
      let size = metadata.size
      // You can also access to download URL after upload.
      riversRef.downloadURL { (url, error) in
        guard let downloadURL = url else {
          // Uh-oh, an error occurred!
          return
        }
      }
    }
    // [END firstorage_memory]
  }

  func storageUploadFromDiskExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_disk]
    // File located on disk
    let localFile = URL(string: "path/to/image")!

    // Create a reference to the file you want to upload
    let riversRef = storageRef.child("images/rivers.jpg")

    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
      guard let metadata = metadata else {
        // Uh-oh, an error occurred!
        return
      }
      // Metadata contains file metadata such as size, content-type.
      let size = metadata.size
      // You can also access to download URL after upload.
      riversRef.downloadURL { (url, error) in
        guard let downloadURL = url else {
          // Uh-oh, an error occurred!
          return
        }
      }
    }
    // [END firstorage_disk]
  }

  func storageMetadataUploadExample() {
    let storageRef = Storage.storage().reference()
    let data = Data()
    let localFile = URL(string: "path/to/image")!

    // [START firstorage_metadata]
    // Create storage reference
    let mountainsRef = storageRef.child("images/mountains.jpg")

    // Create file metadata including the content type
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"

    // Upload data and metadata
    mountainsRef.putData(data, metadata: metadata)

    // Upload file and metadata
    mountainsRef.putFile(from: localFile, metadata: metadata)
    // [END firstorage_metadata]
  }

  func storagePauseExample() {
    let storageRef = Storage.storage().reference()
    let localFile = URL(string: "path/to/image")!

    // [START firstorage_pause]
    // Start uploading a file
    let uploadTask = storageRef.putFile(from: localFile)

    // Pause the upload
    uploadTask.pause()

    // Resume the upload
    uploadTask.resume()

    // Cancel the upload
    uploadTask.cancel()
    // [END firstorage_pause]

    // [START firstorage_progress]
    // Add a progress observer to an upload task
    let observer = uploadTask.observe(.progress) { snapshot in
      // A progress event occured
    }
    // [END firstorage_progress]
  }

  func storageTaskExample() {
    let storageRef = Storage.storage().reference()
    let localFile = URL(string: "path/to/image")!

    let uploadTask = storageRef.putFile(from: localFile)

    // [START firstorage_task]
    // Create a task listener handle
    let observer = uploadTask.observe(.progress) { snapshot in
      // A progress event occurred
    }

    // Remove an individual observer
    uploadTask.removeObserver(withHandle: observer)

    // Remove all observers of a particular status
    uploadTask.removeAllObservers(for: .progress)

    // Remove all observers
    uploadTask.removeAllObservers()
    // [END firstorage_task]
  }

  func storageUploadCombinedExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_upload_combined]
    // Local file you want to upload
    let localFile = URL(string: "path/to/image")!

    // Create the file metadata
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"

    // Upload file and metadata to the object 'images/mountains.jpg'
    let uploadTask = storageRef.putFile(from: localFile, metadata: metadata)

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.observe(.resume) { snapshot in
      // Upload resumed, also fires when the upload starts
    }

    uploadTask.observe(.pause) { snapshot in
      // Upload paused
    }

    uploadTask.observe(.progress) { snapshot in
      // Upload reported progress
      let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
        / Double(snapshot.progress!.totalUnitCount)
    }

    uploadTask.observe(.success) { snapshot in
      // Upload completed successfully
    }

    uploadTask.observe(.failure) { snapshot in
      if let error = snapshot.error as? NSError {
        switch (StorageErrorCode(rawValue: error.code)!) {
        case .objectNotFound:
          // File doesn't exist
          break
        case .unauthorized:
          // User doesn't have permission to access file
          break
        case .cancelled:
          // User canceled the upload
          break

        /* ... */

        case .unknown:
          // Unknown error occurred, inspect the server response
          break
        default:
          // A separate error occurred. This is a good place to retry the upload.
          break
        }
      }
    }
    // [END firstorage_upload_combined]
  }

  func storageReferenceExample() {
    // [START firstorage_start]
    let storage = Storage.storage()
    // [END firstorage_start]

    // [START firstorage_reference]
    // Create a reference with an initial file path and name
    let pathReference = storage.reference(withPath: "images/stars.jpg")

    // Create a reference from a Google Cloud Storage URI
    let gsReference = storage.reference(forURL: "gs://<your-firebase-storage-bucket>/images/stars.jpg")

    // Create a reference from an HTTPS URL
    // Note that in the URL, characters are URL escaped!
    let httpsReference = storage.reference(forURL: "https://firebasestorage.googleapis.com/b/bucket/o/images%20stars.jpg")
    // [END firstorage_reference]
  }

  func storageDownloadExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_download]
    // Create a reference to the file you want to download
    let islandRef = storageRef.child("images/island.jpg")

    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // Data for "images/island.jpg" is returned
        let image = UIImage(data: data!)
      }
    }
    // [END firstorage_download]
  }

  func storageDownloadToDiskExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_download_disk]
    // Create a reference to the file you want to download
    let islandRef = storageRef.child("images/island.jpg")

    // Create local filesystem URL
    let localURL = URL(string: "path/to/image")!

    // Download to the local filesystem
    let downloadTask = islandRef.write(toFile: localURL) { url, error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // Local file URL for "images/island.jpg" is returned
      }
    }
    // [END firstorage_download_disk]
  }

  func storageDownloadURLExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_download_url]
    // Create a reference to the file you want to download
    let starsRef = storageRef.child("images/stars.jpg")

    // Fetch the download URL
    starsRef.downloadURL { url, error in
      if let error = error {
        // Handle any errors
      } else {
        // Get the download URL for 'images/stars.jpg'
      }
    }
    // [END firstorage_download_url]
  }

  func storageFirebaseUIExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_firebaseui]
    // Reference to an image file in Firebase Storage
    let reference = storageRef.child("images/stars.jpg")

    // UIImageView in your ViewController
    let imageView: UIImageView = self.imageView

    // Placeholder image
    let placeholderImage = UIImage(named: "placeholder.jpg")

    // Load the image using SDWebImage
    imageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
    // [END firstorage_firebaseui]
  }

  func storageDownloadPauseExample() {
    let storageRef = Storage.storage().reference()
    let localFile = URL(string: "path/to/image")!

    // [START firstorage_download_pause]
    // Start downloading a file
    let downloadTask = storageRef.child("images/mountains.jpg").write(toFile: localFile)

    // Pause the download
    downloadTask.pause()

    // Resume the download
    downloadTask.resume()

    // Cancel the download
    downloadTask.cancel()
    // [END firstorage_download_pause]

    // [START firstorage_download_observe]
    // Add a progress observer to a download task
    let observer = downloadTask.observe(.progress) { snapshot in
      // A progress event occurred
    }
    // [END firstorage_download_observe]
  }

  func storageHandleObserverExample() {
    let storageRef = Storage.storage().reference()
    let localFile = URL(string: "path/to/image")!
    let downloadTask = storageRef.child("images/mountains.jpg").write(toFile: localFile)

    // [START firstorage_handle_observer]
    // Create a task listener handle
    let observer = downloadTask.observe(.progress) { snapshot in
    // A progress event occurred
    }

    // Remove an individual observer
    downloadTask.removeObserver(withHandle: observer)

    // Remove all observers of a particular status
    downloadTask.removeAllObservers(for: .progress)

    // Remove all observers
    downloadTask.removeAllObservers()
    // [END firstorage_handle_observer]
  }

  func storageDownloadCombinedExample() {
    let storageRef = Storage.storage().reference()
    let localURL = URL(string: "path/to/image")!

    // [START firstorage_download_combined]
    // Create a reference to the file we want to download
    let starsRef = storageRef.child("images/stars.jpg")

    // Start the download (in this case writing to a file)
    let downloadTask = storageRef.write(toFile: localURL)

    // Observe changes in status
    downloadTask.observe(.resume) { snapshot in
      // Download resumed, also fires when the download starts
    }

    downloadTask.observe(.pause) { snapshot in
      // Download paused
    }

    downloadTask.observe(.progress) { snapshot in
      // Download reported progress
      let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
        / Double(snapshot.progress!.totalUnitCount)
    }

    downloadTask.observe(.success) { snapshot in
      // Download completed successfully
    }

    // Errors only occur in the "Failure" case
    downloadTask.observe(.failure) { snapshot in
      guard let errorCode = (snapshot.error as? NSError)?.code else {
        return
      }
      guard let error = StorageErrorCode(rawValue: errorCode) else {
        return
      }
      switch (error) {
      case .objectNotFound:
        // File doesn't exist
        break
      case .unauthorized:
        // User doesn't have permission to access file
        break
      case .cancelled:
        // User cancelled the download
        break

      /* ... */

      case .unknown:
        // Unknown error occurred, inspect the server response
        break
      default:
        // Another error occurred. This is a good place to retry the download.
        break
      }
    }
    // [END firstorage_download_combined]
  }

  func storageGetMetadataExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_get_metadata]
    // Create reference to the file whose metadata we want to retrieve
    let forestRef = storageRef.child("images/forest.jpg")

    // Get metadata properties
    forestRef.getMetadata { metadata, error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // Metadata now contains the metadata for 'images/forest.jpg'
      }
    }
    // [END firstorage_get_metadata]
  }

  func storageChangeMetadataExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_change_metadata]
    // Create reference to the file whose metadata we want to change
    let forestRef = storageRef.child("images/forest.jpg")

    // Create file metadata to update
    let newMetadata = StorageMetadata()
    newMetadata.cacheControl = "public,max-age=300";
    newMetadata.contentType = "image/jpeg";

    // Update metadata properties
    forestRef.updateMetadata(newMetadata) { metadata, error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // Updated metadata for 'images/forest.jpg' is returned
      }
    }
    // [END firstorage_change_metadata]
  }

  func storageDeleteMetadataExample() {
    let storageRef = Storage.storage().reference()
    let forestRef = storageRef.child("images/forest.jpg")

    // [START firstorage_delete_metadata]
    let newMetadata = StorageMetadata()
    newMetadata.contentType = "";

    // Delete the metadata property
    forestRef.updateMetadata(newMetadata) { metadata, error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // metadata.contentType should be nil
      }
    }
    // [END firstorage_delete_metadata]
  }

  func storageCustomMetadataExample() {
    // [START firstorage_custom_metadata]
    let metadata = [
      "customMetadata": [
        "location": "Yosemite, CA, USA",
        "activity": "Hiking"
      ]
    ]
    // [END firstorage_custom_metadata]
  }

  func storageDeleteFileExample() {
    let storageRef = Storage.storage().reference()

    // [START firstorage_delete]
    // Create a reference to the file to delete
    let desertRef = storageRef.child("desert.jpg")

    // Delete the file
    desertRef.delete { error in
      if let error = error {
        // Uh-oh, an error occurred!
      } else {
        // File deleted successfully
      }
    }
    // [END firstorage_delete]
  }

  func listAllFiles() {
    let storage = Storage.storage()
    // [START storage_list_all]
    let storageReference = storage.reference().child("files/uid")
    storageReference.listAll { (result, error) in
      if let error = error {
        // ...
      }
      for prefix in result.prefixes {
        // The prefixes under storageReference.
        // You may call listAll(completion:) recursively on them.
      }
      for item in result.items {
        // The items under storageReference.
      }
    }
    // [END storage_list_all]
  }

  // [START storage_list_paginated]
  func listAllPaginated(pageToken: String? = nil) {
    let storage = Storage.storage()
    let storageReference = storage.reference().child("files/uid")

    let pageHandler: (StorageListResult, Error?) -> Void = { (result, error) in
      if let error = error {
        // ...
      }
      let prefixes = result.prefixes
      let items = result.items

      // ...

      // Process next page
      if let token = result.pageToken {
        self.listAllPaginated(pageToken: token)
      }
    }

    if let pageToken = pageToken {
      storageReference.list(withMaxResults: 100, pageToken: pageToken, completion: pageHandler)
    } else {
      storageReference.list(withMaxResults: 100, completion: pageHandler)
    }
  }
  // [END storage_list_paginated]
}
