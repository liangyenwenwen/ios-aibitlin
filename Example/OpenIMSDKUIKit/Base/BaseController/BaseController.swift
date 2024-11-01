//
//  BaseController.swift
//  所有控制器父类
//
//  Created by mac on 2024/4/24.
//

import UIKit
import ProgressHUD

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initViews()
        initDatum()
        initListeners()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    /// 控件
    func initViews()  {
        
    }
    
    /// 设置数据
    func initDatum()  {
        
    }
    
    /// 设置监听器
    func initListeners()  {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
