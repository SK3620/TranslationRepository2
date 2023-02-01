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
        self.getDocumentOfBlockedUser(user: user)
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

    private func getDocumentOfBlockedUser(user: User) {
        SVProgressHUD.show(withStatus: "データを取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).whereField("blockedBy", isEqualTo: user.uid).order(by: "blockedDate", descending: true)
        self.listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
                SVProgressHUD.dismiss()
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("からでした")
                    SVProgressHUD.dismiss()
                    self.blockArray = []
                    self.blockListcollectionView.reloadData()
                    return
                }
                self.blockArray = []
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    self.blockArray.append(BlockData(document: queryDocumentSnapshot))
                }
                SVProgressHUD.dismiss()
            }
        }
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
                self.unblockUser(blockData: blockData)
            }
        }))
        self.present(alert, animated: true)
    }

    private func unblockUser(blockData: BlockData) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let blockRef = Firestore.firestore().collection(FireBaseRelatedPath.blocking).document(blockData.documentId)
        blockRef.delete { error in
            if let error = error {
                print("エラー\(error)")
            } else {
                print("削除成功")
                self.unBlockUser2(blockData: blockData, user: user)
                self.unBlockUser3(blockData: blockData, user: user)
            }
        }
    }

    private func unBlockUser2(blockData: BlockData, user: User) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: blockData.blockedUser!).whereField("blockedBy", arrayContains: user.uid)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(queryDocumentSnapshot.documentID)
                    let updatedValue = FieldValue.arrayRemove([user.uid])
                    postsRef.updateData(["blockedBy": updatedValue])
                }
            }
        }
    }

    private func unBlockUser3(blockData: BlockData, user: User) {
        let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: blockData.blockedUser!).whereField("blockedBy", arrayContains: user.uid)
        commentsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("エラー\(error)")
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(queryDocumentSnapshot.documentID)
                    let updatedValue = FieldValue.arrayRemove([user.uid])
                    commentsRef.updateData(["blockedBy": updatedValue])
                }
            }
        }
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
