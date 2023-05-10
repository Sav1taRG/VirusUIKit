//
//  Person.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import Foundation

enum HealthStatus {
    case healthy, infected
}

struct Person: Identifiable {
    let id = UUID()
    var healthStatus: HealthStatus
}
