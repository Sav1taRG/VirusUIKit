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
        addDoneButtonOnKeyboard()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Group Size
        groupSizeLabel.text = "Group Size:"
        view.addSubview(groupSizeLabel)
        
        groupSizeTextField.delegate = self
        groupSizeTextField.placeholder = "Enter group size"
        groupSizeTextField.borderStyle = .roundedRect
        groupSizeTextField.keyboardType = .numberPad
        groupSizeTextField.text = ""
        view.addSubview(groupSizeTextField)
        
        // Infection Factor
        infectionFactorLabel.text = "Infection Factor:"
        view.addSubview(infectionFactorLabel)
        
        infectionFactorTextField.delegate = self
        infectionFactorTextField.placeholder = "Enter infection factor 1 - 8"
        infectionFactorTextField.borderStyle = .roundedRect
        infectionFactorTextField.keyboardType = .numberPad
        infectionFactorTextField.text = ""
        view.addSubview(infectionFactorTextField)
        
        // Period
        periodLabel.text = "Timer:"
        view.addSubview(periodLabel)
        
        periodTextField.delegate = self
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
                constant: 16),
            
            groupSizeTextField.topAnchor.constraint(
                equalTo: groupSizeLabel.bottomAnchor,
                constant: 10),
            groupSizeTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            groupSizeTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16)
        ])
        
        // Infection Factor
        NSLayoutConstraint.activate([
            infectionFactorLabel.topAnchor.constraint(
                equalTo: groupSizeTextField.bottomAnchor,
                constant: 20),
            infectionFactorLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            
            infectionFactorTextField.topAnchor.constraint(
                equalTo: infectionFactorLabel.bottomAnchor,
                constant: 10),
            infectionFactorTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            infectionFactorTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16)
        ])
        
        // Timer
        NSLayoutConstraint.activate([
            periodLabel.topAnchor.constraint(
                equalTo: infectionFactorTextField.bottomAnchor,
                constant: 20),
            periodLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            
            
            periodTextField.topAnchor.constraint(
                equalTo: periodLabel.bottomAnchor,
                constant: 10),
            periodTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            periodTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20)
        ])
        
        // Start Button
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(
                equalTo: periodTextField.bottomAnchor,
                constant: 30),
            startButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            startButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createToolbar(withReturnTitle title: String) -> UIToolbar {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, doneButton]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        return doneToolbar
    }

    private func addDoneButtonOnKeyboard() {
        groupSizeTextField.inputAccessoryView = createToolbar(withReturnTitle: "Next")
        infectionFactorTextField.inputAccessoryView = createToolbar(withReturnTitle: "Next")
        periodTextField.inputAccessoryView = createToolbar(withReturnTitle: "Done")
    }

    @objc private func doneButtonAction() {
        if groupSizeTextField.isFirstResponder {
            infectionFactorTextField.becomeFirstResponder()
        } else if infectionFactorTextField.isFirstResponder {
            periodTextField.becomeFirstResponder()
        } else if periodTextField.isFirstResponder {
            periodTextField.resignFirstResponder()
        }
    }

    // MARK: - Private Methods
    
    private func validateInput() -> (groupSize: Int, infectionFactor: Int, period: Double)? {
            return InputValidator.validate(groupSize: groupSizeTextField.text, infectionFactor: infectionFactorTextField.text, period: periodTextField.text)
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

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == groupSizeTextField {
            infectionFactorTextField.becomeFirstResponder()
        } else if textField == infectionFactorTextField {
            periodTextField.becomeFirstResponder()
        } else if textField == periodTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

