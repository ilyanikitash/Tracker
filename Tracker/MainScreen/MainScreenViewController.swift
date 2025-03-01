//
//  MainScreenViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//
import UIKit
import YandexMobileMetrica

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
        label.text = NSLocalizedString("whatTrack", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .customBlack
        return label
    }()
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.locale = .current
        datePicker.maximumDate = Date()
        return datePicker
    }()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .customWhite
        return collectionView
    }()
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Filter", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .customBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    // MARK: - properties
    var categories: [TrackerCategoryModel] = []
    var completedTrackers: Set<TrackerRecordModel> = []
    private var filter: FilterCases? {
        didSet {
            userAppSettingsStorage.selectedFilter = filter
            isFilersActive(filtersActiveState.contains(filter))
        }
    }
    private var filteredCategories: [TrackerCategoryModel] = []
    private var trackerCategoryStore = TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    private let filtersActiveState: [FilterCases?] = [.all, .completed, .notCompleted]
    private let userAppSettingsStorage = UserAppSettingStorage.shared
    var currentDate: Date = Date()
    weak var newTrackerDelegate: NewTrackerViewControllerDelegate?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
        getAllCategories()
        if categories.isEmpty {
            trackerCategoryStore.createCategory(with: TrackerCategoryModel(title: NSLocalizedString("important.title", comment: ""), trackers: []))
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
        YMMYandexMetrica.reportEvent("add_tracker", onFailure: { (error) in
            print("DID FAIL TO REPORT EVENT: %@", "add_tracker")
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        let createTrackerVC  = CreateTrackerViewController()
        createTrackerVC.mainScreenViewController = self
        createTrackerVC.modalPresentationStyle = .popover
        present(createTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged() {
        YMMYandexMetrica.reportEvent("date_picker_value_change", onFailure: { (error) in
            print("DID FAIL TO REPORT EVENT: %@", "date_picker_value_change")
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        currentDate = datePicker.date
        filter = .all
        updateFilteredCategories(with: "")
        filterButton.isHidden = filteredCategories.isEmpty
    }
    @objc private func didTapFilterButton() {
        let filtersVC = FilterViewController(
            selectedFilter: filter,
            delegate: self
        )
        self.present(UINavigationController(rootViewController: filtersVC), animated: true)
    }
    //MARK: - Functions
    func isFilersActive(_ isActive: Bool) {
        let titleColor = isActive
        ? UIColor.customWhite
        : UIColor.customBlack
        filterButton.setTitleColor(titleColor, for: .normal)
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
    
    private func updateFilteredCategories(with text: String) {
        switch filter {
        case .all, .none, .today:
            reloadFiltredCategories(with: text) { id in
                true
            }
        case .completed:
            reloadFiltredCategories(with: text) { id in
                completedTrackers
                    .contains {
                        $0.id == id && $0.date == currentDate
                    }
            }
        case .notCompleted:
            reloadFiltredCategories(with: text) { id in
                !completedTrackers
                    .contains {
                        $0.id == id && $0.date == currentDate
                    }
            }
        }
        
        collectionView.reloadData()
    }
    
    private func reloadFiltredCategories(with text: String, filterCheck: ((UUID) -> Bool)) {
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
                
                let filterCondition = filterCheck(tracker.id)
                
                return textCondition && dateCondition && filterCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategoryModel(
                    title: category.title,
                    trackers: trackers
            )
        }
        filteredCategories = sortCategories(filteredCategories)
        collectionView.reloadData()
        reloadPlaceholder(text)
    }
    private func sortCategories(_ categories: [TrackerCategoryModel]) -> [TrackerCategoryModel] {
        var cleanCategories: [TrackerCategoryModel] = []
        var pinnedTrackerList: [TrackerModel] = []
        
        categories.forEach { category in
            var trackers: [TrackerModel] = []
            var pinnedTrackers: [TrackerModel] = []
            
            category.trackers.forEach { trackerData in
                let isPinned = trackerData.isPinned
                isPinned
                    ? pinnedTrackers.append(trackerData)
                    : trackers.append(trackerData)
            }
            
            if !pinnedTrackers.isEmpty {
                pinnedTrackerList.append(contentsOf: pinnedTrackers)
            }
            
            if !trackers.isEmpty {
                cleanCategories
                    .append(
                        TrackerCategoryModel(
                            title: category.title,
                            trackers: trackers.sorted(by: {$0.name > $1.name})
                        )
                    )
            }
        }
        
        if !pinnedTrackerList.isEmpty {
            let pinnedCategory = TrackerCategoryModel(
                title: NSLocalizedString("pin_category", comment: ""),
                trackers: pinnedTrackerList.sorted(by: {$0.name > $1.name})
            )
            cleanCategories.insert(pinnedCategory, at: 0)
        }
        
        return cleanCategories
    }
    private func reloadPlaceholder(_ searchBarText: String) {
        let isEmpty = filteredCategories.isEmpty
        if searchBarText != "" {
            startImageView.image = UIImage(named: "ErrorImage")
            startLabel.text = NSLocalizedString("nothing", comment: "")
        }
        startImageView.isHidden = !isEmpty
        startLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    private func setupNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .customWhite
        navigationItem.leftBarButtonItem = plusButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("trackers", comment: "")
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
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
        view.backgroundColor = .customWhite
        
        view.addSubview(startImageView)
        setupStartImageViewConstraints()
        
        view.addSubview(startLabel)
        setupStartLabelConstraints()
        
        view.addSubview(collectionView)
        setupCollectionViewConstraints()
        
        view.addSubview(filterButton)
        setupFilterButtonConstraints()
    }
    private func setupCollectionView() {
        collectionView.register(MainScreenCollectionViewCell.self, forCellWithReuseIdentifier: MainScreenCollectionViewCell.identifier)
        collectionView.register(MainScreenCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainScreenCategoryHeader.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    // MARK: - Contraints
    private func setupFilterButtonConstraints() {
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let pinText = tracker.isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: "")
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: pinText) { [weak self] _ in
                    guard let self else { return }
                    
                    let trackerPinned = TrackerModel(
                        id: tracker.id,
                        name: tracker.name,
                        color: tracker.color,
                        emoji: tracker.emoji,
                        schedule: tracker.schedule,
                        type: tracker.type,
                        isPinned: !tracker.isPinned
                    )
                    self.trackerStore.updateTrackerPin(trackerPinned)
                    self.getAllCategories()
                    updateFilteredCategories(with: "")
                },
                UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    let daysCount = self.completedTrackers.filter { $0.id == tracker.id }.count
                    
                    var realCategory: TrackerCategoryModel? = nil

                    for category in categories {
                        let filteredTrackers = category.trackers.filter { tracker.id == $0.id
                        }
                        
                        if !filteredTrackers.isEmpty {
                            realCategory = category
                        }
                    }
                    
                    if tracker.type == .habbit {
                        let editTrackerVC = NewHabitViewController (
                            trackerToEdit: tracker,
                            category: realCategory,
                            daysCount: daysCount
                        )
                        editTrackerVC.newTrackerDelegate = self
                        self.present(UINavigationController(rootViewController: editTrackerVC), animated: true)
                    } else {
//                        let editTrackerVC = NewIrregularEventViewController (
//                            trackerToEdit: tracker,
//                            category: realCategory
//                        )
//                        editTrackerVC.trackerHabbitDelegate = self
//                        self.present(UINavigationController(rootViewController: editTrackerVC), animated: true)
                    }
                },
                UIAction(title: NSLocalizedString("delete", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    self.deleteTracker(tracker)
                },
            ])
        })
    }
    
    private func deleteTracker(_ tracker: TrackerModel) {
        let alertController = UIAlertController(title: "Вы уверены?", message: "Удалить трекер?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
            guard let self else { return }
            self.trackerStore.deleteTracker(tracker)
            self.getAllCategories()
            updateFilteredCategories(with: "")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.getAllCategories()
            updateFilteredCategories(with: "")
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainScreenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        updateFilteredCategories(with: text)
    }
}

extension MainScreenViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        updateFilteredCategories(with: text)
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
            updateFilteredCategories(with: "")
            
        } catch {
            print("error adding tracker: \(error.localizedDescription)")
        }
    }
    
    func didTabCancelButton() {
        dismiss(animated: true)
    }
    
    func didTabSaveButton(categoryTitle: String, trackerToUpdate: TrackerModel) {
        print("🛠 Метод didTapSaveButton вызван с categoryTitle: \(categoryTitle)")
    
        guard let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) else {
            print("⚠️ Категория не найдена: \(categoryTitle)")
            return
        }
        
        let category = categories[categoryIndex]
        
        trackerStore.updateTracker(trackerToUpdate, from: category)
        
        getAllCategories()
        getCompletedTrackers()
        updateFilteredCategories(with: "")
        
        // Закрываем экран редактирования
        dismiss(animated: true)
    }
}

extension MainScreenViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.reloadData()
//            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
//            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
//            
//            collectionView.insertItems(at: insertedIndexPaths)
//            collectionView.deleteItems(at: deletedIndexPaths)
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }
}

extension MainScreenViewController: FilterViewControllerDelegate {
    func filterChanged(to newFilter: FilterCases) {
        guard newFilter == .today else {
            filter = newFilter
            updateFilteredCategories(with: "")
            return
        }
        filter = newFilter
        currentDate = Calendar.current.startOfDay(for: Date())
        datePicker.date = currentDate
        updateFilteredCategories(with: "")
    }
}
