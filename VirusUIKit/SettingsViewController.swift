//
//  SettingsViewController.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // UI Elements
    private let groupSizeLabel = UILabel()
    private let groupSizeTextField = UITextField()
    private let infectionFactorLabel = UILabel()
    private let infectionFactorTextField = UITextField()
    private let periodLabel = UILabel()
    private let periodTextField = UITextField()
    private let columnsLabel = UILabel()
    private let columnsTextField = UITextField()
    private let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Настройки симуляции"
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        // Group Size
        groupSizeLabel.text = "Group Size:"
        view.addSubview(groupSizeLabel)
        
        groupSizeTextField.borderStyle = .roundedRect
        groupSizeTextField.keyboardType = .numberPad
        groupSizeTextField.text = "1500"
        view.addSubview(groupSizeTextField)
        
        // Infection Factor
        infectionFactorLabel.text = "Infection Factor:"
        view.addSubview(infectionFactorLabel)
        
        infectionFactorTextField.borderStyle = .roundedRect
        infectionFactorTextField.keyboardType = .numberPad
        infectionFactorTextField.text = "3"
        view.addSubview(infectionFactorTextField)
        
        // Period
        periodLabel.text = "Period:"
        view.addSubview(periodLabel)
        
        periodTextField.borderStyle = .roundedRect
        periodTextField.keyboardType = .numberPad
        periodTextField.text = "1"
        view.addSubview(periodTextField)
        
        // Columns
        columnsLabel.text = "Columns:"
        view.addSubview(columnsLabel)
        
        columnsTextField.borderStyle = .roundedRect
        columnsTextField.keyboardType = .numberPad
        columnsTextField.text = "10"
        view.addSubview(columnsTextField)
        
        // Start Button
        startButton.setTitle("Start Simulation", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    private func setupConstraints() {
        // Set up UI elements to use Auto Layout
        [groupSizeLabel, groupSizeTextField, infectionFactorLabel, infectionFactorTextField, periodLabel, periodTextField, columnsLabel, columnsTextField, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Group Size
        NSLayoutConstraint.activate([
            groupSizeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            groupSizeTextField.topAnchor.constraint(equalTo: groupSizeLabel.bottomAnchor, constant: 10),
            groupSizeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupSizeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Infection Factor
        NSLayoutConstraint.activate([
            infectionFactorLabel.topAnchor.constraint(equalTo: groupSizeTextField.bottomAnchor, constant: 20),
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            infectionFactorTextField.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor, constant: 10),
            infectionFactorTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infectionFactorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Period
        NSLayoutConstraint.activate([
            periodLabel.topAnchor.constraint(equalTo: infectionFactorTextField.bottomAnchor, constant: 20),
            periodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            periodTextField.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: 10),
            periodTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            periodTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Columns
        NSLayoutConstraint.activate([
            columnsLabel.topAnchor.constraint(equalTo: periodTextField.bottomAnchor, constant: 20),
            columnsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            columnsTextField.topAnchor.constraint(equalTo: columnsLabel.bottomAnchor, constant: 10),
            columnsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            columnsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Start Button
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: columnsTextField.bottomAnchor, constant: 40),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc private func startButtonTapped() {
        print("startButtonTapped called")
        guard let groupSizeText = groupSizeTextField.text, let groupSize = Int(groupSizeText), groupSize > 0 else {
            print("groupSize problem")
            showAlert()
            return
        }
        
        guard let infectionFactorText = infectionFactorTextField.text, let infectionFactor = Int(infectionFactorText), infectionFactor > 0 else {
            print("infectionFactor problem")
            showAlert()
            return
        }
        
        guard let periodText = periodTextField.text, let period = Double(periodText), period > 0 else {
            print("period problem")
            showAlert()
            return
        }
        
        guard let columnsText = columnsTextField.text, let columns = Int(columnsText), columns > 0 else {
            print("columns problem")
            showAlert()
            return
        }
        
        guard let navController = self.navigationController else {
            print("navigationController problem")
            showAlert()
            return
        }

        let simulationViewController = SimulationViewController(groupSize: groupSize, infectionFactor: infectionFactor, period: period, columns: columns)
        navController.pushViewController(simulationViewController, animated: true)
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Please enter valid input for all fields.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
}
