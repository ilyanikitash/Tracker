//
//  MainScreenViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//
import UIKit

final class MainScreenViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var plusButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        button.tintColor = .customBlack
        return button
    }()
    private lazy var startImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StartImage")
        return imageView
    }()
    private lazy var startLabel: UILabel = {
       let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .customBlack
        return label
    }()
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.maximumDate = Date()
        return datePicker
    }()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    // MARK: - properties
    var categories: [TrackerCategoryModel] = []
    var completedTrackers: Set<TrackerRecordModel> = []
    private var filteredCategories: [TrackerCategoryModel] = []
    private var trackerCategoryStore = TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    var currentDate: Date = Date()
    lazy var newHabitViewController: NewHabitViewController = {
        let viewController = NewHabitViewController()
        viewController.newTrackerDelegate = self
        return viewController
    }()
    lazy var newIrregularEventViewController: NewIrregularEventViewController = {
        let viewController = NewIrregularEventViewController()
        viewController.newTrackerDelegate = self
        return viewController
    }()
    weak var newTrackerDelegate: NewTrackerViewControllerDelegate?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
        getAllCategories()
        if categories.isEmpty {
            trackerCategoryStore.createCategory(with: TrackerCategoryModel(title: "Важное", trackers: []))
            getAllCategories()
        }
        getCompletedTrackers()
        
        setupNavigationBar()
        setupUserInterface()
        updateUI()
        setupCollectionView()
    }
    // MARK: - Selectors
    @objc private func plusButtonTapped() {
        let createTrackerVC  = CreateTrackerViewController()
        createTrackerVC.mainScreenViewController = self
        createTrackerVC.modalPresentationStyle = .popover
        present(createTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        reloadFiltredCategories(with: "")
    }
    func updateViewControllers() {
        print("!!!!!!!!!!!!! UPDESTAEEF")
        newHabitViewController = NewHabitViewController()
        newHabitViewController.newTrackerDelegate = self
        
        newIrregularEventViewController = NewIrregularEventViewController()
        newIrregularEventViewController.newTrackerDelegate = self
    }
    // MARK: - Private functions
    private func getAllCategories() {
        categories = trackerCategoryStore.fetchAllCategories()
    }
    
    private func getCompletedTrackers() {
        completedTrackers  = Set(trackerRecordStore.fetchAllRecords())
    }
    
    private func updateUI() {
        collectionView.reloadData()
        datePickerValueChanged()
    }
    
    private func reloadFiltredCategories(with text: String) {
        let calendar = Calendar.current
        var filterWeekday = calendar.component(.weekday, from: currentDate) - 1
        if filterWeekday == 0 {
            filterWeekday = 7
        }
        let filterText = text.lowercased()
        
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                    tracker.name.lowercased().contains(filterText)

                let dateCondition = tracker.schedule.contains { weekDay in
                    return weekDay.rawValue == filterWeekday
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategoryModel(
                    title: category.title,
                    trackers: trackers
            )
        }
        collectionView.reloadData()
        reloadPlaceholder(text)
    }
    private func reloadPlaceholder(_ searchBarText: String) {
        let isEmpty = filteredCategories.isEmpty
        if searchBarText != "" {
            startImageView.image = UIImage(named: "ErrorImage")
            startLabel.text = "Ничего не найдено"
        }
        startImageView.isHidden = !isEmpty
        startLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = plusButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let records = trackerRecordStore.fetchAllRecords()
        
        if let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }),
           tracker.type == .event {
            return records.contains { $0.id == id }
        }

        return records.contains {
            $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
    }
    private func setupUserInterface() {
        setupDatePickerConstraints()
        view.backgroundColor = .white
        
        view.addSubview(startImageView)
        setupStartImageViewConstraints()
        
        view.addSubview(startLabel)
        setupStartLabelConstraints()
        
        view.addSubview(collectionView)
        setupCollectionViewConstraints()
    }
    private func setupCollectionView() {
        collectionView.register(MainScreenCollectionViewCell.self, forCellWithReuseIdentifier: MainScreenCollectionViewCell.identifier)
        collectionView.register(MainScreenCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainScreenCategoryHeader.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    // MARK: - Contraints
    private func setupDatePickerConstraints() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    private func setupStartImageViewConstraints() {
        startImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startImageView.heightAnchor.constraint(equalToConstant: 80),
            startImageView.widthAnchor.constraint(equalToConstant: 80),
            startImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    private func setupStartLabelConstraints() {
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startLabel.topAnchor.constraint(equalTo: startImageView.bottomAnchor, constant: 8),
            startLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    private func setupCollectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
}
// MARK: - UICollectionViewDataSource
extension MainScreenViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCollectionViewCell.identifier, for: indexPath) as? MainScreenCollectionViewCell else {
            return UICollectionViewCell()
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self

        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays: Int

        if tracker.type == .event {
            completedDays = completedTrackers.contains { $0.id == tracker.id } ? 1 : 0
        } else {
            completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        }

        cell.configure(with: tracker,
                       isCompletedToday: isCompletedToday,
                       indexPath: indexPath,
                       completedDays: completedDays)

        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MainScreenCategoryHeader.identifier, for: indexPath) as? MainScreenCategoryHeader else { return UICollectionReusableView() }
            let category = filteredCategories[indexPath.section]
            header.configure(with: category.title)
            return header
        }
        return UICollectionReusableView()
    }
}

extension MainScreenViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
                .flatMap({ $0.trackers })
                .first(where: { $0.id == id }) else { return }
        
        let record: TrackerRecordModel? = {
            switch tracker.type {
            case .habbit:
                return trackerRecordStore.fetchAllRecords().first {$0.id == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)}
            case .event:
                return trackerRecordStore
                    .fetchAllRecords()
                    .first { $0.id == id }
            }
        }()
        if let record {
            trackerRecordStore.deleteRecord(for: record)
        } else {
            let newRecord = TrackerRecordModel(id: id, date: tracker.type == .habbit ? currentDate : Date.distantPast)
            trackerRecordStore.addTrackerRecord(with: newRecord)
        }
        
        getCompletedTrackers()
        collectionView.reloadItems(at: [indexPath])
        collectionView.reloadData()
    }


    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
                .flatMap({ $0.trackers })
                .first(where: { $0.id == id }) else { return }

        if tracker.type == .habbit {
            if let record = trackerRecordStore
                .fetchAllRecords()
                .first(where: {
                    $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                }) {
                trackerRecordStore.deleteRecord(for: record)
            }
        }
        
        else if tracker.type == .event {
            if let record = trackerRecordStore
                .fetchAllRecords()
                .first(where: { $0.id == id }) {
                trackerRecordStore.deleteRecord(for: record)
            }
        }
        getCompletedTrackers()

        collectionView.reloadItems(at: [indexPath])
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 9
        let availableWidth = collectionView.bounds.width - padding
        let cellWidth = availableWidth / 2 - 8
        
        return CGSize(width: cellWidth, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension MainScreenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        reloadFiltredCategories(with: text)
    }
}

extension MainScreenViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        reloadFiltredCategories(with: text)
        searchBar.resignFirstResponder()
    }
}

extension MainScreenViewController: NewTrackerViewControllerDelegate {
    func didTabCreateButton(categoryTitle: String, trackerToAdd: TrackerModel) {
        getAllCategories()
        guard let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) else {
            fatalError("couldn't find category \(categoryTitle)")
        }
        dismiss(animated: true)
        do {
            try trackerStore.addNewTracker(trackerToAdd, toCategory: categories[categoryIndex])
            getAllCategories()
            getCompletedTrackers()
            reloadFiltredCategories(with: "")
            
        } catch {
            print("error adding tracker: \(error.localizedDescription)")
        }
    }
    
    func didTabCancelButton() {
        dismiss(animated: true)
    }
}

extension MainScreenViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }
}
