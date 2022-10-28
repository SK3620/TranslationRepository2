//
//  ProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import CLImageEditor
import Firebase
import SVProgressHUD
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!

    var image: UIImage?
    var tabBarController1: TabBarController?
    var secondTabBarController: SecondTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .systemGray4

        if let secondTabBarController = self.secondTabBarController {
            let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
            secondTabBarController.navigationItem.rightBarButtonItems = [rightBarButtonItem]
            secondTabBarController.title = "プロフィール"
        }

//        丸いimageView
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
//        画像にデフォルト設定
        self.imageView.image = UIImage(systemName: "person")
        self.imageView.layer.borderColor = UIColor.systemGray5.cgColor
        self.imageView.layer.borderWidth = 1

        self.tableView.dataSource = self
        self.tableView.delegate = self

        let nib = UINib(nibName: "CustomCellForProfile", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        self.title = "プロフィール"
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(self.tappedRightBarButtonItem))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }

    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
//        if Auth.auth().currentUser == nil {
//            loginViewController.logoutButton.isEnabled = false
//        } else {
//            loginViewController.logoutButton.isEnabled = true

        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForProfile
        cell.label1.text = "名前"
        if let user = Auth.auth().currentUser {
            cell.label2.text = user.displayName
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToEditProfile", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToEditProfile" {
            let editProfileViewController = segue.destination as! editProfileViewController
            editProfileViewController.indexPath_row = sender as? Int
        }
    }

//    写真ライブラリを開くボタン
    @IBAction func openLibraryButton(_: Any) {
//        ライブラリを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }

//    写真選択時に呼ばれる
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
//           画像を加工する
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }
    }

    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        editor.dismiss(animated: true, completion: { () in
            self.imageView.image = image
            self.image = image
            self.saveImageToStorage()
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }

    //    画像ファイルをstorageに保存する
    func saveImageToStorage() {
        //        画像をJPEG形式に変換
        let imageData = self.image?.jpegData(compressionQuality: 0.75)
        //        画像の保存場所定義
        let user = Auth.auth().currentUser!
        let imageRef = Storage.storage().reference().child(FireBaseRelatedPath.imagePath).child("\(user.displayName ?? "namelessUser")" + ".jpg")
        SVProgressHUD.show()
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metaData, completion: { _, error in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                return
            }
            SVProgressHUD.dismiss()
        })
    }
}
