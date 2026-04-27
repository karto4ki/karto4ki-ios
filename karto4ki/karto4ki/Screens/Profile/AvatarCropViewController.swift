import UIKit

/// Обрезка под круглую маску; на выходе — квадрат, в который вписан круг (сторона = диаметру маски).
final class AvatarCropViewController: UIViewController, UIScrollViewDelegate {

    private let baseImage: UIImage
    private let onCancel: () -> Void
    private let onConfirm: (UIImage) -> Void

    private let scrollView = UIScrollView()
    private let zoomContainer = UIView()
    private let imageView = UIImageView()
    private let dimming = AvatarCropDimmingView()

    private var didLayoutContent = false

    init(image: UIImage, onCancel: @escaping () -> Void, onConfirm: @escaping (UIImage) -> Void) {
        self.baseImage = AvatarImageProcessing.normalizedUpOrientation(image)
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false

        let cancel = makeBarButton(title: "Отмена", action: #selector(cancelTapped))
        let done = makeBarButton(title: "Готово", action: #selector(doneTapped))

        let stack = UIStackView(arrangedSubviews: [cancel, UIView(), done])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(stack)

        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = baseImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = zoomContainer.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomContainer.addSubview(imageView)

        dimming.translatesAutoresizingMaskIntoConstraints = false
        dimming.isUserInteractionEnabled = false

        view.addSubview(scrollView)
        view.addSubview(dimming)
        view.addSubview(topBar)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -8),

            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dimming.topAnchor.constraint(equalTo: scrollView.topAnchor),
            dimming.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            dimming.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            dimming.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if didLayoutContent {
            refreshZoomInsets(resetOffset: false)
            updateDimmingHole()
            return
        }
        guard scrollView.bounds.width > 0, scrollView.bounds.height > 0 else { return }
        didLayoutContent = true
        layoutScrollContent()
        updateDimmingHole()
    }

    private func holeDiameter() -> CGFloat {
        min(scrollView.bounds.width, scrollView.bounds.height) - 32
    }

    private func layoutScrollContent() {
        let hole = holeDiameter()
        let img = baseImage
        let scale = max(hole / img.size.width, hole / img.size.height)
        let contentW = img.size.width * scale
        let contentH = img.size.height * scale

        zoomContainer.frame = CGRect(x: 0, y: 0, width: contentW, height: contentH)
        imageView.frame = zoomContainer.bounds
        scrollView.addSubview(zoomContainer)
        scrollView.contentSize = CGSize(width: contentW, height: contentH)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 8
        refreshZoomInsets(resetOffset: true)
    }

    private func refreshZoomInsets(resetOffset: Bool) {
        let w = zoomContainer.frame.width
        let h = zoomContainer.frame.height
        let bw = scrollView.bounds.width
        let bh = scrollView.bounds.height
        let hi = max((bw - w) * 0.5, 0)
        let vi = max((bh - h) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: vi, left: hi, bottom: vi, right: hi)
        if resetOffset {
            scrollView.contentOffset = CGPoint(x: -hi, y: -vi)
        }
    }

    private func updateDimmingHole() {
        let d = holeDiameter()
        let x = (scrollView.bounds.width - d) / 2
        let y = (scrollView.bounds.height - d) / 2
        dimming.holeFrame = CGRect(x: x, y: y, width: d, height: d)
    }

    private func makeBarButton(title: String, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc
    private func cancelTapped() {
        onCancel()
        dismiss(animated: true)
    }

    @objc
    private func doneTapped() {
        guard let cropped = renderSquareCrop() else { return }
        onConfirm(cropped)
        dismiss(animated: true)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        zoomContainer
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshZoomInsets(resetOffset: false)
    }

    private func renderSquareCrop() -> UIImage? {
        let d = holeDiameter()
        let holeInViewport = CGRect(
            x: (scrollView.bounds.width - d) * 0.5,
            y: (scrollView.bounds.height - d) * 0.5,
            width: d,
            height: d
        )
        let rectInZoom = scrollView.convert(holeInViewport, to: zoomContainer)
        let zW = zoomContainer.bounds.width
        let zH = zoomContainer.bounds.height
        guard zW > 0, zH > 0,
              let cg = baseImage.cgImage
        else { return nil }

        let pxW = CGFloat(cg.width)
        let pxH = CGFloat(cg.height)

        var cropX = rectInZoom.minX / zW * pxW
        var cropY = rectInZoom.minY / zH * pxH
        var cropW = rectInZoom.width / zW * pxW
        var cropH = rectInZoom.height / zH * pxH

        cropX = max(0, min(cropX, pxW - 1))
        cropY = max(0, min(cropY, pxH - 1))
        cropW = max(1, min(cropW, pxW - cropX))
        cropH = max(1, min(cropH, pxH - cropY))

        let integral = CGRect(x: cropX, y: cropY, width: cropW, height: cropH).integral
        let ix = Int(integral.origin.x.rounded(.down))
        let iy = Int(integral.origin.y.rounded(.down))
        let iw = Int(integral.size.width.rounded(.down))
        let ih = Int(integral.size.height.rounded(.down))
        guard ix >= 0, iy >= 0, iw > 0, ih > 0,
              ix + iw <= cg.width,
              iy + ih <= cg.height,
              let part = cg.cropping(to: CGRect(x: ix, y: iy, width: iw, height: ih))
        else { return nil }

        return UIImage(cgImage: part, scale: 1, orientation: .up)
    }
}

// MARK: - Dimming

private final class AvatarCropDimmingView: UIView {

    var holeFrame: CGRect = .zero {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        UIColor(white: 0, alpha: 0.58).setFill()
        UIRectFill(bounds)
        ctx.setBlendMode(.clear)
        UIBezierPath(ovalIn: holeFrame).fill()
    }
}
