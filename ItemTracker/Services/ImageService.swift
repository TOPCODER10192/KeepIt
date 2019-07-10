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

final class ImageService {
    
    static let firebaseStorage = Storage.storage()
    
    static func storeImage(image: UIImage, itemName: String, completion: @escaping (URL) -> Void) {
        
        guard let userEmail = Stored.user?.email else { return }
        
        // Get a storage reference
        let uploadRef = firebaseStorage.reference().child(userEmail).child(itemName)
        
        // Get Data Representation of the image
        guard let imageData = image.jpegData(compressionQuality: 0.01) else { return }
        
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpg"
        
        // Upload the photo
        uploadRef.putData(imageData, metadata: uploadMetaData) { (metaData, error) in
            
            if error != nil {
                print("There was an error uploading the image")
            }
            else {
                
                // Get a download url for the photo
                uploadRef.downloadURL { (url , error) in
                    
                    // Check if the download was successful
                    guard url != nil && error == nil else { return }
                    
                    // Store the url in the database and locally
                    completion(url!)
                }
                
            }
            
        }
        
    }
    
    static func deleteImage(itemName: String) {
        
        guard let userEmail = Stored.user?.email else { return }
        
        let deleteRef = firebaseStorage.reference().child(userEmail).child(itemName)
        
        deleteRef.delete { (error) in
            
            guard error == nil else { return }
            
        }
        
    }
    
}
