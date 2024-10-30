//
//  CallRecordSameHistoryView.swift
//  OUIIM
//
//  Created by mac on 2024/10/30.
//

import Foundation
import OUICalling

class CallRecordSameHistoryView: UIView, UITableViewDelegate, UITableViewDataSource{
    
    var record:CallRecord!
    var dataSource:[CallRecord] = []
    var sectionDataSource:[String:[CallRecord]] = [:]
    
    static func build(record: CallRecord) -> CallRecordSameHistoryView{
        let r = CallRecordSameHistoryView()
        r.record = record
        return r
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let view = centerView
        let point = touch.location(in: self)
        let tPoint = view.convert(point, from: self)
        if view.point(inside: tPoint, with: event) {return}
        self.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(centerView)
        backgroundColor = .black.withAlphaComponent(0.5)
        
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(306)
            make.centerY.equalToSuperview()
        }
        
        centerView.addSubview(userIcon)
        centerView.addSubview(userName)
        centerView.addSubview(cancelImg)
        centerView.addSubview(lineView)
        
        userIcon.snp.makeConstraints { make in
            make.top.leading.equalTo(16)
            make.width.height.equalTo(36)
        }
        
        userName.snp.makeConstraints { make in
            make.centerY.equalTo(userIcon)
            make.left.equalTo(userIcon.snp_right).offset(10)
            make.right.equalTo(-52)
        }
        
        cancelImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(-16)
            make.width.height.equalTo(28)
            make.centerY.equalTo(userIcon)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(65)
            make.height.equalTo(1)
        }
        
        centerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(66)
            make.left.right.bottom.equalToSuperview()
        }
        
        
        
    }
    
    lazy var centerView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.clipsToBounds = true
        r.layer.cornerRadius = 14
        return r
    }()
    
    lazy var userIcon: UIImageView = {
        let r = UIImageView()
        r.corner(radius: 18)
        return r
    }()
    
    lazy var userName: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        return r
    }()
    
    lazy var cancelImg: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    
    lazy var tableView: UITableView = {
        let r = UITableView(frame: .zero, style: .grouped)
        r.register(CallRecordSameHistoryListCell.self, forCellReuseIdentifier: CallRecordSameHistoryListCell.className)
        r.delegate = self
        r.dataSource = self
        r.separatorStyle = .none
        r.backgroundColor = .white
        return r
    }()
    
}

//, UITableViewDelegate, UITableViewDataSource
extension CallRecordSameHistoryView {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataSource.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionListArr(section: section).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CallRecordSameHistoryListCell.className, for: indexPath) as! CallRecordSameHistoryListCell
        let record = recordAbout(indexPath: indexPath)
        cell.bindData(model: record)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let r = CallRecordSameHistoryListSectionHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 41))
        r.bindData(timeStr: sectionTitleArr()[section])
        return r
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 41
    }
    
    
    
    func updateUI() {
        userIcon.setImageAbout(string: record.faceURL, placeHolder: "DefaultAvatar")
        
        let sameCount = record.sameCount == 1 ? "" : " (\(record.sameCount))"
        userName.text = SuperStringUtil.getUserState(showname: record.nickname ?? "").n  + "\(sameCount)"
        userName.textColor = record.success ? .init(hexString: "#333333") :  .init(hexString: "#FF3939")
        
        self.dataSource = CallRecord.fromJson(record.historyLogs)

        calculateDataSource()
        
    }
    
    func calculateDataSource() {
        
        for record in self.dataSource {
            
            if !sectionDataSource.keys.contains(record.formatDateAboutYMDStr()) {
                sectionDataSource[record.formatDateAboutYMDStr()] = []
                sectionDataSource[record.formatDateAboutYMDStr()]?.append(record)
            } else {
                sectionDataSource[record.formatDateAboutYMDStr()]?.append(record)
            }
            
        }
        print(sectionDataSource)
        
    }
    
    func sectionTitleArr() -> [String] {
        sectionDataSource.keys.sorted().reversed()
    }
    
    func sectionListArr(section: Int) -> [CallRecord] {
        let result = sectionDataSource[sectionTitleArr()[section]]
        return result!.sorted { $0.date > $1.date }
    }
    
    func recordAbout(indexPath: IndexPath) -> CallRecord {
        let result = sectionDataSource[sectionTitleArr()[indexPath.section]]
        let sortArr =  result!.sorted { $0.date > $1.date }
        return sortArr[indexPath.row]
    }
    
    
}


class CallRecordSameHistoryListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftIconImg: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.contentMode = .scaleAspectFill
//        r.backgroundColor = .red
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "username"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textAlignment = .left
        r.text = "9:11 呼入"
        return r
    }()
    
    
    func initUI() {
        
        contentView.addSubview(leftIconImg)
        contentView.addSubview(titleLbl)
        
        
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
        }
        
    }
    
    func bindData(model: CallRecord) {
        
        leftIconImg.image = model.type == "audio"  ? .init(named: "call_log_auido") : .init(named: "call_log_video")
        titleLbl.text = "\(model.formatDateAboutHMStr()) \(model.inOrOutStr()) \(model.durationStr())"
    }
    
}

class CallRecordSameHistoryListSectionHeader: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(sectionLbl)
        
        sectionLbl.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
    lazy var sectionLbl: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#333333")
        r.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return r
    }()
    
    func bindData(timeStr: String) {
        sectionLbl.text = timeStr
    }
    
}
