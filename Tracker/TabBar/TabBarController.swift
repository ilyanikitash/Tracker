//
//  TabBarController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let mainScreenViewController = MainScreenViewController()
        mainScreenViewController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                           image: UIImage(named: "TabBarTrackersActive"),
                                                           selectedImage: nil)
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                           image: UIImage(named: "TabBarStatisticsActive"),
                                                           selectedImage: nil)
        self.viewControllers = [mainScreenViewController, statisticsViewController]
    }
}
