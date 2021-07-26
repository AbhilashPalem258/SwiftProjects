//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    private let image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(image)
        initialConfiguration()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.image.image = nil
        super.prepareForReuse()
    }
}
extension ImageCollectionViewCell {
    private func initialConfiguration() {
        image.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
extension ImageCollectionViewCell {
    func setImage(url: String) {
        self.image.sd_setImage(with: URL(string: url), placeholderImage: nil)
    }
}
