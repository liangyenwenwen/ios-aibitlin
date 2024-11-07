
import OUICore
import MJRefresh
import OUICoreView
import OpenIMSDK
import ProgressHUD
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
    
    lazy var publishBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_publish_icon"), for: .normal)
        v.addTarget(self, action: #selector(sendMoments(_:)), for: .touchUpInside)
        v.tag = 200
        return v
    }()
    
    lazy var newMsgBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_new_msg_icon"), for: .normal)
        v.addTarget(self, action: #selector(newMessageAction), for: .touchUpInside)
        v.tag = 300
        return v
    }()
    
    private lazy var menuItems: [PopoverTableViewController.MenuItem] = {
        let graphicsItem = PopoverTableViewController.MenuItem(title: "发布图文".innerLocalized(), icon: UIImage(nameInBundle: "moments_publish_graphics_icon")) { [weak self] in
            let vc = PublishViewController {
                self?.tableView.mj_header?.beginRefreshing()
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let videoItem = PopoverTableViewController.MenuItem(title: "发布视频".innerLocalized(), icon: UIImage(nameInBundle: "moments_publish_video_icon")) { [weak self] in
            let vc = PublishViewController(forVideo: true) {
                self?.tableView.mj_header?.beginRefreshing()
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return [graphicsItem, videoItem]
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
        ProgressHUD.dismiss()
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
        
        
        if self.user.userID == Open_im_sdkGetLoginUserID() {
            view.addSubview(publishBtn)
            view.addSubview(newMsgBtn)
            
            newMsgBtn.snp.makeConstraints { make in
                make.trailing.equalTo(publishBtn.snp.leading).offset(-16)
                make.centerY.equalTo(backButton)
                make.size.equalTo(40)
            }
            
            publishBtn.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(20)
                make.centerY.equalTo(backButton)
                make.size.equalTo(40)
            }
            
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
                if ms.isEmpty{
                    if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                        footer.setTitle(self.user.userID == IMController.shared.uid ? "还没有动态，发布一条吧".innerLocalized():"好友还没有发动态".innerLocalized(), for: .noMoreData)
                        footer.endRefreshingWithNoMoreData()
                    }
                }else{
                    if ms.count < self.viewModel.pageCount{
                        if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                            footer.setTitle("已经全部加载完毕".innerLocalized(), for: .noMoreData)
                            footer.endRefreshingWithNoMoreData()
                        }
                    }
                }
                self.tableView.reloadData()
//                self.tableView.mj_footer?.resetNoMoreData()
            } else {
                // pull up load
                if ms.isEmpty || ms.count < self.viewModel.pageCount {
                    // Brand new without data, when there is data, the text of the footer needs to be corrected
                    if var footer = self.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                        footer.setTitle("已经全部加载完毕".innerLocalized(), for: .noMoreData)
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
        footer.setTitle("点击或上拉加载更多".innerLocalized(), for: .idle)
        footer.setTitle("正在加载更多的数据...".innerLocalized(), for: .refreshing)
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

extension OthersViewController {
    
    @objc func sendMoments(_ btn: UIButton) {
        let popover = PopoverTableViewController(items: menuItems)
        popover.topInset = 0
        popover.show(in: self, sender: btn, permittedArrowDirections: [], sourceViewReviseOffset: 10)
    }
    
    
    @objc func newMessageAction() {

        let vc = NewMessageViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
