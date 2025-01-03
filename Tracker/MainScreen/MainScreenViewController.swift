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
    var categories: [TrackerCategoryModel] = [
        TrackerCategoryModel(title: "Важное", trackers: [
            TrackerModel(id: UUID(), name: "Спать", color: .color1, emoji: "❤️", schedule: [.monday, .thursday, .wednesday, .tuesday, .friday, .saturday, .sunday], type: .habbit),
            TrackerModel(id: UUID(), name: "Есть", color: .color7, emoji: "🍔", schedule: [.monday, .thursday, .wednesday, .tuesday, .friday, .saturday, .sunday], type: .habbit)
        ]),
        TrackerCategoryModel(title: "Неважное", trackers: [
            TrackerModel(id: UUID(), name: "Грустить", color: .color4, emoji: "😱", schedule: [.monday, .thursday, .wednesday, .tuesday, .friday, .saturday, .sunday], type: .habbit)
        ])
    ]
    var completedTrackers: [TrackerRecordModel] = []
    private var filteredCategories: [TrackerCategoryModel] = []
    var currentDate: Date = Date()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewTrackerNotification(_:)), name: .didCreateNewTracker, object: nil)
        setupNavigationBar()
        setupUserInterface()
        updateUI()
        setupCollectionView()
    }
    // MARK: - Selectors
    @objc private func didReceiveNewTrackerNotification(_ notification: Notification) {
        //guard let newTracker = notification.object as? TrackerModel else { return }
        
        var updatedCategories: [TrackerCategoryModel] = []
        
        var trackerAdded = false
        
        var newTracker: TrackerModel = TrackerModel(id: UUID(),
                                                    name: "",
                                                    color: .red,
                                                    emoji: "",
                                                    schedule: [.monday],
                                                    type: .event)
        var categoryName: String = ""
        
        if let userInfo = notification.userInfo {
            if let tracker = userInfo["newTracker"] as? TrackerModel,
               let category = userInfo["categoryName"] as? String
            {
                newTracker = tracker
                categoryName = category
            } else {
                fatalError("Invalid notification userInfo")
            }
        }
        for category in categories {
            if category.title == categoryName {
                var updatedTrackers = category.trackers
                updatedTrackers.append(newTracker)
                
                let updatedCategory = TrackerCategoryModel(title: category.title, trackers: updatedTrackers)
                updatedCategories.append(updatedCategory)
                trackerAdded = true
            } else {
                updatedCategories.append(category)
            }
        }
        
        if !trackerAdded {
            let newCategory = TrackerCategoryModel(title: categoryName, trackers: [newTracker])
            updatedCategories.append(newCategory)
        }
        
        categories = updatedCategories
        updateUI()
    }
    
    @objc private func plusButtonTapped() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.modalPresentationStyle = .popover
        present(createTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        reloadFiltredCategories(with: "")
    }
    // MARK: - Private functions
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
        print("FILTER WEEKDAY: \(filterWeekday)")
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
        if let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }),
           tracker.type == .event {
            return completedTrackers.contains { $0.id == id }
        }

        return completedTrackers.contains {
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
            completedDays = completedTrackers.contains { $0.id == tracker.id } ? 1 : 0 // 0 дней для новых событий
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

        if tracker.type == .habbit {
            let isAlreadyCompleted = completedTrackers.contains {
                $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }
            guard !isAlreadyCompleted else { return }

            let trackerRecord = TrackerRecordModel(id: id, date: currentDate)
            completedTrackers.append(trackerRecord)
        }

        else if tracker.type == .event {
            if completedTrackers.contains(where: { $0.id == id }) {
                uncompleteTracker(id: id, at: indexPath)
                return
            } else {
                completedTrackers.append(TrackerRecordModel(id: id, date: Date.distantPast))
            }
        }

        collectionView.reloadItems(at: [indexPath])
        collectionView.reloadData()
    }


    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
                .flatMap({ $0.trackers })
                .first(where: { $0.id == id }) else { return }

        if tracker.type == .habbit {
            completedTrackers.removeAll { trackerRecord in
                trackerRecord.id == id &&
                Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
            }
        }

        else if tracker.type == .event {
            completedTrackers.removeAll { $0.id == id }
        }

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

extension Notification.Name {
    static let didCreateNewTracker = Notification.Name("didCreateNewTracker")
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
