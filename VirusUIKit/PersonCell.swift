//
//  PersonCell.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class PersonCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonCell"
    
    private var personView: PersonView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with person: Person) {
        personView?.removeFromSuperview()
        let view = PersonView(person: person)
        view.frame = contentView.bounds
        contentView.addSubview(view)
        personView = view
    }
}
