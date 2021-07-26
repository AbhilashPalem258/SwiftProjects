//
//  ViewController.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import UIKit

class ImageGalleryVC: UIViewController {

    private var contentView: ImageCollectionView?
    private var viewModel: ImageCollectionVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ImageCollectionVM(serviceType: ImageGalleryService.self)
        self.contentView = ImageCollectionView(delegate: self)
        self.viewModel?.setdelgate(self)
        initialConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.fetchImages()
    }
}
extension ImageGalleryVC {
    func initialConfiguration() {
        self.view.addSubview(contentView!)
        contentView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
extension ImageGalleryVC: ImageCollectionViewDelegate {
    func sortBtnTapped() {
        self.viewModel?.sortTriggered()
    }
}
extension ImageGalleryVC: ImageCollectionVMDelegate {
    func renderView(state: ImageCollectionDataModel.State) {
        switch state {
        case .success(data: let data):
            self.contentView?.updateData(data)
        case .failure:
            print()
        case .loading:
            print("loading")
        }
    }
}
//rohit.k@plobalapps.com

