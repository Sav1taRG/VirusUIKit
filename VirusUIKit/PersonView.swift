//
//  PersonView.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class PersonView: UIView {
    private(set) var person: Person

    init(person: Person) {
        self.person = person
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 8
        backgroundColor = person.healthStatus == .healthy ? .green : .red
    }
    
    func update(with person: Person) {
        self.person = person
        backgroundColor = person.healthStatus == .healthy ? .green : .red
    }
}
