//
//  FilterViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 2/27/25.
//
import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterChanged(to newFilter: FilterCases)
}

final class FilterViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters", comment: "")
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .customSystemGray
        return tableView
    }()
    // MARK: - Properties
    weak var delegate: FilterViewControllerDelegate?
    private let userAppSettingsStorage = UserAppSettingStorage.shared
    private var selectedFilter: FilterCases?
    // MARK: - ViewDidLoad and Lifecycle
    init(selectedFilter: FilterCases?, delegate: FilterViewControllerDelegate) {
        self.delegate = delegate
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUserInterface()
    }
    //MARK: - Actions
    @objc private func cellDidTapped(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let selectedFilter = FilterCases.allCases[indexPath.row]
            print("DID SELECT FILTER: \(selectedFilter)")
            delegate?.filterChanged(to: selectedFilter)
            dismiss(animated: true)
        }
    }
    // MARK: - Private functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewTrackerTableViewCell.self, forCellReuseIdentifier: "CategoryTableViewCell")
    }
    private func setupUserInterface() {
        view.backgroundColor = .customWhite
        
        view.addSubview(topLabel)
        setupTopLabelContraints()
        
        view.addSubview(tableView)
        setupTableViewContraints()
    }
    private func setupTopLabelContraints() {
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    private func setupTableViewContraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}
    //MARK: - TableView Delegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
    //MARK: - TableView DataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterCases.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? NewTrackerTableViewCell
        guard let cell else { return UITableViewCell() }
        cell.backgroundColor = .customBackground
        cell.image.image = UIImage(named: "DoneImage")
        if FilterCases.allCases[indexPath.row] == userAppSettingsStorage.selectedFilter {
            cell.image.isHidden = false
        } else {
            cell.image.isHidden = true
        }
        let currentFilter = FilterCases.allCases[indexPath.row]
        cell.buttonText.text = currentFilter.title
        cell.button.addTarget(self, action: #selector(cellDidTapped(_:)), for: .touchUpInside)
        return cell
    }
}

