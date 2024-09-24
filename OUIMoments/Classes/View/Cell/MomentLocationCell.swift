
import Foundation
import IGListKit

class MomentLocationCell: UICollectionViewCell {
    
    var viewModel: MomentsInfo?
    
    fileprivate lazy var locationBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame.origin = CGPoint(x: MomentContentLeftPadding, y: 0)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        contentView.addSubview(locationBtn)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @objc func click(_ btn: UIButton) {
    }
}

extension MomentLocationCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? MomentsInfo else { return }
        self.viewModel = viewModel
        locationBtn.setTitle(viewModel.location, for: .normal)
        locationBtn.sizeToFit()
    }
}
