//
//  ImageCollectionVM.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import Foundation

protocol ImageCollectionVMType {
    init<T: ImageGalleryServiceType>(serviceType: T.Type)
    func fetchImages()
    func sortTriggered()
}

protocol ImageCollectionVMDelegate: AnyObject {
    func renderView(state: ImageCollectionDataModel.State)
}

class ImageCollectionVM: ImageCollectionVMType {
    private let service: ImageGalleryServiceType.Type
    private var dataModel: ImageCollectionDataModel
    weak var delegate: ImageCollectionVMDelegate?
    
    // MARK: Initialization
    required init<T>(serviceType: T.Type) where T: ImageGalleryServiceType {
        self.service = serviceType
        self.dataModel = .init(data: .loading)
    }
}
extension ImageCollectionVM {
    func fetchImages() {
        self.updateScreen(state: .loading)
        service.fetchImages {[weak self] result in
            switch result {
            case .success(let model):
                self?.processSuccess(model: model)
            case .failure:
                self?.processFailure()
            }
        }
    }
    
    func sortTriggered() {
        if case .success(data: let images) = self.dataModel.data {
            self.updateScreen(state: .success(data: qs(images)))
        }
    }
    
    func setdelgate(_ delegate: ImageCollectionVMDelegate) {
        self.delegate = delegate
    }
}
extension ImageCollectionVM {
    private func qs(_ arr: [ImageItem]) -> [ImageItem] {
        if arr.count <= 1 {
            return arr
        }
        let pivot = arr[arr.count/2]
        var left = [ImageItem](), right = [ImageItem](), equal = [ImageItem]()
        for element in arr {
            if element.order < pivot.order {
                left.append(element)
            } else if element.order > pivot.order {
                right.append(element)
            } else {
                equal.append(element)
            }
        }
        return qs(left) + equal + qs(right)
    }
}
extension ImageCollectionVM {
    private func processSuccess(model: ImageCollectionResponse) {
        self.updateScreen(state: .success(data: model.images))
    }
    
    private func processFailure() {
        self.updateScreen(state: .failure)
    }
    
    private func updateScreen(state: ImageCollectionDataModel.State) {
        self.dataModel.updateState(state)
        self.delegate?.renderView(state: self.dataModel.data)
    }
}
