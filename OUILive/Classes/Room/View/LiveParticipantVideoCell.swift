
import OUICalling

class LiveParticipantDefaultView: ParticipantCellDefaultView {
}

class LiveParticipantVideoCell: ParticipantCell {
        
    public lazy var toggleCameraButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "trun_camera_flag"), for: .normal)
        v.addTarget(self, action: #selector(toggleCameraButtonAction), for: .touchUpInside)
        
        return v
    }()
    
    @objc func toggleCameraButtonAction() {
        onTap?(.camera)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        videoView.layoutMode = .fit
        
        addSubview(toggleCameraButton)
        toggleCameraButton.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(24)
        }
    }
    
    override func changeInfoByVideoEnable(enable: Bool) {
        super.changeInfoByVideoEnable(enable: enable)
        toggleCameraButton.isHidden = !enable
    }
}
