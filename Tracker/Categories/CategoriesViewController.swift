//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 10/11/24.
//
import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func updateSelectedCategory(_ category: TrackerCategoryModel)
}

final class CategoriesViewController: UIViewController {
    // MARK: - private properties
    private let mainScreenVC = MainScreenViewController()
    // MARK: - lazy properties (UI Elements)
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .customBlack
        return label
    }()
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StartImage")
        return imageView
    }()
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .customBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    weak var delegate: CategoriesViewControllerDelegate?
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        setupTableView()
    }
    // MARK: - Selectors
    @objc
    private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        newCategoryVC.modalPresentationStyle = .popover
        present(newCategoryVC, animated: true, completion: nil)
    }
    @objc
    private func categoryDidTapped(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let cell = tableView.cellForRow(at: indexPath) as? NewTrackerTableViewCell
            cell?.image.isHidden = false
            delegate?.updateSelectedCategory(cell?.category ?? TrackerCategoryModel(title: "Важное", trackers: []))
            dismiss(animated: true)
        }
    }
    // MARK: - Private functions
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewTrackerTableViewCell.self, forCellReuseIdentifier: "CategoryTableViewCell")
    }
    private func setupUserInterface() {
        view.backgroundColor = .white
        
        view.addSubview(topLabel)
        setupLabelConstraints()
        
        view.addSubview(addCategoryButton)
        setupAddCategoryButtonConstraints()
    
        if mainScreenVC.categories.count == 0 {
            view.addSubview(stubImage)
            setupStubImageConstraints()
            
            view.addSubview(stubLabel)
            setupStubLabelConstraints()
        } else {
            view.addSubview(tableView)
            setupTableViewConstraints()
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
    private func setupStubImageConstraints() {
        stubImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    private func setupStubLabelConstraints() {
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stubLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stubLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    private func setupAddCategoryButtonConstraints() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -114)
        ])
    }
}
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainScreenVC.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? NewTrackerTableViewCell
        cell?.image.image = UIImage(named: "DoneImage")
        cell?.image.isHidden = true
        cell?.category = mainScreenVC.categories[indexPath.row]
        cell?.buttonText.text = mainScreenVC.categories[indexPath.row].title
        cell?.button.addTarget(self, action: #selector(categoryDidTapped(_:)), for: .touchUpInside)
        guard let cell else { return UITableViewCell()}
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CategoriesViewController: NewCategoryViewControllerDelegate {
    func addCategory(with name: String) {
        mainScreenVC.categories.append(TrackerCategoryModel(title: name, trackers: []))
        tableView.reloadData()
    }
}
