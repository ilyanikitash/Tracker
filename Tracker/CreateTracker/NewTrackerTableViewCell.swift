//
//  NewTrackerTableViewCell.swift
//  Tracker
//
//  Created by Ilya Nikitash on 10/11/24.
//
import UIKit

final class NewTrackerTableViewCell: UITableViewCell {
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .customSystemGray
        return button
    }()
    lazy var buttonText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .customBlack
        return label
    }()
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "TableArrow")
        return image
    }()
    
    var category: TrackerCategoryModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        
        button.addSubview(image)
        button.addSubview(buttonText)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.heightAnchor.constraint(equalToConstant: 75)
        ])
        buttonText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonText.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 24),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            image.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
