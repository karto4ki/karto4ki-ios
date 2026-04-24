import UIKit

final class SemicircleGaugeView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressGradientLayer = CAGradientLayer()
    private let progressMaskLayer = CAShapeLayer()
    private let percentLabel = UILabel()

    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()

        percentLabel.center = CGPoint(x: bounds.midX, y: bounds.height * 0.62)
    }

    func setProgress(_ value: Int) {
        progress = CGFloat(value) / 100.0
        percentLabel.text = "\(value)%"
        updatePaths()
    }

    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressGradientLayer.colors = [
            UIColor(red: 0.45, green: 0.50, blue: 0.95, alpha: 1).cgColor,
            UIColor(red: 0.95, green: 0.35, blue: 0.55, alpha: 1).cgColor
        ]
        progressGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressGradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        progressGradientLayer.mask = progressMaskLayer

        progressMaskLayer.fillColor   = UIColor.clear.cgColor
        progressMaskLayer.strokeColor = UIColor.black.cgColor
        progressMaskLayer.lineCap     = .round

        layer.addSublayer(progressGradientLayer)
    }

    private func setupLabel() {
        percentLabel.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        percentLabel.textColor = UIColor(red: 0.35, green: 0.35, blue: 0.75, alpha: 1)
        percentLabel.textAlignment = .center
        percentLabel.sizeToFit()
        addSubview(percentLabel)
    }

    private func updatePaths() {
        guard bounds.width > 0 else { return }

        let lineWidth: CGFloat = 14
        let radius = (min(bounds.width, bounds.height * 2) / 2) - lineWidth
        let center = CGPoint(x: bounds.midX, y: bounds.height - lineWidth / 2)

        // Full arc: from π (left) going clockwise through top (3π/2) to 2π (right)
        let startAngle: CGFloat = .pi
        let fullEndAngle: CGFloat = 2 * .pi

        trackLayer.lineWidth = lineWidth
        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: fullEndAngle,
            clockwise: true
        )
        trackLayer.path = trackPath.cgPath

        let progressEndAngle = startAngle + progress * .pi
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: progressEndAngle,
            clockwise: true
        )
        progressMaskLayer.lineWidth = lineWidth
        progressMaskLayer.path = progressPath.cgPath

        progressGradientLayer.frame = bounds
        progressMaskLayer.frame = bounds

        percentLabel.sizeToFit()
        percentLabel.center = CGPoint(x: bounds.midX, y: bounds.height * 0.62)
    }
}
