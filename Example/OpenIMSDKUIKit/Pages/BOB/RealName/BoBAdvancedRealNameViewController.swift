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
class BoBAdvancedRealNameViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
    }
    var captureSession: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var currentVideoDevice: AVCaptureDevice?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var outputFileURL: URL?

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
        bottomRecordView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(162)
        }
        bottomView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(110)
        }
        
    }
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
            self?.bottomRecordView.show()
            self?.bottomView.hide()
            self?.startBtn.isSelected = true
            self?.startRecording()
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
            
        }).disposed(by: rx.disposeBag)
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
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
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
        let tempDir = NSTemporaryDirectory()
        let outputPath = (tempDir as NSString).appendingPathComponent("output.mov")
        outputFileURL = URL(fileURLWithPath: outputPath)

        movieOutput.startRecording(to: outputFileURL!, recordingDelegate: self)

//        // 5秒后自动停止录制
//        DispatchQueue.main.asyncAfter(deadline:.now() + 5) {
//            self.stopRecording()
//        }
    }

    @objc func stopRecording() {
        movieOutput.stopRecording()
        if let fileURL = outputFileURL {
            // 开始循环播放录制的视频
            playRecordedVideo(fileURL: fileURL)
        }
        bottomRecordView.hide()
        bottomView.show()
    }

    func playRecordedVideo(fileURL: URL) {
        player = AVPlayer(url: fileURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer!)

        // 添加循环播放逻辑
//        NotificationCenter.default.addObserver(self, selector: #selector(restartVideo), selector: NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        player?.play()
    }

//    @objc func restartVideo() {
//        player?.seek(to: CMTime.zero)
//        player?.play()
//    }

    func capture(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("录制视频出错: \(error)")
        } else {
            print("视频录制成功，文件位于: \(outputFileURL)")
        }
    }
    // 翻转摄像头的方法
        func toggleCamera() {
            guard let currentDevice = currentVideoDevice else {
                return
            }
            let newPosition: AVCaptureDevice.Position = currentDevice.position == .front ? .back : .front

//            guard let newDevice = AVCaptureDevice.default(.video, for: AVMediaType.video, position: newPosition) else {
//                return
//            }
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video,position:newPosition) else {
                return
            }

            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
                captureSession.beginConfiguration()
                captureSession.removeInput((captureSession.inputs.first as? AVCaptureDeviceInput)!)
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
