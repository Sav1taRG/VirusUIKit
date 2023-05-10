//
//  SettingsViewController.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let groupSizeLabel = UILabel()
    private let groupSizeTextField = UITextField()
    private let infectionFactorLabel = UILabel()
    private let infectionFactorTextField = UITextField()
    private let periodLabel = UILabel()
    private let periodTextField = UITextField()
    private let startButton = UIButton()
    
    // MARK: - ViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Virus Simulation Settings"
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Group Size
        groupSizeLabel.text = "Group Size:"
        view.addSubview(groupSizeLabel)
        
        groupSizeTextField.placeholder = "Enter group size"
        groupSizeTextField.borderStyle = .roundedRect
        groupSizeTextField.keyboardType = .numberPad
        groupSizeTextField.text = ""
        view.addSubview(groupSizeTextField)
        
        // Infection Factor
        infectionFactorLabel.text = "Infection Factor:"
        view.addSubview(infectionFactorLabel)
        
        infectionFactorTextField.placeholder = "Enter infection factor"
        infectionFactorTextField.borderStyle = .roundedRect
        infectionFactorTextField.keyboardType = .numberPad
        infectionFactorTextField.text = ""
        view.addSubview(infectionFactorTextField)
        
        // Period
        periodLabel.text = "Timer:"
        view.addSubview(periodLabel)
        
        periodTextField.placeholder = "Delay in seconds"
        periodTextField.borderStyle = .roundedRect
        periodTextField.keyboardType = .numberPad
        periodTextField.text = ""
        view.addSubview(periodTextField)
        
        // Start Button
        startButton.setTitle("Start Simulation", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
    }
    // MARK: - Setup Constraints
    private func setupConstraints() {
        // Set up UI elements to use Auto Layout
        [groupSizeLabel, groupSizeTextField, infectionFactorLabel, infectionFactorTextField, periodLabel, periodTextField, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        // Group Size
        NSLayoutConstraint.activate([
            groupSizeLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20),
            groupSizeLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            
            groupSizeTextField.topAnchor.constraint(
                equalTo: groupSizeLabel.bottomAnchor,
                constant: 10),
            groupSizeTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            groupSizeTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20)
        ])
        
        // Infection Factor
        NSLayoutConstraint.activate([
            infectionFactorLabel.topAnchor.constraint(
                equalTo: groupSizeTextField.bottomAnchor,
                constant: 20),
            infectionFactorLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            
            infectionFactorTextField.topAnchor.constraint(
                equalTo: infectionFactorLabel.bottomAnchor,
                constant: 10),
            infectionFactorTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            infectionFactorTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20)
        ])
        
        // Period
        NSLayoutConstraint.activate([
            periodLabel.topAnchor.constraint(
                equalTo: infectionFactorTextField.bottomAnchor,
                constant: 20),
            periodLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            
            
            periodTextField.topAnchor.constraint(
                equalTo: periodLabel.bottomAnchor,
                constant: 10),
            periodTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            periodTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20)
        ])
        
        // Start Button
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(
                equalTo: periodTextField.bottomAnchor,
                constant: 40),
            startButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20),
            startButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Private Methods
    
    private func validateInput() -> (groupSize: Int, infectionFactor: Int, period: Double)? {
        guard let groupSizeText = groupSizeTextField.text,
              let groupSize = Int(groupSizeText),
              groupSize > 0 else {
            return nil
        }
        
        guard let infectionFactorText = infectionFactorTextField.text,
              let infectionFactor = Int(infectionFactorText),
              infectionFactor > 0 else {
            return nil
        }
        
        guard let periodText = periodTextField.text,
              let period = Double(periodText),
              period > 0 else {
            return nil
        }
        
        return (groupSize, infectionFactor, period)
    }
    
    @objc private func startButtonTapped() {
        guard let input = validateInput(),
              let navController = self.navigationController else {
            showAlert()
            return
        }
        
        let simulationViewController = SimulationViewController(
            groupSize: input.groupSize,
            infectionFactor: input.infectionFactor,
            period: input.period
        )
        navController.pushViewController(simulationViewController, animated: true)
    }
    // MARK: - Alert
    private func showAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Please enter valid input for all fields.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
