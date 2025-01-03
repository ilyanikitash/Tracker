//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/21/24.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    enum TrackerCategoryStoreError: Error {
        case categoryNotFound
    }
    
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
    
    func createCategory(with category: TrackerCategoryModel) {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        categoryEntity.trackers = NSSet()

        do {
            try context.save()
        } catch {
            fatalError("Error creatimg category: \(error.localizedDescription)")
        }
    }
    
    func getCategoryByTitle(_ title: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        request.fetchLimit = 1
        
        do {
            let category = try context.fetch(request)
            return category.first
        } catch {
            print("Failed to find category by title: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAllCategories() -> [TrackerCategoryModel] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreDataArray = try context.fetch(fetchRequest)
            let categories = categoriesCoreDataArray
                .compactMap { categoriesCoreData -> TrackerCategoryModel? in
                    decodingCategory(from: categoriesCoreData)
                }
            return categories
        } catch {
            fatalError("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(byTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        guard let categoryCoreData = try context.fetch(fetchRequest).first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }

        context.delete(categoryCoreData)
        try context.save()
    }
    
    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategoryModel? {
        guard let title = trackerCategoryCoreData.title else {
            fatalError("Failed to decode category: title is missing")
        }
        guard let trackerCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            fatalError("Failed to decode category: trackers data is invalid")
        }
        let trackers = trackerCoreDataSet.compactMap { TrackerModel(from: $0) }
        
        if trackers.isEmpty {
            print("!!! Category with no trackers - \(title)")
        }
        return TrackerCategoryModel(title: title, trackers: trackers)
    }
}
