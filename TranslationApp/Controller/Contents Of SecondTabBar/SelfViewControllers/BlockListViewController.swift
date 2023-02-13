//
//  BlockListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/01/24.
//

import Firebase
import SVProgressHUD
import UIKit

class BlockListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var blockListcollectionView: UICollectionView!

    var blockArray: [BlockData] = [] {
        didSet {
            self.blockListcollectionView.reloadData()
        }
    }

    var listener: ListenerRegistration?

    var profileViewController: ProfileViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForCollectionView()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if let profileViewController = self.profileViewController {
            profileViewController.blockListViewController = self
        }

        guard let user = Auth.auth().currentUser else {
            self.blockArray = []
            SVProgressHUD.dismiss()
            self.blockListcollectionView.reloadData()
            return
        }
        BlockUnblock.getDocumentOfBlockedUser(user: user, listener: self.listener) { result in
            switch result {
            case let .failure(error):
                print("データの取得に失敗しました\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
            case let .success(blockArray):
                SVProgressHUD.dismiss()
                self.blockArray = blockArray
                self.blockListcollectionView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.listener?.remove()
    }

    private func settingsForCollectionView() {
        let nib = UINib(nibName: "CollectionViewCellForBlockList", bundle: nil)
        self.blockListcollectionView.register(nib, forCellWithReuseIdentifier: "CustomCell")
        self.blockListcollectionView.delegate = self
        self.blockListcollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.blockListcollectionView.collectionViewLayout = layout
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.blockArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CollectionViewCellForBlockList
        cell.setProfileImageViewAndUserNameLabel(blockData: self.blockArray[indexPath.row])

        cell.buttonOnProfileImageView.addTarget(self, action: #selector(self.tappedButtonOnProfileImageView(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let horizontalSpace: CGFloat = 20
        let cellSize: CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    @objc func tappedButtonOnProfileImageView(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.blockListcollectionView)
        let indexPath = self.blockListcollectionView.indexPathForItem(at: point)

        let blockData = self.blockArray[indexPath!.row]

        self.configureUIAlert(blockData: blockData)
    }

    private func configureUIAlert(blockData: BlockData) {
        let alert = UIAlertController(title: "'\(blockData.userName!)'さんをブロック解除しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "解除", style: .destructive, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "'\(blockData.userName!)'さんをブロック解除しました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                BlockUnblock.unblockUser(blockData: blockData)
            }
        }))
        self.present(alert, animated: true)
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
