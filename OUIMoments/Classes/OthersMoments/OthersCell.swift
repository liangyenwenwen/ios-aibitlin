
import OUICore

class OthersCell: UITableViewCell {
    
    public lazy var dayLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0C1C33
        v.font = .f17
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        
        return v
        
    }()
    
    public lazy var monthLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0C1C33
        v.font = .f12
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)

        return v
        
    }()
    
    public lazy var previewImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.masksToBounds = true
        v.isHidden = true
        
        return v
    }()
    
    public lazy var mediaCountLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c8E9AB0
        v.font = .f12
        
        return v
    }()
    
    public lazy var wordLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0C1C33
        v.font = .f14
        v.numberOfLines = 3
        v.lineBreakMode = .byTruncatingTail
        v.backgroundColor = .cE8EAEF
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)

        return v
    }()
    
    public lazy var playButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(systemName: "play.circle"), for: .normal)
        v.tintColor = .white
        v.isHidden = true
        
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .cellBackgroundColor
        selectionStyle = .none
        
        let dateStack = UIStackView(arrangedSubviews: [dayLabel, monthLabel])
        dateStack.axis = .vertical
        dateStack.spacing = 8
        
        let wordStack = UIStackView(arrangedSubviews: [wordLabel, UIView(), mediaCountLabel])
        wordStack.axis = .vertical
        wordStack.spacing = 4
        
        let hStack = UIStackView(arrangedSubviews: [dateStack, previewImageView, wordStack])
        hStack.spacing = 8
        hStack.alignment = .top
        
        contentView.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        previewImageView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        previewImageView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordLabel.text = nil
        previewImageView.image = nil
        mediaCountLabel.text = nil
        previewImageView.isHidden = true
        dayLabel.textColor = .c0C1C33
        monthLabel.textColor = .c0C1C33
    }
}
