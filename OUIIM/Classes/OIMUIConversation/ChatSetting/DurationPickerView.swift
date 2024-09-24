import OUICore

class DurationPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var durationSelectionHandler: ((_ value: Int, _ unit: String) -> Void)?
    
    init(values: [Int], units: [String], column: Int = 2) {
        super.init(frame: .zero)
        self.column = column
        self.numbersRange = values
        self.units = units
        
        setupViews()
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
        self.alpha = 0
        
        UIView.animate(withDuration: 0.3) { [self] in
            self.alpha = 1
        }
    }
    
    static func durationString(seconds: Int) -> String {
        if seconds == 30 {
            return "30" + "秒".innerLocalized()
        } else if seconds == 300 {
            return "5" + "分钟".innerLocalized()
        } else if seconds == 3600 {
            return "1" + "小时".innerLocalized()
        } else {
            let days = seconds / (24 * 3600)
            let weeks = days / 7
            let months = weeks / 4
            
            if days < 6 {
                return String(days) + "天".innerLocalized()
            } else if (weeks <= 6 && (days % 7 == 0)) {
                return String(weeks) + "周".innerLocalized()
            } else {
                return String(months) + "月".innerLocalized()
            }
        }
    }
    
    private var column: Int!
    
    private var numbersRange: [Int]!
    private var units: [String]!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .c0C1C33
        label.font = .f17
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .c8E9AB0
        label.font = .f14
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .cellBackgroundColor
        
        return picker
    }()
    
    private lazy var cancelButton: UIButton = {
        let v = UIButton(type: .system)
        v.tintColor = .c0C1C33
        v.setTitle("cancel".innerLocalized(), for: .normal)
        v.titleLabel?.font = .f17
        v.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        
        return v
    }()
    
    @objc
    private func cancelAction(_ sender: UIButton) {
        dismiss()
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3) { [self] in
            self.alpha = 0
        } completion: { [self] finished in
            self.removeFromSuperview()
        }
    }
    
    private lazy var confirmButton: UIButton = {
        let v = UIButton(type: .system)
        v.tintColor = .c0089FF
        v.setTitle("confirm".innerLocalized(), for: .normal)
        v.titleLabel?.font = .f17
        v.addTarget(self, action: #selector(confirmAction(_:)), for: .touchUpInside)
        
        return v
    }()
    
    @objc
    private func confirmAction(_ sender: UIButton) {
        let index = pickerView.selectedRow(inComponent: 0)
        let selectedNumber = numbersRange[index]
        let selectedUnit = column == 2 ? units[pickerView.selectedRow(inComponent: 1)] : units[index]

        dismiss()
        durationSelectionHandler?(selectedNumber, selectedUnit)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        backgroundColor = .black.withAlphaComponent(0.7)
        
        let contentView = UIView()
        contentView.backgroundColor = .cE6F0FC
        contentView.layer.cornerRadius = 30
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(42)
        }
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, descLabel, pickerView])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8
        contentView.addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
        }
        
        pickerView.snp.makeConstraints { make in
            make.height.equalTo(182.h)
        }
        
        let hStack = UIStackView(arrangedSubviews: [UIView(), cancelButton, confirmButton])
        hStack.alignment = .trailing
        hStack.spacing = 46.w
        contentView.addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(25.w)
            make.top.equalTo(vStack.snp.bottom).offset(20.h)
        }
        
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelAction(_:)))
        addGestureRecognizer(tap)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if column == 2 {
            if component == 0 {
                return numbersRange.count
            } else {
                return units.count
            }
        } else {
            return numbersRange.count
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if column == 2 {
            if component == 0 {
                return "\(numbersRange[row])"
            } else {
                return units[row]
            }
        } else {
            return "\(numbersRange[row])\(units[row])"
        }
    }
}
