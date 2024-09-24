
import OUICore
import MJRefresh

public class OthersViewController: UIViewController {
    
    private var viewModel: MomentsViewModel!
    private var user: User!
    
    private lazy var header = MomentHeaderCell()
    
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.register(OthersCell.self, forCellReuseIdentifier: OthersCell.className)
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 60
        v.backgroundColor = .clear
        v.delegate = self
        v.dataSource = self
        v.separatorStyle = .none
                
        return v
    }()
    
    private lazy var backButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(nameInBundle: "common_back_icon") ?? UIImage(systemName: "chevron.backward"), for: .normal)
        v.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        v.tintColor = .white
        
        return v
    }()
    
    @objc
    private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    public init(userID: String, nickname: String, faceURL: String?) {
        super.init(nibName: nil, bundle: nil)
        self.user = User(userID: userID, nickname: nickname, faceURL: faceURL)
        viewModel = MomentsViewModel(userID: user.userID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        setupSubviews()
        bindData()
        viewModel.loadMoments(split: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupSubviews() {
        
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.height.equalTo(222.h)
            make.leading.top.trailing.equalToSuperview()
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addRefreshing()
    }
    
    private func bindData() {
        
        header.avatarImageView.setAvatar(url: user.faceURL, text: user.nickname)
        header.userNameLabel.text = user.nickname
        
        viewModel.splitByYearMomentsRelay.subscribe { [weak self] (ms: [[MomentsInfo]]) in
            guard let self else { return }
            // Pull down to refresh
            if self.viewModel.pageNumber == 1 {
                self.tableView.mj_header?.endRefreshing()

                if ms.isEmpty || ms.count < self.viewModel.pageCount {
                    if self.user.userID == nil {
                        if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                            footer.setTitle("还没有动态，发布一条吧".innerLocalized(), for: .noMoreData)
                            footer.endRefreshingWithNoMoreData()
                        }
                    } else {
                        if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                            footer.setTitle("没有更多动态了".innerLocalized(), for: .noMoreData)
                            footer.endRefreshingWithNoMoreData()
                        }
                    }
                }
                
                self.tableView.reloadData()
                self.tableView.mj_footer?.resetNoMoreData()
            } else {
                // pull up load
                if ms.isEmpty || ms.count < self.viewModel.pageCount {
                    // Brand new without data, when there is data, the text of the footer needs to be corrected
                    if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                        footer.setTitle("没有更多动态了".innerLocalized(), for: .noMoreData)
                        footer.endRefreshingWithNoMoreData()
                    }
                } else {
                    self.tableView.reloadData()
                    self.tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    private func addRefreshing() {
        
        tableView.mj_header = MomentRefreshHeader(refreshingBlock: {[weak self] in
            self?.viewModel.loadMoments(split: true)
        })

        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.viewModel.loadMoments(loadMore: true, split: true)
        })
        footer.isAutomaticallyRefresh = false
        tableView.mj_footer = footer
    }
}

extension OthersViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in _: UITableView) -> Int {
        let count = viewModel.splitByYearMomentsRelay.value.count
        
        return count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.splitByYearMomentsRelay.value[section].count
        
        return count
    }

    private func areDatesEqual(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current

        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)

        return components1.year == components2.year &&
                   components1.month == components2.month &&
                   components1.day == components2.day
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OthersCell.className, for: indexPath) as! OthersCell
        let lastMoment = viewModel.splitByYearMomentsRelay.value[indexPath.section][indexPath.row - 1 < 0 ? 0 : indexPath.row - 1]
        let moment = viewModel.splitByYearMomentsRelay.value[indexPath.section][indexPath.row]
        let lastDate = Date(timeIntervalSince1970: TimeInterval(lastMoment.createTime / 1000))
        let date = Date(timeIntervalSince1970: TimeInterval(moment.createTime / 1000))
        
        let sameDate = indexPath.row == 0 ? false : areDatesEqual(lastDate, date)
        
        if sameDate {
            cell.dayLabel.textColor = .clear
            cell.monthLabel.textColor = .clear
        }
        
        if date.isToday() {
            cell.dayLabel.text = "今天".innerLocalized()
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Calendar.current.locale
            dateFormatter.setLocalizedDateFormatFromTemplate("MM")
            let month = dateFormatter.string(from: date)
            
            dateFormatter.setLocalizedDateFormatFromTemplate("dd")
            let day = dateFormatter.string(from: date)
            
            cell.monthLabel.text = month
            cell.dayLabel.text = day
        }
        
        if let metas = moment.content?.metas, !metas.isEmpty {
            cell.previewImageView.isHidden = false
            cell.previewImageView.setImage(with: metas.first?.thumb)
            cell.mediaCountLabel.text = metas.count > 1 ? ("\(metas.count)" + "张".innerLocalized()) : nil
            cell.playButton.isHidden = moment.content?.type != 1
        }
        
        cell.wordLabel.text = moment.content?.text
        
        return cell
    }

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let line1 = UIView()
        line1.backgroundColor = .sepratorColor
    
        let line2 = UIView()
        line2.backgroundColor = .sepratorColor
        
        let yearLabel = UILabel()
        yearLabel.textColor = .systemGray4
        yearLabel.font = .f12
        
        let moment = viewModel.splitByYearMomentsRelay.value[section][0]
        let date = Date(timeIntervalSince1970: TimeInterval(moment.createTime / 1000))
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let year = dateFormatter.string(from: date)
        
        yearLabel.text = year
        
        let hStack = UIStackView(arrangedSubviews: [line1, yearLabel, line2])
        hStack.spacing = 16
        hStack.alignment = .center
        hStack.backgroundColor = .cellBackgroundColor
        
        return hStack
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        32
    }

    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let moment = viewModel.splitByYearMomentsRelay.value[indexPath.section][indexPath.row]
        
        let vc = MomentsViewController(momentID: moment.workMomentID, moments: moment)
        navigationController?.pushViewController(vc, animated: true)
    }
}
