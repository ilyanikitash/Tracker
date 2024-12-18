//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/7/24.
//
import UIKit

protocol SelectScheduleItemDelegate: AnyObject {
    func didSelectScheduleItem(_ selectedDays: [Weekday])
}

final class ScheduleViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .customBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .customSystemGray
        return tableView
    }()
    // MARK: - properties
    private var selectedDays = Set<Weekday>()
    private let daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    weak var delegate: SelectScheduleItemDelegate?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    // MARK: - Selectors
    @objc
    private func doneButtonTapped() {
        delegate?.didSelectScheduleItem(Array(selectedDays))
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Private functions
    private func setupTableView() {
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(topLabel)
        setupTopLabelConstraints()
        
        view.addSubview(doneButton)
        setupDoneButtonConstraints()
        
        view.addSubview(tableView)
        setupTableViewConstraints()
    }
    // MARK: - Contraints
    private func setupTopLabelConstraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    private func setupDoneButtonConstraints() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchTableViewCell else {
            return UITableViewCell()
        }
        let weekdayIndex = (indexPath.row + 1)
        guard let weekday = Weekday(rawValue: weekdayIndex) else { return UITableViewCell() }
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        cell.switchControl.tag = weekday.rawValue
        cell.switchControl.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
        cell.switchControl.isOn = selectedDays.contains(weekday)
        cell.selectionStyle = .none
        cell.backgroundColor = .customSystemGray
        
        return cell
    }
    
    @objc
    private func didChangeSwitch(_ sender: UISwitch) {
        guard let day = Weekday(rawValue: sender.tag) else {
            return
        }
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
