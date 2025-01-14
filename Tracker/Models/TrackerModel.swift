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

extension TrackerModel {
    init?(from trackerCoreData: TrackerCoreData) {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let hexColor = trackerCoreData.color,
            let color = UIColorMarshalling().color(from: hexColor),
            let emoji = trackerCoreData.emoji,
            let typeRaw = trackerCoreData.type,
            let type = TrackerTypeValueTransformer().reverseTransformedValue(typeRaw) as? TrackerType,
            let schedule = trackerCoreData.schedule as? [Weekday]
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}
enum Weekday: Int, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

enum TrackerType {
    case habbit
    case event
}
