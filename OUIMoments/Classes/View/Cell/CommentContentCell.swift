
import OUICore
import SnapKit
import RxSwift

class CommentContentCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    let senderScheme = ":sender"
    let othersScheme = ":others"
    
    lazy var commentTextView: UITextView = {
        
        let v = UITextView()
        v.font = .f14
        v.isEditable = false
        v.isScrollEnabled = false
        v.isSelectable = false
        v.textColor = .c0C1C33
        v.delegate = self
        v.backgroundColor = .clear
        v.textContainerInset = .init(top: 2, left: 2, bottom: 2, right: 2)
        v.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hex: 0x6085b1)]
        v.textContainer.lineFragmentPadding = 0;
        
        let tap = UITapGestureRecognizer()
        v.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            sself.onTextClick?()
        }).disposed(by: disposeBag)
        
        let long = UILongPressGestureRecognizer()
        v.addGestureRecognizer(long)
        long.rx.event.subscribe(onNext: { [weak self] sender in
            guard let `self` = self, self.canLongPress?() == true, sender.state == .began else { return }
            self.becomeFirstResponder() 
            let menuController = UIMenuController.shared
            let deleteItem = UIMenuItem(title: "删除", action: #selector(self.onDelete))
            menuController.menuItems = [deleteItem]
            menuController.showMenu(from: v, rect: self.bounds)
        }).disposed(by: disposeBag)
        return v
    }()
    
    @objc func onDelete(_ sender: UILongPressGestureRecognizer)  {
        self.onClick?(.deleteComment)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onDelete) {
            return true
        }
        
        return false
    }
    
    var canLongPress: (() -> Bool)?
    var onClick: ((MomentAction) -> Void)?
    var onTextClick: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .cF8F9FA
        
        contentView.addSubview(commentTextView)
        commentTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setMultiLabel(_ label: MomentLabel) {
        let reply = LabelType.custom(pattern: "回复(.+)：", start: 2, tender: -1)
        label.customColor = [reply: .c6085B1]
        label.enabledTypes = [.URL, .phone, reply]
        label.handleNormalTap {[weak self] text in
            self?.onTextClick?()
        }
        label.handleCustomTap(reply) {[weak self] (text) in
            self?.onClick?(.reply)
        }
        label.handleURLTap { (text) in
            let url = URL(string: text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        label.handlePhoneTap { (phone) in
            UIApplication.shared.openURL(URL(string: "tel://\(phone)")!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func viewClick(_ ges: UIGestureRecognizer) {
        onClick?(.avatar)
    }
    
    @objc private func senderTapAction(_ btn: UIButton) {
        onClick?(.title)
    }
    
    @objc private func othersTapAction(_ btn: UIButton) {
        onClick?(.title)
    }
}

extension CommentContentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(URL)")
        
        return false
    }
}
