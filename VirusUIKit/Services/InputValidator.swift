//
//  InputValidator.swift
//  VirusUIKit
//
//  Created by Roman on 11.05.2023.
//

class InputValidator {
    static func validate(groupSize: String?, infectionFactor: String?, period: String?) -> (Int, Int, Double)? {
        guard let groupSizeText = groupSize,
              let groupSize = Int(groupSizeText),
              groupSize > 0 else {
            return nil
        }
        
        guard let infectionFactorText = infectionFactor,
              let infectionFactor = Int(infectionFactorText),
              infectionFactor > 0 else {
            return nil
        }
        
        guard let periodText = period,
              let period = Double(periodText),
              period > 0 else {
            return nil
        }
        
        return (groupSize, infectionFactor, period)
    }
}
