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
        
        setupCollectionView()
        setupHealthyInfectedLabels()
        setupTimer()
    }
    
    private func setupHealthyInfectedLabels() {
        // Healthy Label
        healthyLabel.translatesAutoresizingMaskIntoConstraints = false
        healthyLabel.text = "Здоровые: \(healthyCount)"
        healthyLabel.textColor = .label // Текст будет черным на светлом фоне, или белым на темном фоне
        healthyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold) // Установка размера и жирности шрифта
        healthyLabel.backgroundColor = .green // Изменение цвета фона лейбла
        healthyLabel.layer.cornerRadius = 8 // Закругление углов
        healthyLabel.layer.masksToBounds = true // Обрезание фона по закругленным углам
        view.addSubview(healthyLabel)
        
        // Infected Label
        infectedLabel.translatesAutoresizingMaskIntoConstraints = false
        infectedLabel.text = "Зараженные: \(infectedCount)"
        infectedLabel.textColor = .label
        infectedLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        infectedLabel.backgroundColor = .red
        infectedLabel.layer.cornerRadius = 8
        infectedLabel.layer.masksToBounds = true
        view.addSubview(infectedLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Healthy and Infected Labels
            healthyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            healthyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            infectedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infectedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Collection View
            collectionView.topAnchor.constraint(equalTo: infectedLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
    }
    
    
    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
            self?.spreadInfection()
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
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = CGFloat(columns - 1) * 10
        let baseWidth = (screenWidth - totalSpacing) / CGFloat(columns)
        let width = baseWidth * scale
        let height = width
        return CGSize(width: width, height: height)
    }

    
    // MARK: - Infection logic
    
    private func infectPerson(at index: Int) {
        guard people[index].healthStatus == .healthy else { return }
        people[index].healthStatus = .infected
        infectedCount += 1
        healthyCount -= 1
        updateHealthyInfectedLabels()
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
                    let healthyNeighbors = neighbors.filter { self.people[$0].healthStatus == .healthy }
                    if healthyNeighbors.isEmpty { continue }
                    
                    // Выбираем случайное количество заражаемых соседей
                    let randomCount = Int.random(in: 0...min(healthyNeighbors.count, self.infectionFactor))
                    let infectedNeighbors = healthyNeighbors.shuffled().prefix(randomCount)
                    
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
        
        for rowOffset in -1..<2 {
            for columnOffset in -1..<2 {
                if rowOffset == 0 && columnOffset == 0 { continue }
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
