//
//  TrackerRecordModel.swift
//  Tracker
//
//  Created by Ilya Nikitash on 7/11/24.
//
import Foundation

struct TrackerRecordModel: Hashable {
    let id: UUID
    let date: Date
}

extension TrackerRecordModel {
    init?(from trackerRecordEntity: TrackerRecordCoreData) {
        guard
              let id = trackerRecordEntity.id,
              let date = trackerRecordEntity.date
        else {
            return nil
        }
        self.id = id
        self.date = date
    }
}
