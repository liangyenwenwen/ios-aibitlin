
import Kingfisher
import UIKit
import SnapKit

class NineImageView: UICollectionView {
    
    var images = [MetaInfo]() {
        didSet {
            reloadData()
        }
    }
    
    var isRounds = false
    
    init(frame: CGRect) {
        let cellSize = (MomentContentWidth - 3 * imageSpace) / 3
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = imageSpace
        layout.minimumLineSpacing = imageSpace
        layout.itemSize = .init(width: cellSize, height: cellSize)
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(NineImageViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(NineImageViewCell.self))
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var onPreviewImages: (([MetaInfo], IndexPath, [UIView]) -> Void)?
}

extension NineImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NineImageViewCell.self), for: indexPath) as! NineImageViewCell
        let item = images[indexPath.item]
        if item.thumb.isEmpty{
            cell.imageView.setImage(with: item.original, placeHolder: "common_image_placeholder", showIndicator: true)
        }else{
            cell.imageView.setImage(with: item.thumb, placeHolder: "common_image_placeholder", showIndicator: true)
        }
        
        cell.imageView.tag = item.original.hashValue
        
        if isRounds {
            cell.imageView.layer.cornerRadius = 5
            cell.imageView.layer.masksToBounds = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("图片预览\(indexPath)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NineImageViewCell.self), for: indexPath) as! NineImageViewCell
        let views = images.flatMap({ collectionView.viewWithTag($0.original.hashValue )})
        
        if !images.isEmpty {
            onPreviewImages?(images, indexPath, views)
        }
    }
}

class NineImageViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.autoresizesSubviews = true
        iv.clearsContextBeforeDrawing = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin: CGFloat = sectionInset.left
        var maxY: CGFloat = -1.0
        
        layoutAttributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return layoutAttributes
    }
}

