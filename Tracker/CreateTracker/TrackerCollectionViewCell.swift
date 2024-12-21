//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/15/24.
//
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 16
        return label
    }()
    
    // Представление для цвета (с рамкой)
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8 // Скругляем углы для рамки
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3 // Толщина рамки
        view.layer.borderColor = UIColor.white.cgColor // Цвет рамки
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Внутреннее представление (для отступа)
    lazy var innerColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8 // Радиус чуть меньше, чтобы вписываться
        view.layer.masksToBounds = true
        view.backgroundColor = .red // Цвет заливки
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorView)
        colorView.addSubview(innerColorView)
        
        // Настройка констрейнтов для titleLabel и colorView
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 52),
            titleLabel.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            innerColorView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 6),
            innerColorView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -6),
            innerColorView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 6),
            innerColorView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
