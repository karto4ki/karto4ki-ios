//
//  OnboardingViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let interactor: OnboardingBussinessLogic
    private let pageControl = UIPageControl()

    private lazy var pages: [UIViewController] = [
        PageViewController(
            title: "Учитесь эффективнее с флеш-карточками",
            description: "Флеш-карточки помогают структурировать информацию и быстрее запоминать материал — от языков до экзаменов и новых навыков."
        ),
        PageViewController(
            title: "Создавайте карточки автоматически",
            description: "Загружайте конспекты, документы или фото — приложение выделит ключевые термины и создаст карточки за вас."
        ),
        PageViewController(
            title: "Запоминание, \nа не заучивание",
            description: "Вопросы переформулируются, чтобы вы запоминали смысл, а не конкретную формулировку."
        ),
        PageViewController(
            title: "Всё для учебы\nв одном месте",
            description: "Создавайте наборы карточек, отслеживайте прогресс и делитесь материалами с другими пользователями.",
            interactor: interactor,
            button: true
        )
    ]

    init(interactor: OnboardingBussinessLogic) {
        self.interactor = interactor
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.lilicD9D7FF

        dataSource = self
        delegate = self

        setViewControllers([pages[0]], direction: .forward, animated: true)
        setupPageControl()
        
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        view.addSubview(pageControl)
        pageControl.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 16)
        pageControl.pinCenterX(to: view.centerXAnchor)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(where: { $0 === viewController }) else { return nil }
        let prevIndex = (index - 1 + pages.count) % pages.count
        return pages[prevIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(where: { $0 === viewController }) else { return nil }
        let nextIndex = (index + 1) % pages.count
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed, let currentVC = viewControllers?.first,
              let index = pages.firstIndex(of: currentVC) else { return }
        pageControl.currentPage = index
    }
}


