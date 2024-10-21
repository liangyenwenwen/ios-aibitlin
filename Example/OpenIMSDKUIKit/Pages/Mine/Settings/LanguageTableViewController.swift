
import Localize_Swift
import UIKit

class LanguageTableViewController: UITableViewController {
    private let rowItems: [[RowType]] = [RowType.allCases]
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let lan = Localize.currentLanguage()
            for (index, item) in self.rowItems[0].enumerated() {
                if item.rawValue == lan {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                }
            }
            if self.tableView.indexPathForSelectedRow == nil {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            }
        }
        
        title = "语言和地区".localized()
    }

    private func configureTableView() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.register(CheckBoxTextTableViewCell.self, forCellReuseIdentifier: CheckBoxTextTableViewCell.className)
        tableView.rowHeight = 60
        tableView.backgroundColor = .viewBackgroundColor
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        rowItems.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowItems[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType: RowType = rowItems[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckBoxTextTableViewCell.className) as! CheckBoxTextTableViewCell
        cell.titleLabel.text = rowType.title
        
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
        let rowType: RowType = rowItems[indexPath.section][indexPath.row]
        switch rowType {
        case .system:
            Localize.resetCurrentLanguageToDefault()
            break
        case .chineseSimplified:
            Localize.setCurrentLanguage(rowType.rawValue)
            
//            UserDefaults.standard.setValue("zh-Hans", forKey: "appLanguage")
//            UserDefaults.standard.setValue(["zh-Hans"], forKey: "AppleLanguages")

            
        case .english:
            Localize.setCurrentLanguage(rowType.rawValue)
            
//            UserDefaults.standard.setValue("en", forKey: "appLanguage")
//            UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")
            
        case .thai:
            Localize.setCurrentLanguage(rowType.rawValue)
            
//            UserDefaults.standard.setValue("th", forKey: "appLanguage")
//            UserDefaults.standard.setValue(["th"], forKey: "AppleLanguages")
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CheckBoxTextTableViewCell
        cell?.titleLabel.text = RowType.system.title
        
        title = "语言和地区".localized()
    }

    enum RowType: String, CaseIterable {
        case system
        case chineseSimplified = "zh-Hans"
        case english = "en"
        case thai = "th"

        var title: String {
            switch self {
            case .system:
                return "跟随系统".localized()
            case .chineseSimplified:
                return "简体中文"
            case .english:
                return "English"
            case .thai:
                return "ภาษาไทย"
            }
        }
        
        
    }
}
