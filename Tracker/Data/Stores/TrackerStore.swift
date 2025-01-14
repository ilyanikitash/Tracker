//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/21/24.
//
import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func addNewTracker(_ tracker: TrackerModel, toCategory category: TrackerCategoryModel) throws
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData?
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerTypeValueTransformer = TrackerTypeValueTransformer()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext = {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//        fatalError("Unable to retrieve AppDelegate")
//    }
        //return appDelegate.persistentContainer.viewContext
        return CoreDataManager.shared.persistentContainer.viewContext
    }()) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchResult = TrackerCoreData.fetchRequest()
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insert = insertedIndexes, let deleted = deletedIndexes else { return }
        
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insert,
            deletedIndexes: deleted
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath else { return }
            deletedIndexes?.insert(indexPath.item)
        case .insert:
            guard let newIndexPath else { return }
            insertedIndexes?.insert(newIndexPath.item)
        default:
            break
        }
    }
}

extension TrackerStore: TrackerStoreProtocol {
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? .zero }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? .zero
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? .zero
    }
    
    func addNewTracker(_ tracker: TrackerModel, toCategory category: TrackerCategoryModel) throws {
        guard let categoryCoreData = trackerCategoryStore.getCategoryByTitle(category.title) else {
            throw StoreErrors.invalidTracker
        }
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.type = trackerTypeValueTransformer.transformedValue(tracker.type) as? String
        trackerCoreData.category = categoryCoreData
        categoryCoreData.addToTrackers(trackerCoreData)
        do {
            try context.save()
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to save tracker: \(error)")
        }
    }
    
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "id == %@", id as CVarArg
        )
        
        do {
            try fetchedResultsController.performFetch()
            guard let tracker = fetchedResultsController.fetchedObjects?.first else {
                throw StoreErrors.invalidFetchTracker
            }
            
            fetchedResultsController.fetchRequest.predicate = nil
            return tracker
        } catch {
            fatalError("Failed to fetch tracker by UUID: \(error)")
        }
    }
}
