//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 1/5/25.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    private let userDefaults: UserDefaults = .standard
    private lazy var pages: [UIViewController] = {
        let blueVC = UIViewController()
        let blueBackgroundImage = setupBackgroundImage(named: "BackgroundBlue")
        blueVC.view.addSubview(blueBackgroundImage)

        let redVC = UIViewController()
        let redBackgroundImage = setupBackgroundImage(named: "BackgroundRed")
        redVC.view.addSubview(redBackgroundImage)

        NSLayoutConstraint.activate([
            blueBackgroundImage.topAnchor.constraint(equalTo: blueVC.view.topAnchor),
            blueBackgroundImage.bottomAnchor.constraint(equalTo: blueVC.view.bottomAnchor),
            blueBackgroundImage.leadingAnchor.constraint(equalTo: blueVC.view.leadingAnchor),
            blueBackgroundImage.trailingAnchor.constraint(equalTo: blueVC.view.trailingAnchor),

            redBackgroundImage.topAnchor.constraint(equalTo: redVC.view.topAnchor),
            redBackgroundImage.bottomAnchor.constraint(equalTo: redVC.view.bottomAnchor),
            redBackgroundImage.leadingAnchor.constraint(equalTo: redVC.view.leadingAnchor),
            redBackgroundImage.trailingAnchor.constraint(equalTo: redVC.view.trailingAnchor)
        ])

        return [blueVC, redVC]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .customBlack
        pageControl.pageIndicatorTintColor = .customLightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = pagesText[0]
        label.textColor = .customBlack
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .customBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        
        return button
    }()
    
    private let pagesText: [String] = [
        "Welcome to Tracker",
        "Track your expenses and income"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupView()
    }
    
    @objc
    private func didTapStartButton() {
        let controller = TabBarController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        userDefaults.setValue(true, forKey: "notFirstStart")
        
        if let window = UIApplication.shared.windows.first {
            let initialViewController = TabBarController()
            window.rootViewController = initialViewController
        }
    }
    
    private func setupView() {
        view.addSubview(pageControl)
        view.addSubview(startButton)
        view.addSubview(textLabel)
        

        NSLayoutConstraint.activate([
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupBackgroundImage(named name: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: name)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return pages.last
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return pages.first
        }

        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
            textLabel.text = pagesText[currentIndex]
        }
    }
}
