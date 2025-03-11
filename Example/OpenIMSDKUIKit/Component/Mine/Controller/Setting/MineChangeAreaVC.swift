//
//  MineChangeAreaVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/3/6.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
class MineChangeAreaVC: UITableViewController {
    
    private let dataArray : [[String: Any]] = [["areaName":"中国大陆","code":"cn","icon":"area_cn_icon"],["areaName":"中国香港","code":"hk","icon":"area_hk_icon"],["areaName":"中国澳门","code":"mo","icon":"area_mo_icon"],["areaName":"泰国","code":"th","icon":"area_th_icon"],["areaName":"菲律宾","code":"ph","icon":"area_ph_icon"],["areaName":"新加坡","code":"sg","icon":"area_sg_icon"],["areaName":"马来西亚","code":"my","icon":"area_my_icon"],["areaName":"越南","code":"vn","icon":"area_vn_icon"],["areaName":"日本","code":"jp","icon":"area_jp_icon"],["areaName":"美国","code":"us","icon":"area_us_icon"],["areaName":"其他","code":"hk","icon":""]]
    
    private var chooseArea: String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseArea = UserDefaults.standard.string(forKey: "chooseArea") ?? "中国"
        configureTableView()
        title = "地区".localized()
    }

    private func configureTableView() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.register(MineChangeAreaCell.self, forCellReuseIdentifier: MineChangeAreaCell.className)
        tableView.rowHeight = 60
        tableView.backgroundColor = .viewBackgroundColor
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MineChangeAreaCell.className) as! MineChangeAreaCell
        cell.iconImageView.image = UIImage(named: data["icon"] as? String ?? "")
        let area = data["areaName"] as? String ?? "中国大陆"
        cell.titleLabel.text = area.localized()
        cell.selectImageView.isHidden = !(area == chooseArea)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        16
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = dataArray[indexPath.row]["areaName"] as? String ?? "中国大陆"
        if area != chooseArea{
            let alert = UIAlertController(title: "提醒".localized(), message: "切换地区需要手动重启App，确认切换地区吗", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "取消".localized(), style: .cancel, handler:nil)
            // 设置按钮文本颜色
            cancleAction.setValue(UIColor.black999, forKey: "titleTextColor")
            alert.addAction(cancleAction)
            let okAction = UIAlertAction(title: "立即切换".localized(), style: .default) { (action) in
                // 处理确定按钮的点击事件
                self.chooseArea = area
                UserDefaults.standard.set(self.chooseArea, forKey: "chooseArea")
                UserDefaults.standard.synchronize()
                self.tableView.reloadData()
                exit(0)
                
            }
            // 设置按钮文本颜色
            okAction.setValue(UIColor.primaryColor, forKey: "titleTextColor")
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
