//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/21/24.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTrackerRecord(with trackerRecordModel: TrackerRecordModel) {
        let trackerRecordEntity = TrackerRecordCoreData(context: context)
        trackerRecordEntity.id = trackerRecordModel.id
        trackerRecordEntity.date = trackerRecordModel.date
        
        let trackerCoreData = trackerStore.getTrackerCoreData(by: trackerRecordModel.id)
        trackerRecordEntity.trackers = trackerCoreData
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save tracker record: \(error.localizedDescription)")
        }
    }
    
    func fetchAllRecords() -> [TrackerRecordModel] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            return try context
                .fetch(fetchRequest)
                .compactMap { trackerRecordCoreData -> TrackerRecordModel? in
                    guard let id = trackerRecordCoreData.id,
                          let date = trackerRecordCoreData.date else { return nil }
                    return TrackerRecordModel(id: id, date: date)
                }
        } catch {
            fatalError("Failed to fetch tracker records: \(error.localizedDescription)")
        }
    }
    
    
    func deleteRecord(for trackerRecord: TrackerRecordModel) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            trackerRecord.id as CVarArg,
            trackerRecord.date as CVarArg
        )

        do {
            let results = try context.fetch(fetchRequest)
            guard let recordToDelete = results.first else {
                fatalError("No record found to delete for: \(trackerRecord)")
            }
            context.delete(recordToDelete)
            try context.save()
        } catch {
            print("Failed to delete record: \(error.localizedDescription)")
        }
    }
}
