//
//  StatCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Nikitash on 3/2/25.
//
import UIKit

final class StatCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "StatisticCollectionViewCell"
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 7
        
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .customBlack
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .customBlack
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .customWhite
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        setupBorder()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatCollectionViewCell {
    
    // MARK: - setupCell
    
    func setupCell(with data: StatModel) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }
    
    // MARK: - setupBorder
    
    func setupBorder() {
        gradientBorder(
            width: 1,
            colors: [.blue, .green, .red],
            startPoint: .unitCoordinate(.left),
            endPoint: .unitCoordinate(.right),
            andRoundCornersWithRadius: 12
        )
    }
    
    // MARK: - setupLayout
    
    private func setupLayout() {
        [
            titleLabel,
            descriptionLabel,
        ].forEach {
            mainStackView.addArrangedSubview($0)
        }
        [mainStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.mainInset),
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.mainInset),
            mainStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.mainInset),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.mainInset),
        ])
    }
}

// MARK: - Constants

private extension StatCollectionViewCell {
    enum Constants {
        static let mainInset: CGFloat = 12
    }
}
