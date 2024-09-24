
import Foundation
import UIKit

class CircleProgressView: UIView {
    // 进度值
    public var progress: CGFloat = 0 {
        didSet {
            print("\(CircleProgressView.self): progress - \(progress)")
//            valueLabel.text = "\(progress * 100)%"
            setNeedsDisplay()
        }
    }

    //进度条颜色
    public var progerssColor: UIColor = .systemBlue
    //进度条背景颜色
    public var progerssBackgroundColor: UIColor = .white
    //进度条的宽度
    public var progerWidth: CGFloat = 3
    //进度数据字体大小
    public var percentageFontSize: CGFloat = 10
    //进度数字颜色
    public var percentFontColor: UIColor = .white

    lazy var valueLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: percentageFontSize)
        v.textColor = percentFontColor
        v.textAlignment = .center
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubviews() {
        backgroundColor = .clear
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        
        //路径
        var backgroundPath = UIBezierPath()
        //线宽
        backgroundPath.lineWidth = progerWidth
        //颜色
        progerssBackgroundColor.set()
        //拐角
        backgroundPath.lineCapStyle = .round
        backgroundPath.lineJoinStyle = .round
        //半径
        var radius = (min(rect.size.width, rect.size.height) - progerWidth) * 0.5;
        //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
        backgroundPath.addArc(withCenter: CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: M_PI * 1.5, endAngle: M_PI * 1.5 + M_PI * 2, clockwise: true)
        //连线
        backgroundPath.stroke()
        
        //路径
        var progressPath = UIBezierPath()
        //线宽
        progressPath.lineWidth = progerWidth
        //颜色
        progerssColor.set()
        //拐角
        progressPath.lineCapStyle = .round
        progressPath.lineJoinStyle = .round
        
        //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
        progressPath.addArc(withCenter: CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: M_PI * 1.5, endAngle: M_PI * 1.5 + M_PI * 2 * progress, clockwise: true)
        //连线
        progressPath.stroke()
    }
}
