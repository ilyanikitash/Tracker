//
//  SwitchTableViewCell.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/11/24.
//
import UIKit

final class SwitchTableViewCell: UITableViewCell {
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .customBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
