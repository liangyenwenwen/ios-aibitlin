import OUICore
import SnapKit
import RxSwift

class ForwardListCell: UITableViewCell {
    
    var onTap: ((_ value: String?) -> Void)?
    
    let avatarView = AvatarView()
    
    lazy var nikenameLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c8E9AB0
        v.font = .f12
        
        return v
    }()
    
    lazy var dateTimeLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c8E9AB0
        v.font = .f12
        
        return v
    }()
    
    lazy var msgContentView: UIView = {
        let v = UIView()
        
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal let disposeBag = DisposeBag()
    
    internal func setupSubviews() {
        contentView.backgroundColor = .cF8F9FA
        
        let hStack = UIStackView(arrangedSubviews: [nikenameLabel, UIView(), dateTimeLabel])
        
        let vStack = UIStackView(arrangedSubviews: [hStack, msgContentView])
        vStack.axis = .vertical
        vStack.spacing = 8
        
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(StandardUI.avatarWidth)
            make.leading.top.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.top.trailing.bottom.equalToSuperview().inset(10)
        }
        
        let tap = UITapGestureRecognizer()
        msgContentView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.handleTap()
        }).disposed(by: disposeBag)
    }
    
    internal let imageMaxWidth = 120.w
    internal func handleTap() {
        onTap?(nil)
    }
}

class ForwardListTextCell: ForwardListCell {
    lazy var textView: UITextView = {
        let v = UITextView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = true
        
        v.backgroundColor = .clear
        v.dataDetectorTypes = [.link]
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.textColor = .c0C1C33
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        msgContentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class ForwardListImageCell: ForwardListCell {
    lazy var msgImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .center
        v.layer.masksToBounds = true
        
        return v
    }()
    
    lazy var playImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "play.circle")?.withTintColor(.white))
        v.tintColor = .white
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        playImageView.isHidden = true
        playImageView.tintColor = .white
        
        msgContentView.addSubview(msgImageView)
        msgImageView.snp.makeConstraints { make in
            make.width.equalTo(120.w)
            make.height.equalTo(120.h)
            make.leading.top.bottom.equalToSuperview()
        }
        
        msgImageView.addSubview(playImageView)
        playImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(44)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if let image = msgImageView.image {
            var width = image.size.width
            var height = image.size.height
            
            if (imageMaxWidth < width) {
                width = imageMaxWidth
                height = width * image.size.height / image.size.width
            }
            
            msgImageView.snp.updateConstraints { make in
                make.height.equalTo(height)
                make.width.equalTo(width)
            }
        }
    }
}

class ForwardListLocationCell: ForwardListCell {
    lazy var mapImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .center
        v.layer.masksToBounds = true
        
        return v
    }()
    
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c0C1C33
        
        return v
    }()
    
    lazy var addressLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.layer.borderColor = UIColor.cE8EAEF.cgColor
        bgView.layer.borderWidth = 1
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(220.w)
        }
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel, line])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        
        bgView.addSubview(infoStack)
        bgView.addSubview(mapImageView)
        
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        infoStack.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(10)
        }
        
        mapImageView.snp.makeConstraints { make in
            make.top.equalTo(infoStack.snp.bottom)
            make.leading.bottom.equalTo(bgView)
            make.height.equalTo(79.h)
            make.width.equalTo(220.w)
        }
    }
}

class ForwardListCardCell: ForwardListCell {
    
    lazy var cardAvatarView = AvatarView()
    
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 17)
        v.textColor = .c0C1C33
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.layer.borderColor = UIColor.cE8EAEF.cgColor
        bgView.layer.borderWidth = 1
        bgView.backgroundColor = .cellBackgroundColor
        
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(220.w)
        }
        
        let infoStack = UIStackView(arrangedSubviews: [cardAvatarView, nameLabel])
        infoStack.spacing = 8
        infoStack.alignment = .center
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        
        let label = UILabel()
        label.text = "carte".innerLocalized()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.c8E9AB0
        
        let columStack = UIStackView(arrangedSubviews: [infoStack, line, label])
        columStack.spacing = 8
        columStack.axis = .vertical
        
        bgView.addSubview(columStack)
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        columStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
}

class ForwardListMergeCell: ForwardListCell {
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 1
        v.font = .f17
        v.textColor = .c0C1C33
        v.contentMode = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    private lazy var labelsStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        
        let line = UIView()
        line.backgroundColor = .cE8EAEF
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let v = UIStackView(arrangedSubviews: [UIView(), titleLabel, line, labelsStack])
        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var abstracts: [String]? {
        didSet {
            let labels = abstracts?.prefix(4).map({ text in
                let v = UILabel()
                v.numberOfLines = 3
                v.font = .f14
                v.textColor = .c8E9AB0
                v.lineBreakMode = .byTruncatingTail
                v.translatesAutoresizingMaskIntoConstraints = false
                v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
                v.text = text
                
                return v
            })
            
            labels?.forEach({ labelsStack.addArrangedSubview($0) })
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.layer.borderColor = UIColor.cE8EAEF.cgColor
        bgView.layer.borderWidth = 1
        bgView.backgroundColor = .cellBackgroundColor
        
        
        msgContentView.addSubview(bgView)
        bgView.addSubview(contentStack)
        
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(220.w)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }
}

class ForwardListAudioCell: ForwardListCell {
    
    var duration: Int = 0 {
        didSet {
            durationLabel.text = #"\#(duration)``"#
        }
    }
    
    var url: URL!
    
    private enum AudioViewState {
        case idle
        case loading
        case play
    }
    
    private var state: AudioViewState = .idle {
        didSet {
            switch state {
            case .loading, .idle:
                iconImageView.isHighlighted = true
            case .play:
                iconImageView.isHighlighted = false
            }
        }
    }
    
    private lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.text = #"\#(0)``"#
        v.textColor = .c0089FF
        
        return v
    }()
    
    lazy var iconImageView: UIImageView = {
        let v = UIImageView()
        v.highlightedImage = UIImage(nameInBundle: "chat_msg_audio_record_normal")?.withTintColor(.c0089FF)
        v.loadGif(name: "chat_msg_audio_record_play")
        v.isHighlighted = true
        
        return v
    }()
    
    lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [iconImageView, durationLabel])
        v.spacing = 4
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.backgroundColor = .cF4F5F7
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        bgView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4.h)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
    }
    
    override func handleTap() {
        playback()
    }
    
    func playback() {
        let audioPlayController = AudioPlayController.shared
        let messageId = url.absoluteString.md5
        
        // 点击的下一条
        if audioPlayController.isPausing(messageID: messageId) || audioPlayController.isPlaying(messageID: messageId) {
            // 如果处于暂停中，就播放
            if audioPlayController.isPausing(messageID: messageId) {
                audioPlayController.play(url: url, messageID: messageId)
                state = .play
            } else if audioPlayController.isPlaying(messageID: messageId) {
                // 如果点击的是正在播放的语音，就暂停
                audioPlayController.pause(messageID: messageId)
                state = .idle
            }
            
            return
        }
        // 先停止上一条的播放
        audioPlayController.stop()
        // 开始缓存
        audioPlayController.focus(messageID: messageId)
        
        if url.isFileURL {
            audioPlayController.play(url: url, messageID: messageId)
            state = .play
        } else {
            let localURL = FileHelper.shared.exsit(path: url.absoluteString)
            // 如果沙盒不存在，就下载
            if localURL == nil {
                FileDownloadManager.manager.downloadMessageFile(messageID: messageId, url: url) { [weak self] msgID, location in
                    // 保存
                    let r = URL(fileURLWithPath: FileHelper.shared.saveAudio(from: location.path, name: location.lastPathComponent).fullPath)
                    // 播放 - 确认缓冲好以后没有切换 audio message
                    if audioPlayController.isFocus(messageID: msgID) {
                        DispatchQueue.main.async {
                            audioPlayController.play(url: r, messageID: msgID)
                            self?.state = .play
                        }
                    }
                }
            } else {
                let url = URL(fileURLWithPath: localURL!)
                audioPlayController.play(url: url, messageID: messageId)
                state = .play
            }
        }
        
        audioPlayController.didFinishPlaying = { [weak self] msgID in
            guard messageId == msgID else { return }
            self?.state = .idle
        }
    }
}

class ForwardListFileCell: ForwardListCell {
    
    var length: Int = 0 {
        didSet {
            lengthLabel.text = FileHelper.formatLength(length: length)
        }
    }
    
    var url: URL! {
        didSet {
            obtainIconImage(url: url)
            if FileHelper.shared.exsit(path: url.relativeString, name: nameLabel.text) != nil {
                status = .completion
            }
        }
    }
    
    private lazy var statusButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        v.setImage(UIImage(systemName: "pause.circle"), for: .selected)
        v.setImage(nil, for: .disabled)
        v.backgroundColor = .clear
        v.tintColor = .white
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.toggleDownloadStatus()
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .center
        
        return v
    }()
    
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        v.lineBreakMode = .byTruncatingMiddle
        
        return v
    }()
    
    private lazy var lengthLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    private enum FileDownloadStatus {
        case normal
        case downloading
        case paused
        case completion
    }
    
    private lazy var progressView = CircleProgressView()
    
    private var downloadRequest: FileDownloadRequest?
    
    private func toggleDownloadStatus() {
        if status == .normal {
            statusButton.isSelected = true
            resume()
        } else if status == .downloading {
            statusButton.isSelected = false
            pause()
        } else if status == .paused {
            resume()
        }
    }
    
    private var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
        }
    }
    
    private var status: FileDownloadStatus = .normal {
        didSet {
            if status == .normal || status == .paused {
                statusButton.isSelected = false
            } else if status == .downloading {
                statusButton.isSelected = true
                progressView.progress = progress
            } else if status == .completion {
                progressView.isHidden = true
                statusButton.isHidden = true
                iconImageView.isHighlighted = true
            }
        }
    }
    
    private func pause() {
        status = .paused
        downloadRequest?.request.suspend()
    }
    
    private func resume() {
        status = .downloading
        
        if downloadRequest == nil {
            loadFile()
        } else {
            downloadRequest?.request.resume()
        }
    }
    
    private func cancel() {
        downloadRequest?.request.cancel()
    }
    
    override func prepareForReuse() {
        let messageId = url.md5
        let name = nameLabel.text
        
        if let req = FileDownloadManager.manager.downloadRequest(messageID: messageId) {
            downloadRequest = req
            FileDownloadManager.manager.setExistsTaskHandler(messageID: messageId) { [self] (messageID, written, total) in
                
                guard messageId == messageID else { return }
                
                DispatchQueue.main.async { [self] in
                    self.progress = CGFloat(written) / CGFloat(total)
                }
            } completion: { [weak self] (messageID, url) in
                FileHelper.shared.saveFile(from: url.path, name: name)
                
                DispatchQueue.main.async { [self] in
                    guard let self else { return }
                    self.status = .completion
                }
            }
        }
    }
    
    private func loadFile() {
        let messageId = url.md5
        let name = nameLabel.text
        
        downloadRequest = FileDownloadManager.manager.downloadMessageFile(messageID: messageId,
                                                                          url: url,
                                                                          name: name) { [self] (messageID, written, total) in
            
            guard messageId == messageID else { return }
            
            DispatchQueue.main.async { [self] in
                self.progress = CGFloat(written) / CGFloat(total)
            }
        } completion: { [weak self] (messageID, url) in
            FileHelper.shared.saveFile(from: url.path, name: name)
            
            DispatchQueue.main.async { [self] in
                guard let self else { return }
                self.status = .completion
            }
        }
    }
    
    private func obtainIconImage(url: URL) {
        var image: UIImage?
        var highlightedImage: UIImage?
        let ext = url.relativeString.split(separator: ".").last
        
        switch ext {
        case "xls", "xlsx":
            image = UIImage(nameInBundle: "chat_msg_file_excel_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_excel_normal_icon")
        case "ppt", "pptx":
            image = UIImage(nameInBundle: "chat_msg_file_ppt_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_ppt_normal_icon")
        case "doc", "docx":
            image = UIImage(nameInBundle: "chat_msg_file_word_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_word_normal_icon")
        case "pdf":
            image = UIImage(nameInBundle: "chat_msg_file_pdf_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_pdf_normal_icon")
        case "zip", "rar", "7z":
            image = UIImage(nameInBundle: "chat_msg_file_zip_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_zip_normal_icon")
        default:
            image = UIImage(nameInBundle: "chat_msg_file_unknown_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_unknown_normal_icon")
        }
        
        iconImageView.image = image
        iconImageView.highlightedImage = highlightedImage
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.layer.borderColor = UIColor.cE8EAEF.cgColor
        bgView.layer.borderWidth = 1
        bgView.backgroundColor = .cellBackgroundColor
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(64.h)
            make.width.equalTo(247.w)
        }
        
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, lengthLabel])
        infoStack.spacing = 8
        infoStack.axis = .vertical
        
        let iconView = UIView()
        iconView.addSubview(iconImageView)
        iconView.addSubview(statusButton)
        iconView.addSubview(progressView)
        
        progressView.isUserInteractionEnabled = false
        
        iconView.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statusButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.center.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalTo(iconView)
            make.size.equalTo(20)
        }
        
        let rowStack = UIStackView(arrangedSubviews: [infoStack, UIView(), iconView])
        rowStack.distribution = .fill
        rowStack.alignment = .center
        rowStack.backgroundColor = .clear
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(rowStack)
        rowStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.trailing.equalToSuperview()
        }
    }
    
    override func handleTap() {
        if let path = FileHelper.shared.exsit(path: url.relativeString, name: nameLabel.text) {
            onTap?(path)
        } else {
            if status == .downloading {
                pause()
            } else {
                resume()
            }
        }
    }
}

class ForwardListCustomCell: ForwardListCell {
    lazy var textView: UITextView = {
        let v = UITextView()
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.spellCheckingType = .no
        v.backgroundColor = .clear
        v.dataDetectorTypes = .link
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isExclusiveTouch = true
        v.isUserInteractionEnabled = false
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textColor = .c0C1C33
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue,
                                .underlineStyle: 1]
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.backgroundColor = .cF4F5F7
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4.h)
        }
    }
}

class ForwardListBlankCustomCell: ForwardListCell {
    lazy var textView: UITextView = {
        let v = UITextView()
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.spellCheckingType = .no
        v.backgroundColor = .clear
        v.dataDetectorTypes = .link
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isExclusiveTouch = true
        v.isUserInteractionEnabled = false
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textColor = .c0C1C33
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue,
                                .underlineStyle: 1]
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let bgView = UIView()
        bgView.layer.cornerRadius = StandardUI.cornerRadius
        bgView.layer.borderColor = UIColor.cE8EAEF.cgColor
        bgView.layer.borderWidth = 1
        bgView.backgroundColor = .cellBackgroundColor
        
        msgContentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(247.w)
        }
        
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class ForwardListQuoteCell: ForwardListCell {
     lazy var textView: UITextView = {
        let v = UITextView()
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        v.isEditable = false
        v.isSelectable = true
        v.isUserInteractionEnabled = true
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.spellCheckingType = .no
        v.dataDetectorTypes = [.link]
        v.font = .f17
        v.scrollsToTop = false
        v.bounces = false
        v.bouncesZoom = false
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.isExclusiveTouch = true
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.textContainer.lineBreakMode = .byCharWrapping
        v.textContainer.lineFragmentPadding = 0
        v.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        v.backgroundColor = .cCCE7FE
        
        return v
    }()
    
    lazy var replyTextView: UITextView = {
        let v = UITextView()
        v.backgroundColor = .cF4F5F7
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = false
        v.font = .f12
        v.scrollsToTop = false
        v.bounces = false
        v.textContainer.maximumNumberOfLines = 2
        v.setContentCompressionResistancePriority(UILayoutPriority(998), for: .vertical)
        v.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        v.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: 0]
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.textContainer.lineBreakMode = .byTruncatingTail
        v.textContainer.lineFragmentPadding = 0
        v.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return v
    }()
    
    lazy var playButtonImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "play.circle"))
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 8).isActive = true
        v.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        return v
    }()
    
    private lazy var attachmentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .cF4F5F7
        v.layer.cornerRadius = 3.0
        
        let tap = UITapGestureRecognizer()
        v.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.onTap?(nil)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    lazy var attachmentImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 20).isActive = true
        v.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return v
    }()
    
    private lazy var textStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [textView, UIView()])
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var replyStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [replyTextView, attachmentImageView, UIView()])
        v.alignment = .center
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        let vStack = UIStackView(arrangedSubviews: [textStack, replyStack])
        vStack.axis = .vertical
        vStack.spacing = 4
        
        msgContentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        attachmentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        
        attachmentImageView.addSubview(playButtonImageView)
        playButtonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
