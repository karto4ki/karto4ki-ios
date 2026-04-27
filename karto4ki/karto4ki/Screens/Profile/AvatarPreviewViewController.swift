import UIKit

/// Полноэкранный просмотр: чёрный фон, изображение `aspectFit` (целиком видно).
final class AvatarPreviewViewController: UIViewController {

    private let remoteURL: URL?
    private let localImage: UIImage?
    private let imageView = UIImageView()
    private var loadTask: URLSessionDataTask?

    init(remoteURL: URL) {
        self.remoteURL = remoteURL
        self.localImage = nil
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    init(localImage: UIImage) {
        self.remoteURL = nil
        self.localImage = localImage
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        loadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let close = UIButton(type: .system)
        close.setTitle("Закрыть", for: .normal)
        close.setTitleColor(.white, for: .normal)
        close.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(close)

        NSLayoutConstraint.activate([
            close.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),

            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let localImage {
            imageView.image = localImage
        } else if let remoteURL {
            loadTask = URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, _ in
                guard let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.imageView.image = img }
            }
            loadTask?.resume()
        }
    }

    @objc
    private func closeTapped() {
        dismiss(animated: true)
    }
}
