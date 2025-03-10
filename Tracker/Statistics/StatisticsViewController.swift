//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Ilya Nikitash on 31/10/24.
//
import UIKit
protocol StatServiceProtocol {
    func getStatistic() -> [StatModel]
}

final class StatisticsViewController: UIViewController {
    // MARK: - lazy properties (UI Elements)
    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistic", comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var statisticCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout?.collectionView?.backgroundColor = .customWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatErrorImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("no_analyze", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //MARK: - properties
    private var statisticData = [StatModel]()
    private let collectionViewParams = UICollectionView.GeometricParams(
        cellCount: 1,
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 12,
        height: 90,
        cellSpacing: 12
    )
    private let statisticService: StatServiceProtocol = StatService()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        setupConstraints()
        setupCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStatistic()
    }
    // MARK: - Private functions
    private func getStatistic() {
        statisticData = statisticService.getStatistic()
        statisticCollectionView.reloadData()
        showPlaceholder(statisticData.isEmpty)
    }
    private func showPlaceholder(_ isShow: Bool) {
        stubLabel.isHidden = !isShow
        stubImageView.isHidden = !isShow
        statisticCollectionView.isHidden = isShow
    }
    private func setupCollectionView() {
        statisticCollectionView.dataSource = self
        statisticCollectionView.delegate = self
        statisticCollectionView.register(
            StatCollectionViewCell.self,
            forCellWithReuseIdentifier: StatCollectionViewCell.identifier
        )
    }
    // MARK: - Contraints
    private func setupConstraints() {
        view.addSubview(statisticLabel)
        view.addSubview(statisticCollectionView)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticLabel.heightAnchor.constraint(equalToConstant: 41),
            statisticLabel.widthAnchor.constraint(equalToConstant: 254),
            
            
            statisticCollectionView.topAnchor.constraint(equalTo: statisticLabel.bottomAnchor, constant: 53),
            statisticCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            statisticCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            statisticCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
}

extension StatisticsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        statisticData.count
    }
    
    // MARK: - SETUP Collection CELLS
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let statisticCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StatCollectionViewCell.identifier,
                for: indexPath
            ) as? StatCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let data = statisticData[indexPath.row]
        
        statisticCell.setupCell(with: data)

        return statisticCell
    }
}

// MARK: - UICollectionViewDelegate

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize
    {
        let availableSpace = collectionView.frame.width - collectionViewParams.paddingWidth
        let cellWidth = availableSpace / collectionViewParams.cellCount
        return CGSize(width: cellWidth, height: collectionViewParams.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets
    {
        UIEdgeInsets(
            top: collectionViewParams.topInset,
            left: collectionViewParams.leftInset,
            bottom: collectionViewParams.bottomInset,
            right: collectionViewParams.rightInset
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewParams.cellSpacing
    }
}

