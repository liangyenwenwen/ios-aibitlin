
import UIKit
import MJRefresh

fileprivate let kHeaderHeight: CGFloat = 60.h

class MomentRefreshHeader: MJRefreshHeader {
    
    private lazy var rotateImageView: UIImageView = {
        let imageView = UIImageView(image: .init(nameInBundle:"moments_refresh_icon"))
        return imageView
    }()
    
    // MARK: - prepare
    
    override func prepare() {
        super.prepare()
        
        
        
        ignoredScrollViewContentInsetTop = -40.h
        mj_h = kHeaderHeight
        
        self.addSubview(rotateImageView)
        mj_y = -mj_h - ignoredScrollViewContentInsetTop;
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        rotateImageView.frame = CGRect(x: (UIScreen.main.bounds.width-30)/2, y: -20, width: 30, height: 30)
    }
    
    // MARK: - ScrollViewPanStateDidChange
    
    override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewPanStateDidChange(change)
        
        self.mj_y = -self.mj_h - self.ignoredScrollViewContentInsetTop;
        let scrollViewOffsetY: CGFloat = self.scrollView?.mj_offsetY ?? 0
        let pullingY: CGFloat = abs(scrollViewOffsetY + UIApplication.safeAreaInsets.top +
                                     self.ignoredScrollViewContentInsetTop)
        
        if (pullingY >= kHeaderHeight) {
            let marginY: CGFloat = -kHeaderHeight - (pullingY - kHeaderHeight) -
            self.ignoredScrollViewContentInsetTop
            self.mj_y = marginY
        }
    }
    
    // MARK: - MJRefreshState
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                rotateImageView.isHidden = true
            case .pulling:
                rotateImageView.isHidden = false
            case .refreshing:
                rotateImageView.isHidden = false
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                rotationAnimation.duration = 1.0
                rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
                rotationAnimation.repeatCount = .infinity
                rotateImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
            default:
                break
            }
        }
    }
}
