//
//  MainScreenViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 30/10/24.
//
import UIKit

final class MainScreenViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .customBlack
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        return searchBar
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
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    // MARK: - Selectors
    @objc private func plusButtonTapped() {
        
    }
    // MARK: - Private functions
    private func setupUserInterface() {
        view.addSubview(plusButton)
        setupPlusButtonConstraints()
        
        view.addSubview(trackerLabel)
        setupTrackerLabelConstraints()
        
        view.addSubview(searchBar)
        setupSearchBarConstraints()
        
        view.addSubview(startImageView)
        setupStartImageViewConstraints()
        
        view.addSubview(startLabel)
        setupStartLabelConstraints()
        
        view.addSubview(datePicker)
        setupDatePickerConstraints()
    }
    // MARK: - Contraints
    private func setupPlusButtonConstraints() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6)
        ])
    }
    
    private func setupTrackerLabelConstraints() {
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 1),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func setupSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            searchBar.widthAnchor.constraint(equalToConstant: 343),
//            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7)
        ])
    }
    
    private func setupStartImageViewConstraints() {
        startImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startImageView.heightAnchor.constraint(equalToConstant: 80),
            startImageView.widthAnchor.constraint(equalToConstant: 80),
            startImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupStartLabelConstraints() {
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startLabel.topAnchor.constraint(equalTo: startImageView.bottomAnchor, constant: 8),
            startLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupDatePickerConstraints() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.centerXAnchor.constraint(equalTo: plusButton.centerXAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
