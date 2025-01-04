//
//  YFTranslateVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/22.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import MMBAlertsPickers
import Alamofire
import OUICore

class YFTranslateVC: BaseTitleController, QMUITextViewDelegate {

    var chooseLanguage = "英文".localized()
    var translateTo: String = "en"
    
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
        title = "翻译".localized()
        container.tg_padding = UIEdgeInsets(top: PADDING_SMALL, left: PADDING_OUTER, bottom: PADDING_SMALL, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(chooselanguageView)

        container.addSubview(titleTop)
        container.addSubview(needTransView)
        
        container.addSubview(titleBottom)
        container.addSubview(reslutView)
        
    }
    
    lazy var chooselanguageView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_gravity = .vert.center
        r.tg_space = PADDING_MEDDLE
        r.addSubview(autoLan)
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.change_icon()!, 22))
        r.addSubview(chooseLan)
        r.tg_height.equal(52)
        r.tg_width.equal(.fill)
        return r
    }()
    
    lazy var autoLan: ItemView = {
        let r = ItemView()
        r.title.text = "自动".localized()
        r.backgroundColor = UIColor(red: 0.919, green: 0.919, blue: 0.919, alpha: 1)
        r.tg_width.equal(.fill)
        r.tg_height.equal(52)
        r.corner(MEDDLE_RADIUS)
        return r
    }()
    
    
    lazy var chooseLan: ItemView = {
        let r = ItemView()
        r.title.text = "英文".localized()
        r.backgroundColor = .white
        r.tg_width.equal(.fill)
        r.tg_height.equal(52)
        r.corner(MEDDLE_RADIUS)
        r.arrowImg.show()
        let tap = UITapGestureRecognizer(target: self, action: #selector(changelanguage))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    
    lazy var titleTop: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("原文-自动检测输入的语言".localized())
        r.tg_top.equal(14)
        return r
    }()
    
    lazy var needTransView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.backgroundColor = .white
        r.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        r.corner()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.addSubview(transTextView)
        return r
    }()
    
    lazy var transTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView("输入翻译的文字".localized())
        r.delegate = self
        return r
    }()
    
    func textViewShouldReturn(_ textView: QMUITextView!) -> Bool {
        if textView.text.length > 0 {
            self.translateReceivedMessage(textView.text)
            self.view.endEditing(true)
        }
        return true
    }
    
    lazy var titleBottom: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("译文".localized())
        r.tg_top.equal(14)
        return r
    }()
    
    lazy var reslutView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.backgroundColor = .white
        r.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        r.corner()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.tg_bottom.equal(50)
        r.addSubview(reslutTextView)
        return r
    }()
    
    lazy var reslutTextView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView("")
        r.isEditable = false
        r.text = ""
        return r
    }()
    
    
    
    @objc func changelanguage() {
        
        
        let alert = UIAlertController(title: "选择语言".localized(), message: "选择目标语言".localized(), preferredStyle: .actionSheet)
        
        let frameSizes: [String] = ["英文".localized(), "汉语".localized(), "泰语".localized(), "日语".localized(), "俄语".localized(), "法语".localized(), "德语".localized(), "韩语".localized()]
        let pickerViewValues: [[String]] = [frameSizes]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.firstIndex(of: self.chooseLanguage) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue, withSerchBar: false) { [weak self] vc, picker, index, values  in
            self?.chooseLanguage = values[0][index.row]
            self?.chooseLan.title.text =  values[0][index.row]
            
            self?.changeTranslateTo(values[0][index.row])
            
        }
        
        //cacel 取消也改变值  defalut 必须选择 alert才会消失
        alert.addAction(title: "Done".localized(), style: .cancel)
        alert.show()
    }
    
    
    func changeTranslateTo(_ language: String) {
        if language == "英文".localized() {
            translateTo = "en"
        } else if language == "汉语".localized() {
            translateTo = "zh"
        } else if language == "泰语".localized() {
            translateTo = "th"
        } else if language == "日语".localized() {
            translateTo = "jp"
        } else if language == "俄语".localized() {
            translateTo = "ru"
        } else if language == "法语".localized() {
            translateTo = "fra"
        } else if language == "德语".localized() {
            translateTo = "de"
        } else if language == "韩语".localized() {
            translateTo = "kor"
        } else {
            translateTo = "en"
        }
    }
    
    // MARK: -    翻译API
    func translateReceivedMessage(_ content: String) {
        print(content)
        
        let request = TranslateRequest(q: content, from: "auto", to: translateTo, sign: nil)
        var req = try! URLRequest(url: "http://api.fanyi.baidu.com/api/trans/vip/translate?q=\(request.q)&from=\(request.from)&to=\(request.to)&appid=\(request.appid)&salt=\(request.salt)&sign=\(request.sign!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, method: .get)
        Alamofire.request(req).responseString { (response: DataResponse<String>) in
            switch response.result {
            case .success(let result):
                if let res = JsonTool.fromJson(result, toClass: ResponseTranslate<[transReslutItem]>.self) {
                    if res.trans_result?.count ??  0 >= 0 {
                        //如果scr == dst 说明from语言不是 设置的语言 不用翻译
                        print(res.trans_result![0].dst)
                        self.reslutTextView.text = res.trans_result![0].dst
                        
                    } else {
                        
                    }
                }
            case .failure(let err):
                print(err)
                break
            }
        }
    }
    
    
    
    
    class ItemView: TGLinearLayout {
        
        init() {
            super.init(frame: .zero, orientation: .horz)
            
            tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
            tg_gravity = .vert.center
            addSubview(title)
            addSubview(arrowImg)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        lazy var title: UILabel = {
            let r  = ViewFactoryUtil.customTilteLabelFill("自动", font: 16, textColor: .colorOnBackground)
            return r
        }()
        
        lazy var arrowImg: UIImageView = {
            let r = ViewFactoryUtil.defalutImgView(R.image.smallGrayBottomArrow()!, 16)
            r.hide()
            return r
        }()
        
    }
}


class TranslateRequest: Encodable {
     let q: String
     let from: String
     let to: String
     let appid: String = "20240516002053204"
     let key: String = "bM2EltHXo2Qyg3DjnryP"
     let salt: String = "1435661231458"
     let sign: String?
    
    init(q: String, from: String = "auto", to: String = "en", sign: String?) {
        self.q = q
        self.from = from
        self.to = to
        let signStr = "\(appid)\(q)\(salt)\(key)"
        self.sign = signStr.md5Str
        print(signStr, self.sign)
        
    }
}

class ResponseTranslate<T: Decodable> :Decodable {
    var trans_result: T? = nil
    var from: String?
    let to: String?
}

 
struct transReslutItem: Decodable {
    let src: String
    let dst: String
}
