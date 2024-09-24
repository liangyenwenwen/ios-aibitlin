//
//  ContentContainerView.swift
//  OUIIM
//
//  Created by x on 2023/11/28.
//

import Foundation
import OUICore

final class ContentContainerView<ContentView: UIView>: UIView {
    
    public lazy var contentView = ContentView(frame: bounds)
    
    private var onTapRead: (() -> Void)?
    private var onTapStatus: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .systemGray2
        v.font = .f12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        
        return v
    }()
    
    // Failed to send status
    private lazy var errorButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
        v.tintColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        v.addTarget(self, action: #selector(errorButtonAction(_:)), for: .touchUpInside)
        
        return v
    }()
    
    @objc private func errorButtonAction(_ sender: UIButton) {
        onTapStatus?()
        sender.isHiddenSafe = true
        showStutusIndicator()
    }
    
    // Message sending status
    private lazy var statusIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var readStatusLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0089FF
        v.font = .f12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .right
        v.isUserInteractionEnabled = true
        v.text = " "
        v.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        
        v.addGestureRecognizer(tap)
        
        return v
    }()
    
    @objc private func tapAction() {
        onTapRead?()
    }
    
    private var timer: DispatchSourceTimer?
    private var countdownTime: Int = 0
    
    // Burn After Reading Countdown
    private lazy var countdownLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c8E9AB0
        v.font = .f12
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    // Add a read mark to received voice messages.
    private let dotView: UIView = {
        let dotSize: CGFloat = 6.0
        
        let v = UIView()
        v.layer.cornerRadius = dotSize / 2.0
        v.layer.masksToBounds = true
        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: dotSize).isActive = true
        v.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
        v.isHidden = true
        
        return v
    }()
    
    private let blankView = UIView()
    
    private lazy var contentStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [errorButton, statusIndicator, contentView, dotView])
        v.spacing = 8
        v.alignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(titleLabel)
        // WARNING: If they are added to the stackview, the name will not be fully displayed when the text is very short.
        addSubview(contentStack)
        
        //去除已读lbl
        addSubview(readStatusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            
            contentStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            contentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -8),
            
            readStatusLabel.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 0),
            readStatusLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            readStatusLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            readStatusLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContentContainerView {
    
    public func showStutusIndicator(_ show: Bool = true) {
        if show {
            statusIndicator.isHiddenSafe = false
            statusIndicator.startAnimating()
        } else {
            statusIndicator.isHiddenSafe = true
        }
    }
    
    public func showErrorButton(_ show: Bool = false, onTapStatus: (() -> Void)? = nil) {
        errorButton.isHiddenSafe = !show
        self.onTapStatus = onTapStatus
    }
    
    // Set whether to burn after reading
    public func setPrivateChat(isPrivate: Bool = false, hasReadTime: Double = 0, duration: Double = 0, completion: @escaping (() -> Void)) {
        
        timer?.cancel()
        timer = nil
        
        countdownLabel.isHidden = true
        countdownLabel.text = nil
        
        let shouldCountDown = hasReadTime > 0
        
        guard isPrivate, shouldCountDown else { return }
        
        countdownLabel.isHidden = false
        
        let timestamp = NSDate().timeIntervalSince1970 * 1000
        let adjustDuration = duration == 0 ? 30 : duration
        
        if (hasReadTime > 0) {
            let end = hasReadTime + (adjustDuration * 1000)
            var diff = (end - timestamp) / 1000
            countdownTime = Int(ceil(diff < 0 ? 0 : diff))
        }
        
        if countdownTime <= 0 {
            timer?.cancel()
            timer = nil
            completion()
            
            return
        }
        
        if timer == nil, countdownTime > 0 {
            timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.private.timer.\(hasReadTime)"))
            timer?.schedule(deadline: .now(), repeating: .seconds(1))
            timer?.setEventHandler(handler: {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    if countdownTime <= 0 {
                        countdownLabel.text = nil
                        timer?.cancel()
                        timer = nil
                        completion()
                    } else {
                        countdownLabel.text = "\(countdownTime) s"
                    }
                    
                    countdownTime -= 1
                }
            })
            timer?.resume()
        }
    }
    
    // 设置已读标识
    func setReadStatus(allReaded: Bool = false, title: String?, completion: (() -> Void)? = nil) {
        let showTips = title?.isEmpty == false
        readStatusLabel.text = showTips ? title : " "
        readStatusLabel.textColor = allReaded ? .c8E9AB0 : .c0089FF
        onTapRead = showTips ? completion : nil
    }
    
    func hidenReadStatusLbl(_ isHidden: Bool) {
        readStatusLabel.isHidden = isHidden
    }
    
    func setTitle(title: String?, messageType: MessageType) {
        titleLabel.text = title
        titleLabel.textAlignment = messageType == .outgoing ? .right : .left
        
        contentStack.removeArrangedSubview(blankView)
        
        if messageType == .outgoing {
            contentStack.insertArrangedSubview(countdownLabel, at: 0)
            contentStack.insertArrangedSubview(blankView, at: 0)
        } else {
            contentStack.addArrangedSubview(countdownLabel)
            contentStack.addArrangedSubview(blankView)
        }
    }
    
    func showDotView(_ show: Bool = true) {
        dotView.isHiddenSafe = !show
    }
}
