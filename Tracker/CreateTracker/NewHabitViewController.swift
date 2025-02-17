//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 10/11/24.
//
import UIKit

final class NewHabitViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var habitsNameTextField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название трекера"
        textField.addTarget(self, action: #selector(checkCreateButton), for: .editingChanged)
        return textField
    }()
    private lazy var habitsNameView: UIView = {
        let view = UIView()
        view.backgroundColor = .customSystemGray
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customSystemGray
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.customRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.customRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .customGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return emojiLabel
        
    }()
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private lazy var colorLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Цвет"
        emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return emojiLabel
    }()
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        return view
    }()
    // MARK: - properties
    private let emojis = [
        "😊", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    private let colors: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    private let tableRowsNames = ["Категория", "Расписание"]
    private var selectedCategory: TrackerCategoryModel?
    private var selectedSchedule = [Weekday]()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    weak var newTrackerDelegate: NewTrackerViewControllerDelegate?
    weak var scheduleDelegate: SelectScheduleItemDelegate?
    
    var trackerCreated: ((TrackerModel) -> Void)?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        setupTableView()
        setupCollections()
    }
    // MARK: - Override functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - Selectors
    @objc
    private func didTapCreateButton() {
        guard let text = habitsNameTextField.text else { return }
        guard let color = selectedColor else { return }
        guard let emoji = selectedEmoji else { return }
        guard let categoryName = selectedCategory?.title else { return }
        if !selectedSchedule.isEmpty {
            let newTracker = TrackerModel(id: UUID(),
                                          name: text,
                                          color: color,
                                          emoji: emoji,
                                          schedule: selectedSchedule,
                                          type: .habbit)
            newTrackerDelegate?.didTabCreateButton(categoryTitle: categoryName, trackerToAdd: newTracker)
            navigationController?.popViewController(animated: true)
        }
    }
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
        newTrackerDelegate?.didTabCancelButton()
    }
    @objc
    private func checkCreateButton() {
        guard let text = habitsNameTextField.text else { return }
        guard let _ = selectedCategory else { return }
        guard let _ = selectedColor else { return }
        guard let _ = selectedEmoji else { return }
        if !text.isEmpty && !selectedSchedule.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .customBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .customGray
        }
    }
    // MARK: - Private functions
    private func setupCollections() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        updateCollectionViewHeights()
    }
    private func updateCollectionViewHeights() {
        let itemHeight: CGFloat = 52
        let itemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5

        let emojiRows = ceil(CGFloat(emojis.count) / itemsPerRow)
        let colorRows = ceil(CGFloat(colors.count) / itemsPerRow)
        
        let emojiHeight = emojiRows * itemHeight + max(emojiRows - 1, 0) * interItemSpacing
        let colorHeight = colorRows * itemHeight + max(colorRows - 1, 0) * interItemSpacing
        
        emojiCollectionView.heightAnchor.constraint(equalToConstant: emojiHeight).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: colorHeight).isActive = true
    }
    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func setupUserInterface() {
        view.backgroundColor = .white
        
        view.addSubview(topLabel)
        setupTopLabelConstraints()
        
        view.addSubview(habitsNameView)
        setupHabitsNameViewConstraints()
        
        habitsNameView.addSubview(habitsNameTextField)
        setupHabitsNameTextFieldConstraints()
        habitsNameTextField.delegate = self
        
        view.addSubview(tableView)
        setupTableViewConstraints()
        
        view.addSubview(cancelButton)
        setupCancelButtonConstraints()
        
        view.addSubview(createButton)
        setupCreateButtonConsraints()
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        setupScrollViewConstraints()
        
        scrollContentView.addSubview(emojiLabel)
        scrollContentView.addSubview(emojiCollectionView)
        scrollContentView.addSubview(colorLabel)
        scrollContentView.addSubview(colorCollectionView)
        setupScrollElementsConstrints()
    }
    private func selectedScheduleString() -> String {
        guard !selectedSchedule.isEmpty else { return "" }
        
        let weekdayShortNames: [Weekday: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]
        selectedSchedule.sort { $0.rawValue < $1.rawValue }
        let shortNames = selectedSchedule.compactMap { weekdayShortNames[$0] }
        return shortNames.joined(separator: ", ")
    }
    // MARK: - Contraints
    private func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)
        ])
        
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    private func setupCreateButtonConsraints() {
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4)
        ])
    }
    private func setupCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4)
        ])
    }
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: habitsNameView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    private func setupTopLabelConstraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    private func setupHabitsNameTextFieldConstraints() {
        habitsNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            habitsNameTextField.centerYAnchor.constraint(equalTo: habitsNameView.centerYAnchor),
            habitsNameTextField.leadingAnchor.constraint(equalTo: habitsNameView.leadingAnchor, constant: 16),
            habitsNameTextField.trailingAnchor.constraint(equalTo: habitsNameView.trailingAnchor, constant: -16),
            habitsNameTextField.topAnchor.constraint(equalTo: habitsNameView.topAnchor),
            habitsNameTextField.bottomAnchor.constraint(equalTo: habitsNameView.bottomAnchor)
        ])
    }
    private func setupHabitsNameViewConstraints() {
        habitsNameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            habitsNameView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitsNameView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitsNameView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            habitsNameView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    private func setupScrollElementsConstrints() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 0),
            emojiLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -16)
        ])
    }
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "optionCell")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory?.title ?? ""
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .customGray
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = selectedScheduleString()
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .customGray
        }

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .customSystemGray
        return cell
    }
}
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            habitsNameTextField.resignFirstResponder()
            let categoriesVC = CategoriesViewController()
            categoriesVC.delegate = self
            categoriesVC.modalPresentationStyle = .popover
            present(categoriesVC, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            habitsNameTextField.resignFirstResponder()
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.modalPresentationStyle = .popover
            present(scheduleVC, animated: true, completion: nil)
        }
    }
}
extension NewHabitViewController: CategoriesViewControllerDelegate {
    func updateSelectedCategory(_ category: TrackerCategoryModel) {
        selectedCategory = category
        tableView.reloadData()
        checkCreateButton()
    }
}

extension NewHabitViewController: SelectScheduleItemDelegate {
    func didSelectScheduleItem(_ selectedDays: [Weekday]) {
        selectedSchedule = selectedDays
        tableView.reloadData()
        checkCreateButton()
    }
}

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? TrackerCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.titleLabel.text = emojis[indexPath.row]
            cell.colorView.isHidden = true
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? TrackerCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.innerColorView.backgroundColor = colors[indexPath.row]
            cell.titleLabel.isHidden = true
            cell.colorView.isHidden = false
            return cell
        }
        return UICollectionViewCell()
    }
}

extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        
        cell.titleLabel.backgroundColor = .customLightGray
        
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.row]
            cell.colorView.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
        }
        checkCreateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.backgroundColor = .white
        cell?.colorView.layer.borderColor = UIColor.white.cgColor
        checkCreateButton()
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
