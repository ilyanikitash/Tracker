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
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    }()
    // MARK: - properties
    var categories: [TrackerCategoryModel] = []
    var completedTrackers: [TrackerRecordModel] = []
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        setupNavigationBar()
    }
    // MARK: - Selectors
    @objc private func plusButtonTapped() {
        
    }
    // MARK: - Private functions
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = plusButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func setupUserInterface() {
        setupDatePickerConstraints()
        
        view.addSubview(startImageView)
        setupStartImageViewConstraints()
        
        view.addSubview(startLabel)
        setupStartLabelConstraints()
    }
    // MARK: - Contraints
    private func setupDatePickerConstraints() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 90),
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
}
