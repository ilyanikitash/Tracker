//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 15/11/24.
//
import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func addCategory(with name: String)
}

final class NewCategoryViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .customGray
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .customSystemGray
        view.layer.cornerRadius = 16
        return view
    }()
    private let mainScreenVC = MainScreenViewController()
    weak var delegate: NewCategoryViewControllerDelegate?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    private func setupUserInterface() {
        view.backgroundColor = .white
        
        view.addSubview(topLabel)
        setupLabelConstraints()
        
        view.addSubview(readyButton)
        setupReadyButtonConstraints()
        
        view.addSubview(textFieldView)
        setupTextFieldViewConstraints()
        
        textFieldView.addSubview(textField)
        setupTextFieldConstraints()
        textField.delegate = self
    }
    // MARK: - Selectors
    @objc
    private func textFieldDidChange() {
        updateButtonState()
    }
    @objc
    private func readyButtonTapped() {
        if let text = textField.text, !text.isEmpty {
            print(mainScreenVC.categories)
            delegate?.addCategory(with: text)
            dismiss(animated: true)
        }
    }
    // MARK: - Private functions
    private func updateButtonState() {
        if let text = textField.text, !text.isEmpty {
            readyButton.isEnabled = true
            readyButton.backgroundColor = .customBlack
        } else {
            readyButton.isEnabled = false
            readyButton.backgroundColor = .customGray
        }
    }
    // MARK: - Contraints
    private func setupLabelConstraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    private func setupReadyButtonConstraints() {
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    private func setupTextFieldViewConstraints() {
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textFieldView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldView.heightAnchor.constraint(equalToConstant: 75),
            textFieldView.widthAnchor.constraint(equalToConstant: 343)
        ])
    }
    private func setupTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalTo: textFieldView.heightAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 16)
        ])
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
