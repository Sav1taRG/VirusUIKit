//
//  PersonCell.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class PersonCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonCell"
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with person: Person) {
        switch person.healthStatus {
        case .healthy:
            label.text = String(HealthStatus.healthy.rawValue)
            label.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        case .infected:
            label.text = String(HealthStatus.infected.rawValue)
            label.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }
    }
    
    private func setupLabel() {
        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
