//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 10/11/24.
//
import UIKit

final class CreateTrackerViewController: UIViewController {
    weak var mainScreenViewController: MainScreenViewController?
    // MARK: - lazy properties (UI Elements)
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярные событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    // MARK: - Selectors
    @objc
    private func habitButtonTapped() {
        guard let mainScreenVC = mainScreenViewController else { return }

        let mainScreenViewController = mainScreenVC.newHabitViewController
        
//        if let navigationController = self.navigationController {
//            navigationController.pushViewController(mainScreenViewController, animated: true)
//        } else {
//            mainScreenViewController.modalPresentationStyle = .pageSheet
//            present(mainScreenViewController, animated: true) {
//            }
//        }
    }
    @objc
    private func irregularEventButtonTapped() {
        guard let mainScreenVC = mainScreenViewController else { return }

        let mainScreenViewController = mainScreenVC.newIrregularEventViewController
        if let navigationController = self.navigationController {
            navigationController.pushViewController(mainScreenViewController, animated: true)
        } else {
            mainScreenViewController.modalPresentationStyle = .pageSheet
            present(mainScreenViewController, animated: true) {
            }
        }
    }
    // MARK: - Private functions
    private func setupUserInterface() {
        view.backgroundColor = .white
        
        view.addSubview(label)
        setupLabelConstraints()
        
        view.addSubview(habitButton)
        setupHabitButtonConstraints()
        
        view.addSubview(irregularEventButton)
        setupIrregularEventButtonConstraints()
    }
    // MARK: - Contraints
    private func setupLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    private func setupHabitButtonConstraints() {
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    private func setupIrregularEventButtonConstraints() {
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
        ])
    }
}
