//
//  PageViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import UIKit
import Lottie

// TODO: added different animations
final class PageViewController: UIViewController {

    private let titleText: String
    private let descriptionText: String
    private let animationView = LottieAnimationView(name: "logo")
    private let showButton: Bool
    private var interactor: OnboardingBussinessLogic?

    init(title: String, description: String, interactor: OnboardingBussinessLogic? = nil, button: Bool = false) {
        self.titleText = title
        self.descriptionText = description
        self.showButton = button
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animationView.play()
    }

    private func configureUI() {
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        let descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        
        let button = ButtonFactory.makeButton(
            title: "Продолжить",
            titleColor: Colors.lilicBAB6FD,
            backgroundColor: .white.withAlphaComponent(0.5),
            borderColor: .white.withAlphaComponent(0.8))
        button.isHidden = !showButton
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(routing), for: .touchUpInside)
        let buttonContainer = UIView()
        buttonContainer.addSubview(button)
        button.pinCenterX(to: buttonContainer.centerXAnchor)
        button.pinTop(to: buttonContainer.topAnchor, 0)
        button.pinBottom(to: buttonContainer.bottomAnchor, 0)
        button.setWidth(300)
        
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 10))
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 10))
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        
        stack.addArrangedSubview(view1)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(buttonContainer)
        stack.addArrangedSubview(view2)
        
        configureAnimation()
        view.addSubview(stack)
        stack.pinTop(to: animationView.bottomAnchor, 24)
        stack.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 32)
        stack.pinLeft(to: view.leadingAnchor, 24)
        stack.pinRight(to: view.trailingAnchor, 24)
        
        view1.isUserInteractionEnabled = false
        view2.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
    }
    
    private func configureAnimation() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        view.addSubview(animationView)
        animationView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 0)
        animationView.pinLeft(to: view.leadingAnchor, 0)
        animationView.pinRight(to: view.trailingAnchor, 0)

        view.layoutIfNeeded()
        let width = animationView.bounds.width
        animationView.setHeight(width)

        animationView.play()
        animationView.isUserInteractionEnabled = false
    }
    
    @objc
    private func routing() {
        interactor?.routingToSignIn()
    }
}
