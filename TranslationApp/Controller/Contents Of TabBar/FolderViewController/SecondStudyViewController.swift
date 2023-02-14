//
//  SecondStudyViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/14.
//

import UIKit

class SecondStudyViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForCollectionView()
    }

    private func settingsForCollectionView() {
        let nib = UINib(nibName: "CollectionViewCellForSecondStudy", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.collectionViewLayout = layout

//        セルの初期サイズを指定
        self.collectionViewFlowLayout.estimatedItemSize = CGSize(width: self.collectionView.frame.width / 2, height: self.collectionView.frame.height / 3)

        self.collectionView.reloadData()
    }
}

extension SecondStudyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        print("実行")
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("実行")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    /*
        func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
            let cellSizeWidth: CGFloat = self.view.bounds.width - 20
            let cellSizeHeight: CGFloat = self.view.bounds.width / 2
            return CGSize(width: cellSizeWidth, height: cellSizeHeight)
        }
     */
}
