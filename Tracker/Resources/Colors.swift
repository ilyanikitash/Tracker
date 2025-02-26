//
//  Colors.swift
//  Tracker
//
//  Created by Ilya Nikitash on 2/26/25.
//
import UIKit

final class Colors {
    let viewBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.lightGray
        } else {
            return UIColor(red: 0.8, green: 0.5, blue: 0.8, alpha: 1)
        }
    }
}
