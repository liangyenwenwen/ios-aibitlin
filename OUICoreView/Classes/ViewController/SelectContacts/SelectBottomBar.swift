import OUICore
import UIKit
import RxSwift

enum SelectBottomBarType {
    case selected
    case complete
}

public class SelectBottomBar: UIView {
    
    var maxCount: Int = 1000 {
        didSet {
            completeBtn.setTitle("\("确定".innerLocalized())(\(selectedCount)/\(maxCount))", for: .normal)
        }
    }
    
    var selectedCount: Int = 0 {
        didSet {
            completeBtn.isEnabled = selectedCount > 0
            completeBtn.setTitle("\("确定".innerLocalized())(\(selectedCount)/\(maxCount))", for: .normal)
            selectCountBtn.setTitle("\("已选择".innerLocalized()):(\(selectedCount))", for: .normal)
        }
    }
    
    var names: String = "" {
        didSet {
            namesLabel.text = names
        }
    }
    
    var onTap: ((SelectBottomBarType) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    private lazy var completeBtn: UIButton = {
        let v = UIButton(type: .system)
        v.layer.cornerRadius = 4
        v.backgroundColor = .c0089FF
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = .f14
        v.contentEdgeInsets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)
        v.setTitle("\("确定".innerLocalized())(0/\(maxCount))", for: .normal)
        v.isEnabled = false
        
        v.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.onTap?(.complete)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    private lazy var selectCountBtn: LayoutButton = {
        let v = LayoutButton(imagePosition: .right, atSpace: 7)
        v.setImage(UIImage(nameInBundle: "common_blue_arrow_up_icon"), for: .normal)
        v.titleLabel?.font = .f14
        v.setTitleColor(.c0089FF, for: .normal)
        v.setTitle("\("已选择".innerLocalized()):(0)", for: .normal)

        v.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.onTap?(.selected)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    private let namesLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c8E9AB0
        v.font = .f14
        v.numberOfLines = 1
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        selectedCount = 0
        
        let vStack = UIStackView(arrangedSubviews: [selectCountBtn, namesLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .leading
        
        let hStack = UIStackView(arrangedSubviews: [vStack, completeBtn])
        hStack.alignment = .center
        hStack.spacing = 8
        
        addSubview(hStack)
        
        completeBtn.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        hStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(60)
        }
        
        let safeAreaInsets = UIApplication.safeAreaInsets
        let spacer = UIView()
        
        addSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(hStack.snp.bottom)
            make.height.equalTo(safeAreaInsets.bottom)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
