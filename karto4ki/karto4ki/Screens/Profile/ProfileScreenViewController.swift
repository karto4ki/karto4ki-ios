import UIKit

final class ProfileScreenViewController: UIViewController {

    private let interactor: ProfileScreenBusinessLogic

    private let signOutButton = ButtonFactory.makeButton(
        title: "Выйти",
        titleColor: .white.withAlphaComponent(0.9),
        backgroundColor: UIColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 0.25),
        borderColor: UIColor(red: 0.95, green: 0.40, blue: 0.45, alpha: 0.8)
    )

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
        configureUI()
    }

    // MARK: - UI

    private func configureUI() {
        configureBackground()
        configureTitleLabel()
        configureSignOutButton()
    }

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    private func configureTitleLabel() {
        let label = UILabel()
        label.text = "Профиль"
        label.font = Fonts.futuraB22
        label.textColor = .white
        label.textAlignment = .center

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureSignOutButton() {
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        view.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    // MARK: - Actions

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

// MARK: - DisplayLogic

extension ProfileScreenViewController: ProfileScreenDisplayLogic {}
