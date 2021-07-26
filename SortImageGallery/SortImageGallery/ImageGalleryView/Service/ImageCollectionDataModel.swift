//
//  ImageCollectionDataModel.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import Foundation

struct ImageCollectionDataModel {
    enum State {
        case loading
        case failure
        case success(data: [ImageItem])
    }
    
    private(set) var data: State
    
    mutating func updateState(_ state: State) {
        self.data = state
    }
}

struct ImageCollectionResponse: Codable {
    let images: [ImageItem]
}
struct ImageItem: Codable {
    let img: String
    let order: Int
    let title: String
}
extension ImageItem: Comparable {
    static func < (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.order < rhs.order
    }
}
