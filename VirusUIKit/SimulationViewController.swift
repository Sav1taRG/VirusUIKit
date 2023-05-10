//
//  SimulationViewController.swift
//  VirusUIKit
//
//  Created by Roman Golubinko on 10.05.2023.
//

import UIKit

class SimulationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Симуляция"
        view.backgroundColor = .systemBackground
        
        setupHealthyInfectedLabels()
        setupCollectionView()
        setupTimer()
        setupPinchGesture()
    }
    
    private func setupHealthyInfectedLabels() {
        healthyLabel.translatesAutoresizingMaskIntoConstraints = false
        healthyLabel.text = "Здоровые: \(healthyCount)"
        view.addSubview(healthyLabel)
        
        infectedLabel.translatesAutoresizingMaskIntoConstraints = false
        infectedLabel.text = "Зараженные: \(infectedCount)"
        view.addSubview(infectedLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Healthy and Infected Labels
        NSLayoutConstraint.activate([
            healthyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            healthyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            infectedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infectedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.reuseIdentifier)
        
        view.addSubview(collectionView)
    }
    
    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
            self?.spreadInfection()
        }
    }
    
    //MARK: - Pinch Gestures Setup
    private func setupPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
            let newSize = CGSize(width: flowLayout.itemSize.width * gesture.scale,
                                 height: flowLayout.itemSize.height * gesture.scale)
            flowLayout.itemSize = newSize
            flowLayout.invalidateLayout()
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.reuseIdentifier, for: indexPath) as! PersonCell
        cell.configure(with: people[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        infectPerson(at: indexPath.item)
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - CGFloat(columns - 1) * 10) / CGFloat(columns)
        return CGSize(width: width, height: width)
    }
    
    // MARK: - Infection logic
    
    private func infectPerson(at index: Int) {
        if people[index].healthStatus == .healthy {
            people[index].healthStatus = .infected
            infectedCount += 1
            healthyCount -= 1
            updateHealthyInfectedLabels()
        }
    }
    
    private func updateHealthyInfectedLabels() {
        healthyLabel.text = "Здоровые: \(healthyCount)"
        infectedLabel.text = "Зараженные: \(infectedCount)"
    }
    
    private func spreadInfection() {
        DispatchQueue.global(qos: .background).async {
            var newInfected = Set<Int>()
            for (index, person) in self.people.enumerated() {
                if person.healthStatus == .infected {
                    let neighbors = self.getNeighbors(of: index)
                    let infectedNeighbors = neighbors.filter { self.people[$0].healthStatus == .healthy }.shuffled().prefix(self.infectionFactor)
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
        let rows = groupSize / columns
        let row = index / columns
        let column = index % columns
        var neighbors = [Int]()
        
        for rowOffset in -1...1 {
            for columnOffset in -1...1 {
                if rowOffset == 0 && columnOffset == 0 {
                    continue
                }
                let newRow = row + rowOffset
                let newColumn = column + columnOffset
                if newRow >= 0 && newRow < rows && newColumn >= 0 && newColumn < columns {
                    neighbors.append(newRow * columns + newColumn)
                }
            }
        }
        
        return neighbors
    }
    
}
