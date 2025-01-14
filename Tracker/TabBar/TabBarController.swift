//
//  TabBarController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//
import UIKit

final class TabBarController: UITabBarController {
    weak var onboardingViewController: OnboardingViewController?
    
    private var viewControllersList: [UIViewController] {
            
        let mainVC = MainScreenViewController()
        let mainNavController = UINavigationController(rootViewController: mainVC)
            
        mainNavController.setNavigationBarHidden(false, animated: false)
        mainNavController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TabBarTrackersActive"), tag: 0)
            
        let secondVC = StatisticsViewController()
        secondVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "TabBarStatisticsActive"), tag: 1)
            
        return [mainNavController, secondVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
        
        viewControllers = viewControllersList
        configureTabBarAppearance()
    }
    
    private func configureTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
    }
    
}
