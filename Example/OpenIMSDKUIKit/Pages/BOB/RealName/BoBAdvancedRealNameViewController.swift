//
//  BoBAdvancedRealNameViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/1/8.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
import AVFoundation
import OUICore
import ProgressHUD
import ZLPhotoBrowser

class BoBAdvancedRealNameViewController: UIViewController {
    var name:String = ""
    var cardId:String = ""
    var idCardZM:String = ""
    var idCardBM:String = ""
    var captureSession: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var currentVideoDevice: AVCaptureDevice?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var outputFileURL: URL?
    var videoUrl:String = ""
    private var timer: DispatchSourceTimer?
    var timeCount:Int = 0
    private var videoInput: AVCaptureDeviceInput?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // 请求摄像头和麦克风使用权限
        requestPermissions()

        // 设置视频捕获会话
        setupCaptureSession()

        // 设置视频输出
        setupMovieOutput()
        view.addSubview(bottomRecordView)
        view.addSubview(bottomView)
        view.addSubview(backImg)
        view.addSubview(tipLabel)
        view.addSubview(timeLabel)
        bottomRecordView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(162)
        }
        bottomView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(110)
        }
        backImg.snp_makeConstraints { make in
            make.top.equalTo(kStatusBarHeight+12)
            make.left.equalTo(18)
            make.width.height.equalTo(20)
        }
        tipLabel.snp_makeConstraints { make in
            make.top.equalTo(kStatusBarHeight+44+6)
            make.centerX.equalTo(view)
            make.height.equalTo(30)
            make.width.equalTo(166)
        }
        timeLabel.snp_makeConstraints { make in
            make.top.centerX.bottom.equalTo(tipLabel)
            make.width.equalTo(87)
        }
    }
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    func uploadVideo(){
        if videoUrl.length == 0{
            ProgressHUD.animate()
            PhotoHelper.getVideoAt(url: outputFileURL!) { main, thumb, duration in
                IMController.shared.uploadFile(fullPath: main.fullPath) { progress in
                    
                } onSuccess: { [weak self] url in
                    if let url = url {
                        self?.videoUrl = url
                        self?.commitInfo()
                    }else{
                        ProgressHUD.dismiss()
                        SuperToast.show(title: "上传失败")
                    }
                }
            }
        }else{
            commitInfo()
        }
        
    }
    func commitInfo(){
        BoBRealNameModel.AdvancedRealNameAuthenticationRequest(videoUrl: videoUrl, name: name, cardId: cardId, idCardZM: idCardBM, idCardBM:idCardBM){errCode,errMsg in
            if errCode == 620000{
                SuperToast.show(title: "提交成功")
                if (self.navigationController?.viewControllers.count)! > 3{
                    let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-4]
                    self.navigationController?.popToViewController(vc!, animated: true)
                }else{
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    func convertSecondsToMinuteSecondFormat(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "00:%02d:%02d", minutes, remainingSeconds)
    }
    func startTimer() {
        // 创建一个基于全局并发队列的定时器源
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        // 设置定时器触发间隔为1秒
        timer?.schedule(deadline:.now(), repeating:.seconds(1))
        // 设置定时器触发时执行的闭包
        timer?.setEventHandler {[weak self] in
            if self?.timeCount == 10{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.stopRecording()
                }
            }else{
                DispatchQueue.main.async {
                    self?.timeCount = (self?.timeCount ?? 0)+1
                    self?.timeLabel.text = self?.convertSecondsToMinuteSecondFormat(self?.timeCount ?? 0)
                }
            }
        }
        // 启动定时器
        timer?.resume()
    }
    func stopTimer() {
        if timer != nil{
            timer?.cancel()
            timer = nil
        }
    }
    lazy var backImg: UIImageView = {
        let r = UIImageView()
        r.image = UIImage(named: "common_back_icon")!.changeImageColor(color: .white)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        r.addGestureRecognizer(tap)
        r.layer.zPosition = 101
        return r
    }()
    lazy var bottomRecordView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "real_name_record_video_bg_icon"))
        r.isUserInteractionEnabled = true
        r.addSubview(startBtn)
        r.addSubview(flipBtn)
        
        startBtn.snp_makeConstraints { make in
            make.top.equalTo(40)
            make.width.height.equalTo(76)
            make.centerX.equalTo(r)
        }
        flipBtn.snp_makeConstraints { make in
            make.centerY.equalTo(startBtn)
            make.right.equalTo(-20)
            make.width.height.equalTo(50)
        }
       
        return r
    }()
    lazy var startBtn: QMUIButton = {
        let r = QMUIButton()
        r.setImage(UIImage(named: "real_name_record_video_start_icon"), for: .normal)
        r.setImage(UIImage(named: "real_name_record_video_stop_icon"), for: .selected)
        r.rx.tap.subscribe(onNext: { [weak self] in
            r.isSelected = !r.isSelected
            if r.isSelected{
                self?.startRecording()
            }else{
                self?.stopRecording()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var flipBtn: QMUIButton = {
        let r = QMUIButton()
        r.setImage(UIImage(named: "real_name_record_video_flip_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.toggleCamera()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var bottomView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "real_name_record_video_bottom_bg_icon"))
        r.layer.zPosition = 100
        r.isUserInteractionEnabled = true
        r.hide()
        r.addSubview(retakeBtn)
        r.addSubview(commitBtn)
        retakeBtn.snp_makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(16)
            make.height.equalTo(46)
            make.width.equalTo((kScreenWidth-32-18)/2)
        }
        commitBtn.snp_makeConstraints { make in
            make.top.width.height.equalTo(retakeBtn)
            make.right.equalTo(-16)
        }
        return r
    }()
    lazy var retakeBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("重拍")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.white,borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.player != nil {
                self?.player?.pause()
                self?.playerLayer?.removeFromSuperlayer()
                self?.player = nil
                self?.playerLayer = nil
            }
            self?.videoUrl = ""
            self?.bottomRecordView.show()
            self?.bottomView.hide()
            self?.tipLabel.show()
            self?.startBtn.isSelected = false
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var commitBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("提交审核")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.uploadVideo()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#FF0000")
        r.backgroundColor = .white
        r.corner(4)
        r.textAlignment = .center
        r.font = .regularFont(16)
        r.text = "请录制5~10秒的视频"
        return r
    }()
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .white
        r.backgroundColor = .init(hexString: "#FF0000")
        r.corner(4)
        r.textAlignment = .center
        r.font = .regularFont(16)
        r.text = "00:00:00"
        r.hide()
        return r
    }()
    func requestPermissions() {
        AVCaptureDevice.requestAccess(for:.video) { granted in
            if granted {
                // 权限已授予，可继续操作
            } else {
                print("未授予摄像头权限，无法录制视频")
            }
        }

        AVCaptureDevice.requestAccess(for:.audio) { granted in
            if granted {
                // 权限已授予，可继续操作
            } else {
                print("未授予麦克风权限，无法录制带声音的视频")
            }
        }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()

        // 获取默认的视频输入设备（先获取前置摄像头作为初始设备）
        currentVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video,position:.front)

        guard let videoDevice = currentVideoDevice else {
            return
        }

        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput!) {
                captureSession.addInput(videoInput!)
            }
        } catch {
            print("添加视频输入出错: \(error)")
        }

        // 添加音频输入（若需要录制有声音的视频）
        guard let audioDevice = AVCaptureDevice.default(for:.audio) else {
            return
        }
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        } catch {
            print("添加音频输入出错: \(error)")
        }

        // 创建预览层，用于显示正在录制的画面（可根据需求选择是否展示）
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func setupMovieOutput() {
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
    }

    @objc func startRecording() {
        if player != nil {
            player?.pause()
            playerLayer?.removeFromSuperlayer()
            player = nil
            playerLayer = nil
        }
        flipBtn.hide()
        tipLabel.hide()
        timeLabel.show()
//        let connection = movieOutput.connection(with: .video)
//        connection?.videoScaleAndCropFactor = 1
//        if connection?.isVideoOrientationSupported == true {
//                let currentDeviceOrientation = UIDevice.current.orientation
//                var videoOrientation: AVCaptureVideoOrientation
//                switch currentDeviceOrientation {
//                case.landscapeLeft:
//                    videoOrientation = .landscapeRight
//                case.landscapeRight:
//                    videoOrientation = .landscapeLeft
//                case.portrait:
//                    videoOrientation = .portrait
//                case.portraitUpsideDown:
//                    videoOrientation = .portraitUpsideDown
//                default:
//                    videoOrientation = .portrait
//                }
//                connection?.videoOrientation = videoOrientation
//            if let previewConnection = previewLayer.connection {
//                if previewConnection.isVideoOrientationSupported {
//                    previewConnection.videoOrientation = videoOrientation
//                }
//            }
//            }
//        // 解决前置摄像头录制视频时候左右颠倒的问题
//        if videoInput?.device.position == .front {
//            // 镜像设置
//            if connection?.isVideoMirroringSupported == true {
//                connection?.isVideoMirrored = true
//            }
//        }
        let tempDir = NSTemporaryDirectory()
        let videoName = UUID().uuidString + ".mov"
        let outputPath = (tempDir as NSString).appendingPathComponent(videoName)
        outputFileURL = URL(fileURLWithPath: outputPath)
        movieOutput.startRecording(to: outputFileURL!, recordingDelegate: self)
        timeCount = 0
        startTimer()
    }

    @objc func stopRecording() {
        movieOutput.stopRecording()
        stopTimer()
        flipBtn.show()
        timeLabel.hide()
        if timeCount < 5{
            bottomRecordView.show()
            bottomView.hide()
            tipLabel.show()
            startBtn.isSelected = false
        }else{
            bottomRecordView.hide()
            bottomView.show()
        }
    }

    func playRecordedVideo(fileURL: URL) {
        player = AVPlayer(url: fileURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer!)

        // 添加循环播放逻辑
        NotificationCenter.default.addObserver(self, selector: #selector(restartVideo), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player?.play()
    }
    @objc func restartVideo() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    // 翻转摄像头的方法
        func toggleCamera() {
            guard let currentDevice = currentVideoDevice else {
                return
            }
            let newPosition: AVCaptureDevice.Position = currentDevice.position == .front ? .back : .front
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video,position:newPosition) else {
                return
            }

            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
                captureSession.beginConfiguration()
                if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                    captureSession.removeInput(currentInput)
                }
                if captureSession.canAddInput(newVideoInput) {
                    captureSession.addInput(newVideoInput)
                    currentVideoDevice = newDevice
                }
                
                captureSession.commitConfiguration()
            } catch {
                print("切换摄像头出错: \(error)")
            }
        }
}
extension BoBAdvancedRealNameViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("录制视频出错: \(error)")
        } else {
            print("视频录制成功，文件位于: \(outputFileURL)")
            // 开始循环播放录制的视频
            if timeCount >= 5{
                playRecordedVideo(fileURL: outputFileURL)
            }else{
                SuperToast.show(title: "录制时间不能少于5s")
            }
        }
    }
}
