//
//  TrackerCategoryModel.swift
//  Tracker
//
//  Created by Ilya Nikitash on 7/11/24.
//
import Foundation

struct TrackerCategoryModel {
    let title: String
    let trackers: [TrackerModel]
}

extension TrackerCategoryModel {
    init?(from categoryCoreData: TrackerCategoryCoreData) {
        guard let title = categoryCoreData.title
        else {
            return nil
        }
        
        let trackerList: [TrackerModel] = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { TrackerModel(from: $0) } ?? []
        
        self.title = title
        self.trackers = Array(trackerList)
    }
}
