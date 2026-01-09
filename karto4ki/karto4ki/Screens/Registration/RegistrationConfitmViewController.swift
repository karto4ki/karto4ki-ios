//
//  RegistrationConfitmViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 09.01.2026.
//

import UIKit

final class RegistrationConfitmViewController: UIViewController {
    
    private let name: String
    private let username: String
    private let heart = UILabel()
    private let nameButton = UIButton(type: .system)
    private var isNameTapped: Bool = false
    private let usernameButton = UIButton(type: .system)
    private let closure: (Bool) -> Void
    
    init(name: String, username: String, closure: @escaping (Bool) -> Void) {
        self.name = name
        self.username = username
        self.closure = closure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        configureBackground()
        configureHeart()
        configureNameButton()
        configureUsernameButton()
    }
    
    private func configureBackground() {
        let background = BackgroundView(with: "background-10")
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }
    
    private func configureHeart() {
        heart.text = "."
        heart.font = UIFont(name: "Musinka-Regular", size: 500)
        heart.textColor = .white
        heart.textAlignment = .center
        view.addSubview(heart)
        heart.pinTop(to: view.safeAreaLayoutGuide.topAnchor, -200)
        heart.pinCenterX(to: view.centerXAnchor)
    }
    
    private func configureNameButton() {
        var config = UIButton.Configuration.plain()

        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        config.background.cornerRadius = 25
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

        nameButton.configuration = config
        nameButton.titleLabel?.numberOfLines = 3
        nameButton.titleLabel?.lineBreakMode = .byCharWrapping
        nameButton.titleLabel?.textAlignment = .center
        nameButton.addTarget(self, action: #selector(goBackName), for: .touchUpInside)
        var attrs = AttributeContainer()
        attrs.font = UIFont(name: "Musinka-Regular", size: 40) ?? .systemFont(ofSize: 40)
        attrs.foregroundColor = UIColor(red: 255/255, green: 174/255, blue: 213/255, alpha: 1)

        config.attributedTitle = AttributedString("имя: \(name)", attributes: attrs)
        nameButton.configuration = config

        view.addSubview(nameButton)
        nameButton.pinLeft(to: view.leadingAnchor, 40)
        nameButton.pinRight(to: view.trailingAnchor, 40)
        nameButton.pinTop(to: heart.bottomAnchor, -20)
    }
    
    private func configureUsernameButton() {
        var config = UIButton.Configuration.plain()

        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        config.background.cornerRadius = 25
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

        usernameButton.configuration = config
        usernameButton.titleLabel?.numberOfLines = 3
        usernameButton.titleLabel?.lineBreakMode = .byCharWrapping
        usernameButton.titleLabel?.textAlignment = .center
        usernameButton.addTarget(self, action: #selector(goBackUsername), for: .touchUpInside)
        var attrs = AttributeContainer()
        attrs.font = UIFont(name: "Musinka-Regular", size: 40) ?? .systemFont(ofSize: 40)
        attrs.foregroundColor = UIColor(red: 255/255, green: 174/255, blue: 213/255, alpha: 1)

        config.attributedTitle = AttributedString("username: \(username)", attributes: attrs)
        usernameButton.configuration = config

        view.addSubview(usernameButton)
        usernameButton.pinLeft(to: view.leadingAnchor, 40)
        usernameButton.pinRight(to: view.trailingAnchor, 40)
        usernameButton.pinTop(to: nameButton.bottomAnchor, 10)
    }
    
    @objc private func goBackName() {
        closure(true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goBackUsername() {
        closure(false)
        navigationController?.popViewController(animated: true)
    }
}


