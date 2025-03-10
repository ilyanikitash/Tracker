//
//  FilterCases.swift
//  Tracker
//
//  Created by Ilya Nikitash on 2/27/25.
//
import Foundation

enum FilterCases: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: NSLocalizedString("all_trackers", comment: "")
        case .today: NSLocalizedString("today_trackers", comment: "")
        case .completed: NSLocalizedString("completed_trackers", comment: "")
        case .notCompleted: NSLocalizedString("not_completed_trackers", comment: "")
        }
    }
}
