//
//  ImageService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-25.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

protocol ImageServiceProtocol {

    func urlRetrieved()
    
}

class ImageService {
    
    static func storeImage(image: UIImage, itemRef: DocumentReference) {
        
        // Generate a random image id
        let imageID = UUID.init().uuidString
        guard let userEmail = Stored.user?.email else { return }
        
        // Get a storage reference
        let uploadRef = Storage.storage().reference().child(userEmail).child(imageID)
        
        // Get Data Representation of the image
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpg"
        
        // Upload the photo
        uploadRef.putData(imageData, metadata: uploadMetaData) { (metaData, error) in
            
            if error != nil {
                print("There was an error uploading the image")
            }
            else {
                createImageDatabseEntry(ref: uploadRef, itemRef: itemRef)
            }
            
        }
        
    }
    
    private static func createImageDatabseEntry(ref: StorageReference, itemRef: DocumentReference) {
        
        // Get a download url for the photo
        ref.downloadURL { (url , error) in
            
            // Check if the download was successful
            guard url != nil && error == nil else { return }
            
            itemRef.updateData([Constants.Key.Item.imageURL: url!.absoluteString])
        }
        
        
    }
    
}
