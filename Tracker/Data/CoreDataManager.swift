//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Ilya Nikitash on 1/6/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Error loading persistent store: \(error.localizedDescription)")
                fatalError("Error loading persistent store: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
       return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError.localizedDescription)")
                fatalError("Error saving context: \(nsError.localizedDescription)")
            }
        }
    }

    // выполнения операций в фоновом потоке
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { backgroundContext in
            block(backgroundContext)
            do {
                try backgroundContext.save()
            } catch {
                let nsError = error as NSError
                print("Error saving background context: \(nsError.localizedDescription)")
            }
        }
    }
}
