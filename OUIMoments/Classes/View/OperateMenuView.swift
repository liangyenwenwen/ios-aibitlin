import SnapKit
import UIKit

class OperateMenuView: UIView {
    
    private lazy var thumbupBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.init(nameInBundle: "moments_thumb_nomal_icon"), for: .normal)
        btn.setImage(.init(nameInBundle: "moments_thumb_selected_icon"), for: .selected)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        btn.setTitle("赞".innerLocalized(), for: .normal)
        btn.setTitle("取消".innerLocalized(), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var commentBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.init(nameInBundle: "moments_comment_nomal_icon"), for: .normal)
        btn.setTitle("评论".innerLocalized(), for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.tag = 1
        return btn
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: 160, height: 36)
        v.backgroundColor = UIColor(red: 0.36, green: 0.37, blue: 0.38, alpha: 1)
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        return v
    }()
    
    private lazy var separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        return v
    }()
    
    static func show(_ relative: UIView, isLiked: Bool, canComment: Bool, completed: ((Int)->Void)?) {
        let v = OperateMenuView(isLiked, canComment: canComment, completed: completed)
        UIApplication.shared.keyWindow?.addSubview(v)
        // 计算相对于屏幕的位置
        let frame = relative.convert(relative.bounds, to: UIApplication.shared.keyWindow)
        v.show(by: frame)
    }
    
    private var completed: ((Int)->Void)?
    private var canComment = true
    private init(_ isLiked: Bool, canComment: Bool, completed: ((Int)->Void)?) {
        super.init(frame: UIScreen.main.bounds)
        self.completed = completed
        thumbupBtn.isSelected = isLiked
        self.canComment = canComment
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubview(contentView)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        addGestureRecognizer(tap)
        
        contentView.addSubview(thumbupBtn)
        
        thumbupBtn.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.leading.centerY.equalToSuperview()
        }
        if canComment {
            contentView.addSubview(commentBtn)
            contentView.addSubview(separatorView)

            separatorView.snp.makeConstraints { (make) in
                make.width.equalTo(0.5)
                make.height.equalToSuperview().inset(5)
                make.leading.equalTo(thumbupBtn.snp.trailing)
                make.centerY.equalToSuperview()
            }
            commentBtn.snp.makeConstraints { (make) in
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.trailing.centerY.equalToSuperview()
            }
        }else {
            thumbupBtn.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    @objc func click(_ btn: UIButton) {
        hide()
        btn.isSelected = !btn.isSelected
        completed?(btn.tag)
    }
    
    func show(by relative: CGRect) {
        let width: CGFloat = canComment ? 160 : 80
        let originY = relative.midY - 36/2
        let originX = relative.minX - width - 10
        contentView.frame = CGRect(x: relative.minX, y: originY, width: 0, height: 36)
        UIView.animate(withDuration: 0.25) {
            self.contentView.frame.origin.y = originY
            self.contentView.frame.origin.x = originX
            self.contentView.frame.size.width = width
        }
    }
    
    @objc func hide() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.alpha = 0
        }) { (_) in
            self.alpha = 0
            self.removeFromSuperview()
        }
    }
}
