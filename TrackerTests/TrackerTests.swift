//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ilya Nikitash on 3/1/25.
//

import Testing
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testMainScreenViewController() {
        let vc = MainScreenViewController()
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)))
    }
    
    func testMainScreenControllerDarkTheme() {
        let vc = MainScreenViewController()
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)))
    }
    
    func testMainScreenVC() {
        let vc = MainScreenViewController()
        
        assertSnapshot(of: vc, as: .image)
    }
}
