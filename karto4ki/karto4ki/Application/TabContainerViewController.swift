import UIKit

final class TabContainerViewController: UIViewController {

    // MARK: - Tab definitions

    private struct TabItem {
        let icon: String
        let activeIcon: String
        let makeVC: () -> UIViewController
    }

    private let appContext: ContextProtocol

    private lazy var tabs: [TabItem] = [
        TabItem(icon: "house",          activeIcon: "house.fill")     { MainScreenAssembly.build() },
        TabItem(icon: "plus.circle",    activeIcon: "plus.circle.fill") { PlaceholderViewController() },
        TabItem(icon: "books.vertical", activeIcon: "books.vertical.fill") { LibraryScreenAssembly.build() },
        TabItem(icon: "person",         activeIcon: "person.fill")    { ProfileScreenAssembly.build(context: self.appContext) }
    ]

    private var cachedVCs: [Int: UIViewController] = [:]
    private var selectedIndex: Int = 0
    private var tabButtons: [UIButton] = []

    // MARK: - UI

    private let contentContainer = UIView()
    private let tabBarContainer  = UIView()

    // MARK: - Init

    init(context: ContextProtocol) {
        self.appContext = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureBackground()
        configureContentContainer()
        configureTabBar()
        switchToTab(0, animated: false)
    }

    // MARK: - Background

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    // MARK: - Content area

    private func configureContentContainer() {
        view.addSubview(contentContainer)
        contentContainer.backgroundColor = .clear
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Tab bar

    private func configureTabBar() {
        tabBarContainer.backgroundColor = .clear
        tabBarContainer.layer.cornerRadius = 30
        tabBarContainer.clipsToBounds = true

        view.addSubview(tabBarContainer)
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBarContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tabBarContainer.heightAnchor.constraint(equalToConstant: 60)
        ])

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        tabBarContainer.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),
            stack.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            stack.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor)
        ])

        tabButtons = []
        for (index, tab) in tabs.enumerated() {
            let btn = UIButton(type: .system)
            btn.tag = index
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            updateButton(btn, icon: tab.icon, isActive: index == selectedIndex)
            stack.addArrangedSubview(btn)
            tabButtons.append(btn)
        }
    }

    private func updateButton(_ btn: UIButton, icon: String, isActive: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let img = UIImage(systemName: icon, withConfiguration: config)
        btn.setImage(img, for: .normal)
        btn.tintColor = isActive
            ? UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
            : UIColor.white.withAlphaComponent(0.7)
    }

    // MARK: - Switching

    @objc
    private func tabTapped(_ sender: UIButton) {
        switchToTab(sender.tag, animated: true)
    }

    private func switchToTab(_ index: Int, animated: Bool) {
        guard index != selectedIndex || cachedVCs[index] == nil else { return }

        // Remove current
        if let current = cachedVCs[selectedIndex] {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Update buttons
        let prev = selectedIndex
        selectedIndex = index
        if let prevBtn = tabButtons[safe: prev] {
            updateButton(prevBtn, icon: tabs[prev].icon, isActive: false)
        }
        if let newBtn = tabButtons[safe: index] {
            updateButton(newBtn, icon: tabs[index].activeIcon, isActive: true)
        }

        // Add new
        let vc = cachedVCs[index] ?? tabs[index].makeVC()
        cachedVCs[index] = vc

        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        if animated {
            vc.view.alpha = 0
            UIView.animate(withDuration: 0.2) { vc.view.alpha = 1 }
        }

        vc.didMove(toParent: self)
    }
}

// MARK: - Placeholder

private final class PlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
