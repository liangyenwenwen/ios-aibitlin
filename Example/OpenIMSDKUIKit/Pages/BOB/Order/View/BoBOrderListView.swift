//
//  BoBOrderListView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/19.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView

class BoBOrderListView: UIView {
    var tableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        tableView = UITableView(frame: frame, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BoBOrderListCell.self, forCellReuseIdentifier: "cell")
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tableView.frame = bounds
    }

}

extension BoBOrderListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BoBOrderListCell
        cell.titleLabel.text = "row:\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

extension BoBOrderListView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
