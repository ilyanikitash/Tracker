//
//  AppDelegate.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//

import UIKit
import CoreData
import YandexMobileMetrica
//aba820ae-cc15-4240-bdae-f7899c2e1fd3
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let coreDataManager = CoreDataManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ScheduleValueTransformer.register()
        TrackerTypeValueTransformer.register()
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "aba820ae-cc15-4240-bdae-f7899c2e1fd3") else {
                return true
            }
                
        YMMYandexMetrica.activate(with: configuration)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataManager.saveContext()
    }
}

