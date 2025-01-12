//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Ilya Nikitash on 1/12/25.
//
import Foundation

final class CategoriesViewModel {
    var didUpdateCategories: (() -> Void)?
    var didSelectedRaw: ((TrackerCategoryModel) -> Void)?
    private(set) var categories: [TrackerCategoryModel] = [] {
        didSet {
            didUpdateCategories?()
        }
    }
    
    private var selectedCategory: TrackerCategoryModel?  {
        didSet {
            guard let selectedCategory else { return }
            didSelectedRaw?(selectedCategory)
        }
    }

    private var trackerStore = TrackerStore()
    private var trackerCategoryStore = TrackerCategoryStore()
    
    /// Метод загрузки данных из CoreData при первом входе в приложение по паттерну MVVM
    func loadCategoriesFromCoreData() {
        categories = trackerCategoryStore.fetchAllCategories()
        print("CATEGORIES UPDATED")
    }
    
    /// Метод добавления новой категории по паттерну MVVM
    func addCategory(name: String) {
        categories.append(TrackerCategoryModel(title: name, trackers: []))
        trackerCategoryStore.createCategory(with: TrackerCategoryModel(title: name, trackers: []))
    }
    
    /// Метод удаления категории по паттерну MVVM
    func deleteCategory(_ category: String) {
        do {
            try trackerCategoryStore.deleteCategory(byTitle: category)
            categories.removeAll{$0.title == category}
        } catch {
            print("ОШИБКА УДАЛЕНИЯ КАТЕГОРИИ: \(error.localizedDescription)")
            return
        }
    }
    
    func isSelectedCategory(category: TrackerCategoryModel) -> Bool {
        selectedCategory?.title == category.title
    }
    
    func didSelectCategory(category: TrackerCategoryModel) {
        selectedCategory = category
    }
}
