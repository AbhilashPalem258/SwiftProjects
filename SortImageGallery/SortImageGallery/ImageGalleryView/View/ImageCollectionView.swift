//
//  ImageCollectionView.swift
//  ImageGallery
//
//  Created by Abhilash Palem on 26/07/21.
//

import UIKit
import SnapKit

// MARK: ImageCollectionViewDelegate
protocol ImageCollectionViewDelegate: AnyObject {
    func sortBtnTapped()
}

class ImageCollectionView: UIView {
    // MARK: Exposed Properties
    weak var delegate: ImageCollectionViewDelegate?
    
    // MARK: - Internal Properties
    private lazy var imageCollectionView: UICollectionView = {[weak self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 8.0, right: 0)

        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear

        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ImageCollectionViewCell.self))
        return collectionView
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("SORT IMAGES", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        return btn
    }()
    
    private var dataSource: [ImageItem]? {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    func updateData(_ data: [ImageItem]) {
        self.dataSource = data
    }

    // MARK: - Initialization
    init(delegate: ImageCollectionViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        initialConfiguration()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ImageCollectionView {
    func initialConfiguration() {
        self.addSubview(imageCollectionView)
        self.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(sortBtnTapped), for: .touchUpInside)
        
        imageCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(actionButton.snp.top)
        }
        
        actionButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
    }
    
    @objc func sortBtnTapped() {
        self.delegate?.sortBtnTapped()
    }
}
extension ImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as! ImageCollectionViewCell
        cell.setImage(url: dataSource![indexPath.row].img)
        return cell
    }
}
extension ImageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size.width / 2 - 40
        return CGSize(width: collectionViewSize , height: 200)
    }
}
