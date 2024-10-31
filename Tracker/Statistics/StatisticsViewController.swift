//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 31/10/24.
//
import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .customBlack
        return label
    }()
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Private functions
    private func setupUserInterface() {
        view.addSubview(statisticLabel)
        setupStatisticLabelConstraints()
    }
    // MARK: - Contraints
    private func setupStatisticLabelConstraints() {
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticLabel.heightAnchor.constraint(equalToConstant: 41),
            statisticLabel.widthAnchor.constraint(equalToConstant: 254)
        ])
    }
}
