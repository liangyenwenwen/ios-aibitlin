//
//  AllQuickWindowView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/5/8.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
import OUICore

class AllQuickWindowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var closeBtn:UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "web_more_close_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.removeFromSuperview()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: (kScreenWidth-32-20*2)/3.0, height: 180)
        let r = UICollectionView(frame: .zero, collectionViewLayout: layout)
        r.register(QuickWindowItemView.self, forCellWithReuseIdentifier: QuickWindowItemView.className)
        r.backgroundColor = .clear
        r.dataSource = self
        r.delegate = self
        r.showsHorizontalScrollIndicator = false
        return r
    }()

    
    
    func initUI() {
        
        backgroundColor = .clear;
//        alpha = 0.5;
        let blur = UIBlurEffect(style: .light)
        let effectview = UIVisualEffectView(effect: blur)
        effectview.frame = self.bounds
        addSubview(effectview)
        addSubview(closeBtn)
        addSubview(collectionView)
        closeBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalTo(kStatusBarHeight+6)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-kSafeAreaBottomHeight)
            make.top.equalTo(closeBtn.snp_bottom).offset(6)
        }
    }
    
    
    
}
extension AllQuickWindowView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            return appDelegate.quickWindowArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuickWindowItemView.className, for: indexPath) as! QuickWindowItemView
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let item = appDelegate.quickWindowArray[indexPath.row]
            cell.smallImageView.image = item["image"] as! UIImage?
            cell.nameLabel.text = item["name"] as? String
        }
        cell.closeBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                var item = appDelegate.quickWindowArray[indexPath.row]
                item["vc"] = nil
                appDelegate.quickWindowArray.remove(at:indexPath.row)
                if appDelegate.quickWindowArray.count == 0{
                    self?.removeFromSuperview()
                    appDelegate.hideQuickWindow()
                }else{
                    self?.collectionView.reloadData()
                }
            }
        }).disposed(by: rx.disposeBag)
        return cell
    }
}
extension AllQuickWindowView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 执行动画
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.removeFromSuperview()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let data = appDelegate.quickWindowArray[indexPath.row]
            if indexPath.row != 0 {
                appDelegate.quickWindowArray.remove(at: indexPath.row)
                appDelegate.quickWindowArray.insert(data, at: indexPath.row)
            }
            let webVC = data["vc"] as? YFCustomWebViewController ?? YFCustomWebViewController()
            webVC.modalPresentationStyle = .fullScreen
            let nav = UINavigationController.init(rootViewController:  webVC)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.currentViewController().present(nav, animated: true)
        }
    }
    
}
class QuickWindowItemView: UICollectionViewCell {
    
    lazy var smallImageView: UIImageView = {
        let r = UIImageView()
        r.contentMode = .scaleAspectFill
        r.corner(8)
        return r
    }()
    lazy var nameLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(15)
        r.textColor = .black333
        r.textAlignment = .center
        
        return r
    }()
    lazy var closeBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "web_more_close_icon"), for: .normal)
        return r
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(smallImageView)
        contentView.addSubview(closeBtn)
        contentView.addSubview(nameLabel)
        smallImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(contentView)
            make.bottom.equalTo(nameLabel.snp_top)
        }
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(smallImageView.snp_top).offset(5)
            make.right.equalTo(smallImageView.snp_right).offset(-5)
            make.width.height.equalTo(25)
        }
        nameLabel.snp_makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


