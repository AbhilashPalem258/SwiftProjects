//
//  ImageGalleryService.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import Foundation

protocol ImageGalleryServiceType {
    static func fetchImages(completion: @escaping (Result<ImageCollectionResponse, Error>) -> Void)
}

enum ImageGalleryService: ImageGalleryServiceType {
    static func fetchImages(completion: @escaping (Result<ImageCollectionResponse, Error>) -> Void) {
        let session = URLSession.shared
        guard let url =  URL(string: "https://plobalapps.s3.ap-southeast-1.amazonaws.com/assets/test-sample.json") else {
            return
        }
        let task = session.dataTask(with: url) { data, _, error in
             if error != nil || data == nil {
                completion(.failure(error!))
                return
             }
             do {
                let collection = try JSONDecoder().decode(ImageCollectionResponse.self, from: Data(ImageJson.utf8))
                DispatchQueue.main.async {
                    completion(.success(collection))
                }
             } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                 print("JSON error: \(error.localizedDescription)")
             }
        }
         task.resume()
    }
}
