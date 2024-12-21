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
    let schedule: [Weekday]
    let type: TrackerType
}

enum Weekday: Int {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

enum TrackerType {
    case habbit
    case event
}
