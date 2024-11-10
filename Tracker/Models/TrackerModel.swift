//
//  TrackerModel.swift
//  Tracker
//
//  Created by Ilya Nikitash on 7/11/24.
//
import UIKit

struct TrackerModel {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule?
}

struct Schedule {
    let weekdays: [Weekday : Bool]
}

enum Weekday: String, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}


