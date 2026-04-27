import UIKit
import PhotosUI

final class ProfileScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    private let interactor: ProfileScreenBusinessLogic

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let blockSpacing: CGFloat = 12

    private let titleLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private var glassCardsForLoading: [UIView] = []

    // MARK: — Header card
    private let profileHeaderCard = UIView()
    private let avatarWrap = UIView()
    private let avatarImageView = UIImageView()
    private let initialsLabel = UILabel()
    private let editAvatarButton = UIButton(type: .system)
    private let nameValueLabel = UILabel()
    private let usernameValueLabel = UILabel()

    // MARK: — Email card
    private let emailCard = UIView()
    private let emailTitleLabel = UILabel()
    private let emailValueLabel = UILabel()

    // MARK: — Notifications card
    private let notificationsCard = UIView()
    private let notificationsTitleLabel = UILabel()
    private let notificationsSubtitleLabel = UILabel()
    private let notificationSwitch = UISwitch()

    // MARK: — Logout card
    private let logoutCard = UIView()
    private let logoutTitleLabel = UILabel()
    private let logoutSubtitleLabel = UILabel()

    private var photoLoadTask: URLSessionDataTask?
    private var currentPhotoURL: URL?

    private let profilePurple = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let glassCorner: CGFloat = 22
    private let iconBoxSize: CGFloat = 48
    private let iconBoxCorner: CGFloat = 14

    // MARK: - Init

    init(interactor: ProfileScreenBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureUI()
        interactor.loadProfile()
    }

    deinit {
        photoLoadTask?.cancel()
    }

    // MARK: - UI

    private func configureUI() {
        configureBackground()
        configureScrollView()
        configureTitle()
        configureProfileHeaderCard()
        configureEmailCard()
        configureNotificationsCard()
        configureLogoutCard()
        configureLoadingIndicator()
        glassCardsForLoading = [profileHeaderCard, emailCard, notificationsCard, logoutCard]
    }

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    private func configureScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -76)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = blockSpacing
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func configureTitle() {
        titleLabel.text = "Профиль"
        titleLabel.font = Fonts.futuraB22
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left

        let titleRow = UIView()
        titleRow.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleRow.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: titleRow.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleRow.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleRow.bottomAnchor)
        ])
        contentStack.addArrangedSubview(titleRow)
        contentStack.setCustomSpacing(16, after: titleRow)
    }

    private func configureProfileHeaderCard() {
        styleCloudCardLikeMain(profileHeaderCard)
        contentStack.addArrangedSubview(profileHeaderCard)

        let avatarSize: CGFloat = 96
        avatarWrap.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.clipsToBounds = false

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarSize / 2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        avatarImageView.backgroundColor = .white.withAlphaComponent(0.18)

        initialsLabel.font = UIFont.systemFont(ofSize: 32, weight: .black)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.addSubview(avatarImageView)
        avatarWrap.addSubview(initialsLabel)
        avatarImageView.pin(to: avatarWrap)
        NSLayoutConstraint.activate([
            avatarWrap.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarWrap.heightAnchor.constraint(equalToConstant: avatarSize),
            initialsLabel.centerXAnchor.constraint(equalTo: avatarWrap.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarWrap.centerYAnchor)
        ])

        editAvatarButton.backgroundColor = profilePurple
        editAvatarButton.tintColor = .white
        let pen = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        editAvatarButton.setImage(UIImage(systemName: "pencil", withConfiguration: pen), for: .normal)
        editAvatarButton.layer.cornerRadius = 18
        editAvatarButton.clipsToBounds = true
        editAvatarButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.addSubview(editAvatarButton)

        avatarWrap.isUserInteractionEnabled = true
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarAreaTapped))
        avatarTap.cancelsTouchesInView = false
        avatarTap.delegate = self
        avatarWrap.addGestureRecognizer(avatarTap)
        NSLayoutConstraint.activate([
            editAvatarButton.widthAnchor.constraint(equalToConstant: 36),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 36),
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarWrap.trailingAnchor, constant: 4),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarWrap.bottomAnchor, constant: 4)
        ])

        nameValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameValueLabel.textColor = .white
        nameValueLabel.numberOfLines = 2

        usernameValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        usernameValueLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        usernameValueLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [nameValueLabel, usernameValueLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        let row = UIStackView(arrangedSubviews: [avatarWrap, textStack])
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center

        let contentHost = UIView()
        profileHeaderCard.addSubview(contentHost)
        contentHost.translatesAutoresizingMaskIntoConstraints = false
        contentHost.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentHost.topAnchor.constraint(equalTo: profileHeaderCard.topAnchor, constant: 18),
            contentHost.leadingAnchor.constraint(equalTo: profileHeaderCard.leadingAnchor, constant: 16),
            contentHost.trailingAnchor.constraint(equalTo: profileHeaderCard.trailingAnchor, constant: -16),
            contentHost.bottomAnchor.constraint(equalTo: profileHeaderCard.bottomAnchor, constant: -18),
            row.topAnchor.constraint(equalTo: contentHost.topAnchor),
            row.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: contentHost.bottomAnchor)
        ])
    }

    private func configureEmailCard() {
        styleCloudCardLikeMain(emailCard)
        contentStack.addArrangedSubview(emailCard)

        let icon = iconBadge(symbol: "envelope.fill", background: profilePurple)
        emailTitleLabel.text = "Почта"
        emailTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        emailTitleLabel.textColor = .white
        emailValueLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emailValueLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        emailValueLabel.numberOfLines = 2

        let textCol = UIStackView(arrangedSubviews: [emailTitleLabel, emailValueLabel])
        textCol.axis = .vertical
        textCol.spacing = 4
        textCol.alignment = .leading

        let row = UIStackView(arrangedSubviews: [icon, textCol])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center

        embedCardContent(row, in: emailCard, inset: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }

    private func configureNotificationsCard() {
        styleCloudCardLikeMain(notificationsCard)
        contentStack.addArrangedSubview(notificationsCard)

        let icon = iconBadge(symbol: "bell.fill", background: profilePurple)
        notificationsTitleLabel.text = "Уведомления"
        notificationsTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        notificationsTitleLabel.textColor = .white

        notificationsSubtitleLabel.text = "Получать напоминания об обучении и стриках"
        notificationsSubtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        notificationsSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        notificationsSubtitleLabel.numberOfLines = 0

        notificationSwitch.onTintColor = profilePurple
        wireNotificationSwitchTarget()

        let textCol = UIStackView(arrangedSubviews: [notificationsTitleLabel, notificationsSubtitleLabel])
        textCol.axis = .vertical
        textCol.spacing = 6
        textCol.alignment = .leading

        let mid = UIStackView(arrangedSubviews: [icon, textCol])
        mid.axis = .horizontal
        mid.spacing = 14
        mid.alignment = .top

        let row = UIStackView(arrangedSubviews: [mid, notificationSwitch])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.distribution = .fill
        textCol.setContentHuggingPriority(.defaultLow, for: .horizontal)

        embedCardContent(row, in: notificationsCard, inset: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 14))
    }

    private func configureLogoutCard() {
        styleLogoutCloudCardLikeMain(logoutCard)
        contentStack.addArrangedSubview(logoutCard)

        let icon = iconBadge(
            symbol: "rectangle.portrait.and.arrow.right",
            background: UIColor(red: 0.95, green: 0.35, blue: 0.42, alpha: 1),
            iconTint: .white
        )

        logoutTitleLabel.text = "Выйти из аккаунта"
        logoutTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        logoutTitleLabel.textColor = UIColor(red: 0.95, green: 0.25, blue: 0.32, alpha: 1)

        logoutSubtitleLabel.text = "Разлогиниться и выйти из профиля"
        logoutSubtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        logoutSubtitleLabel.textColor = UIColor(red: 0.92, green: 0.38, blue: 0.44, alpha: 0.95)
        logoutSubtitleLabel.numberOfLines = 0

        let textCol = UIStackView(arrangedSubviews: [logoutTitleLabel, logoutSubtitleLabel])
        textCol.axis = .vertical
        textCol.spacing = 4
        textCol.alignment = .leading

        let row = UIStackView(arrangedSubviews: [icon, textCol])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center

        embedCardContent(row, in: logoutCard, inset: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let tap = UITapGestureRecognizer(target: self, action: #selector(signOutTapped))
        logoutCard.addGestureRecognizer(tap)
        logoutCard.isUserInteractionEnabled = true
    }

    private func configureLoadingIndicator() {
        scrollView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }

    // MARK: - Карточки как на главном (`MainScreenViewController.styleCard`)

    private func styleCloudCardLikeMain(_ card: UIView) {
        card.backgroundColor = .white.withAlphaComponent(0.28)
        card.layer.cornerRadius = glassCorner
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }

    /// Та же заливка 0.28, что у белых «облаков» на главной; красная обводка для выхода.
    private func styleLogoutCloudCardLikeMain(_ card: UIView) {
        card.backgroundColor = .white.withAlphaComponent(0.28)
        card.layer.cornerRadius = glassCorner
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.92, green: 0.38, blue: 0.44, alpha: 0.85).cgColor
    }

    /// Вставляет контент в карточку (вызвать после `styleCloudCardLikeMain`, пока в `card` нет сабвью).
    private func embedCardContent(_ content: UIView, in container: UIView, inset: UIEdgeInsets) {
        container.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: inset.top),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset.left),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset.right),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset.bottom)
        ])
        container.bringSubviewToFront(content)
    }

    private func iconBadge(symbol: String, background: UIColor, iconTint: UIColor = .white) -> UIView {
        let box = UIView()
        box.backgroundColor = background
        box.layer.cornerRadius = iconBoxCorner
        box.translatesAutoresizingMaskIntoConstraints = false
        box.setWidth(iconBoxSize)
        box.setHeight(iconBoxSize)

        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iv.image = UIImage(systemName: symbol, withConfiguration: cfg)
        iv.tintColor = iconTint
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
        return box
    }

    // MARK: - Photo

    private func loadAvatar(from url: URL?) {
        photoLoadTask?.cancel()
        photoLoadTask = nil
        avatarImageView.image = nil

        guard let url else {
            avatarImageView.isHidden = true
            initialsLabel.isHidden = false
            return
        }

        avatarImageView.isHidden = false
        initialsLabel.isHidden = true

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.avatarImageView.isHidden = true
                    self?.initialsLabel.isHidden = false
                }
                return
            }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
                self?.avatarImageView.isHidden = false
                self?.initialsLabel.isHidden = true
            }
        }
        photoLoadTask = task
        task.resume()
    }

    // MARK: - Actions

    @objc
    private func notificationSwitchChanged(_ sender: UISwitch) {
        interactor.setNotificationEnabled(sender.isOn)
    }

    /// Программная установка без лишнего `.valueChanged` (иначе уходит второй PUT).
    private func applyNotificationSwitchFromViewModel(_ isOn: Bool) {
        notificationSwitch.removeTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
        notificationSwitch.setOn(isOn, animated: false)
        wireNotificationSwitchTarget()
    }

    private func wireNotificationSwitchTarget() {
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
    }

    @objc
    private func avatarAreaTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let canPreview = currentPhotoURL != nil || avatarImageView.image != nil
        if canPreview {
            sheet.addAction(UIAlertAction(title: "Посмотреть аватарку", style: .default) { [weak self] _ in
                self?.presentAvatarPreview()
            })
        }
        sheet.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            self?.presentCameraPicker()
        })
        sheet.addAction(UIAlertAction(title: "Медиатека", style: .default) { [weak self] _ in
            self?.presentPhotoLibraryPicker()
        })
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = avatarWrap
            pop.sourceRect = avatarWrap.bounds
        }
        present(sheet, animated: true)
    }

    private func presentAvatarPreview() {
        if let url = currentPhotoURL {
            present(AvatarPreviewViewController(remoteURL: url), animated: true)
        } else if let img = avatarImageView.image {
            present(AvatarPreviewViewController(localImage: img), animated: true)
        }
    }

    private func presentCameraPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "Камера недоступна", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    private func presentPhotoLibraryPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentAvatarCrop(image: UIImage) {
        let crop = AvatarCropViewController(
            image: image,
            onCancel: {},
            onConfirm: { [weak self] cropped in
                guard let self,
                      let data = AvatarImageProcessing.jpegDataForUpload(fromSquareImage: cropped)
                else { return }
                self.interactor.uploadAvatarPhoto(jpegData: data)
            }
        )
        present(crop, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let image else { return }
            self.presentAvatarCrop(image: image)
        }
    }

    // MARK: - PHPickerViewControllerDelegate

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let item = results.first, item.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            guard let self, let image = obj as? UIImage else { return }
            DispatchQueue.main.async {
                self.presentAvatarCrop(image: image)
            }
        }
    }

    @objc
    private func editTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Изменить данные", style: .default) { [weak self] _ in
            self?.presentEditProfileAlert()
        })
        sheet.addAction(UIAlertAction(title: "Удалить аккаунт", style: .destructive) { [weak self] _ in
            self?.presentDeleteAccountConfirmation()
        })
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = editAvatarButton
            pop.sourceRect = editAvatarButton.bounds
        }
        present(sheet, animated: true)
    }

    private func presentEditProfileAlert() {
        let alert = UIAlertController(title: "Изменить данные", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Имя"; $0.text = self.nameValueLabel.text }
        alert.addTextField { $0.placeholder = "Никнейм"; $0.text = self.usernameValueLabel.text?.replacingOccurrences(of: "@", with: "") }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self,
                  let name = alert.textFields?[0].text,
                  let username = alert.textFields?[1].text
            else { return }
            self.interactor.updateDisplayNameAndUsername(name: name, username: username)
        })
        present(alert, animated: true)
    }

    private func presentDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Удалить аккаунт?",
            message: "Профиль и данные будут удалены без возможности восстановления.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.interactor.deleteAccount()
        })
        present(alert, animated: true)
    }

    @objc
    private func signOutTapped() {
        let alert = UIAlertController(
            title: "Выйти из аккаунта?",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.interactor.signOut()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ProfileScreenViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        return !view.isDescendant(of: editAvatarButton)
    }
}

// MARK: - DisplayLogic

extension ProfileScreenViewController: ProfileScreenDisplayLogic {

    func displayProfile(_ viewModel: ProfileScreenModels.ViewModel) {
        nameValueLabel.text = viewModel.name
        usernameValueLabel.text = "@" + viewModel.username
        emailValueLabel.text = viewModel.emailDisplay == "не указан" ? "—" : viewModel.emailDisplay
        initialsLabel.text = viewModel.initials

        applyNotificationSwitchFromViewModel(viewModel.notificationEnabled)

        currentPhotoURL = viewModel.photoURL
        loadAvatar(from: viewModel.photoURL)
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            glassCardsForLoading.forEach { $0.alpha = 0.5 }
            editAvatarButton.isEnabled = false
            logoutCard.isUserInteractionEnabled = false
            notificationSwitch.isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            glassCardsForLoading.forEach { $0.alpha = 1 }
            editAvatarButton.isEnabled = true
            logoutCard.isUserInteractionEnabled = true
            notificationSwitch.isEnabled = true
        }
    }
}
