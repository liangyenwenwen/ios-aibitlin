
import Foundation
import IGListKit
import RxSwift
import SnapKit

class MomentNewMessageCell: UICollectionViewCell {
    
    let disposeBag = DisposeBag()
    
    lazy var valueLabel: UILabel = {
        let v = UILabel()
        v.layer.cornerRadius = 6
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        v.textColor = .white
        v.font = .systemFont(ofSize: 14)
        v.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?()
        }).disposed(by: disposeBag)
        v.addGestureRecognizer(tap)
        return v
    }()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cellBackgroundColor
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(28.h)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MomentNewMessageCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? HeaderInfo else {
            return
        }
        
        valueLabel.text = " \("nMessage".innerLocalizedFormat(arguments: viewModel.newMsgCount)) "
    }
}
