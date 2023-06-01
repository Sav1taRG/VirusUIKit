//
//  SimulationViewController.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class SimulationViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let groupSize: Int
    private let infectionFactor: Int
    private let period: Double
    private let columns: Int
    private let healthyLabel = UILabel()
    private let infectedLabel = UILabel()
    private var people: [Person]
    private var healthyCount: Int
    private var infectedCount: Int
    private var collectionView: UICollectionView!
    private var scale: CGFloat = 1.0
    
    // MARK: - Initializers
    
    init(groupSize: Int, infectionFactor: Int, period: Double, columns: Int = 10) {
        self.groupSize = groupSize
        self.infectionFactor = infectionFactor
        self.period = period
        self.columns = columns
        
        let initialPeople = Array(repeating: Person(healthStatus: .healthy), count: groupSize)
        self.people = initialPeople
        self.healthyCount = groupSize
        self.infectedCount = 0
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Simulation"
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupHealthyInfectedLabels()
        setupTimer()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupHealthyInfectedLabels() {
        // Healthy Label
        healthyLabel.translatesAutoresizingMaskIntoConstraints = false
        healthyLabel.text = "Healthy: \(healthyCount)"
        healthyLabel.textColor = .label
        healthyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        healthyLabel.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        healthyLabel.layer.cornerRadius = 8
        healthyLabel.layer.masksToBounds = true
        healthyLabel.textAlignment = .center
        healthyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(healthyLabel)
        
        // Infected Label
        infectedLabel.translatesAutoresizingMaskIntoConstraints = false
        infectedLabel.text = "Infected: \(infectedCount)"
        infectedLabel.textColor = .label
        infectedLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        infectedLabel.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        infectedLabel.layer.cornerRadius = 8
        infectedLabel.layer.masksToBounds = true
        infectedLabel.textAlignment = .center
        infectedLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(infectedLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Healthy and Infected Labels
            healthyLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10),
            healthyLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            healthyLabel.widthAnchor.constraint(equalToConstant: 140),
            
            infectedLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10),
            infectedLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            infectedLabel.widthAnchor.constraint(equalToConstant: 140),
            // Collection View
            collectionView.topAnchor.constraint(
                equalTo: infectedLabel.bottomAnchor,
                constant: 10),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let topPadding: CGFloat = 50
        collectionView = UICollectionView(
            frame: CGRect(
                x: view.bounds.origin.x,
                y: view.bounds.origin.y + topPadding,
                width: view.bounds.width,
                height: view.bounds.height - topPadding),
            collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            PersonCell.self,
            forCellWithReuseIdentifier: PersonCell.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        
    }
    
    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
            self?.spreadInfection()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        infectPerson(at: indexPath.item)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    // MARK: - Infection logic methods
    
    private func infectPerson(at index: Int) {
        guard people[index].healthStatus == .healthy else { return }
        people[index].healthStatus = .infected
        infectedCount += 1
        healthyCount -= 1
        updateHealthyInfectedLabels()
    }
    
    private func updateHealthyInfectedLabels() {
        healthyLabel.text = "Healthy: \(healthyCount)"
        infectedLabel.text = "Infected: \(infectedCount)"
    }
    
    private func spreadInfection() {
        DispatchQueue.global(qos: .background).async {
            var newInfected = Set<Int>()
            for (index, person) in self.people.enumerated() {
                if person.healthStatus == .infected {
                    let neighbors = self.getNeighbors(of: index)
                    let healthyNeighbors = neighbors.filter { self.people[$0].healthStatus == .healthy }
                    if healthyNeighbors.isEmpty { continue }
                    
                    let numberOfInfections = min(self.infectionFactor, healthyNeighbors.count)
                    let infectedNeighbors = healthyNeighbors.shuffled().prefix(numberOfInfections)
                    
                    newInfected.formUnion(infectedNeighbors)
                }
            }
            
            DispatchQueue.main.async {
                newInfected.forEach { index in
                    self.infectPerson(at: index)
                }
                self.collectionView.reloadItems(at: newInfected.map { IndexPath(item: $0, section: 0) })
            }
        }
    }
    
    private func getNeighbors(of index: Int) -> [Int] {
        let coordinates = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        let row = index / columns
        let column = index % columns
        var neighbors = [Int]()
        
        for coordinate in coordinates {
            let newRow = row + coordinate.0
            let newColumn = column + coordinate.1
            
            if newRow >= 0 && newRow < groupSize / columns && newColumn >= 0 && newColumn < columns {
                let neighborIndex = newRow * columns + newColumn
                
                if (row == newRow && abs(column - newColumn) == 1) || (column == newColumn && abs(row - newRow) == 1) {
                    neighbors.append(neighborIndex)
                }
            }
        }
        
        return neighbors
    }
}
// MARK: - UICollectionViewDataSource
extension SimulationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.reuseIdentifier, for: indexPath) as! PersonCell
        cell.configure(with: people[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SimulationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = CGFloat(columns - 1) * 10
        let baseWidth = (screenWidth - totalSpacing) / CGFloat(columns)
        let width = baseWidth * scale
        let height = width
        return CGSize(width: width, height: height)
    }
}
