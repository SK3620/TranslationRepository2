//
//  PagingViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/09.
//

import Firebase
import Parchment
import UIKit

class SecondPagingViewController: UIViewController {
    @IBOutlet var pagingView: UIView!

    var secondTabBarController: SecondTabBarController!
    var postData: PostData!
    var savedTextView_text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationController3 = storyboard?.instantiateViewController(withIdentifier: "NC3") as! UINavigationController
        let timeLineViewController = navigationController3.viewControllers[0] as! TimeLineViewController
        timeLineViewController.secondPagingViewController = self

        let navigationController4 = storyboard?.instantiateViewController(withIdentifier: "NC4") as! UINavigationController
        let correctViewController = navigationController4.viewControllers[0] as! CorrectViewController
        correctViewController.secondPagingViewController = self

        let navigationController5 = storyboard?.instantiateViewController(withIdentifier: "NC5") as! UINavigationController
        let howToLearnViewController = navigationController5.viewControllers[0] as! HowToLearnViewController
        howToLearnViewController.secondPagingViewController = self

        let navigationController6 = storyboard?.instantiateViewController(withIdentifier: "NC6") as! UINavigationController
        let wordViewController = navigationController6.viewControllers[0] as! WordViewController
        wordViewController.secondPagingViewController = self

        let navigationController7 = storyboard?.instantiateViewController(withIdentifier: "NC7") as! UINavigationController
        let grammerViewController = navigationController7.viewControllers[0] as! GrammerViewController
        grammerViewController.secondPagingViewController = self

        let navigationController8 = storyboard?.instantiateViewController(withIdentifier: "NC8") as! UINavigationController
        let conversationViewController = navigationController8.viewControllers[0] as! ConversationViewController
        conversationViewController.secondPagingViewController = self

        let navigationController9 = storyboard?.instantiateViewController(withIdentifier: "NC9") as! UINavigationController
        let listeningViewController = navigationController9.viewControllers[0] as! ListeningViewController
        listeningViewController.secondPagingViewController = self

        let navigationController10 = storyboard?.instantiateViewController(withIdentifier: "NC10") as! UINavigationController
        let pronunciationViewController = navigationController10.viewControllers[0] as! PronunciationViewController
        pronunciationViewController.secondPagingViewController = self

        let navigationController11 = storyboard?.instantiateViewController(withIdentifier: "NC11") as! UINavigationController
        let certificationViewController = navigationController11.viewControllers[0] as! CertificationViewController
        certificationViewController.secondPagingViewController = self

        let navigationController12 = storyboard?.instantiateViewController(withIdentifier: "NC12") as! UINavigationController
        let etcViewController = navigationController12.viewControllers[0] as! EtcViewController
        etcViewController.secondPagingViewController = self

        navigationController3.title = "全て"
        navigationController4.title = "修正/教えて"
        navigationController5.title = "学習法"
        navigationController6.title = "単語"
        navigationController7.title = "文法"
        navigationController8.title = "英会話"
        navigationController9.title = "リスニング"
        navigationController10.title = "発音"
        navigationController11.title = "資格試験"
        navigationController12.title = "その他"

//        pagingViewControllerのインスタンス生成
        let pagingViewController = PagingViewController(viewControllers: [navigationController3, navigationController4, navigationController5, navigationController6, navigationController7, navigationController8, navigationController9, navigationController10, navigationController11, navigationController12])

//        Adds the specified view controller as a child of the current view controller.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
//        Called after the view controller is added or removed from a container view controller.
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.leadingAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingViewController.view.topAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.topAnchor).isActive = true
        pagingViewController.selectedTextColor = .black
        pagingViewController.textColor = .systemGray4
        pagingViewController.indicatorColor = .systemBlue
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 50)
        pagingViewController.menuItemLabelSpacing = 0
    }

//    viewWillAppearだけでsetRightBarButton()を呼ぶと、rightBarButtonItemが表示されない
//    viewWillAppearとviewDidAppearで呼ぶと、表示される
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.setRightBarButtonItem()
    }

    func setRightBarButtonItem() {
        self.secondTabBarController.rightBarButtonItems = []
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.secondTabBarController.tabBar.isHidden = false
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        self.secondTabBarController.rightBarButtonItems.append(rightBarButtonItem)
        self.secondTabBarController.title = "タイムライン"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.navigationItem.rightBarButtonItems = self.secondTabBarController.rightBarButtonItems

        if Auth.auth().currentUser == nil {
            rightBarButtonItem.isEnabled = false
        } else {
            rightBarButtonItem.isEnabled = true
        }
    }

    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        print("バーボタンタップされた")
        let NCForPostViewContoller = storyboard!.instantiateViewController(withIdentifier: "Post") as! UINavigationController
        let postViewController = NCForPostViewContoller.viewControllers[0] as! PostViewController
        postViewController.secondPagingViewController = self
        postViewController.savedTextView_text = self.savedTextView_text

        present(NCForPostViewContoller, animated: true, completion: nil)
    }

    func segue() {
        self.performSegue(withIdentifier: "ToCommentSection", sender: nil)
    }

    func segueToOthersProfile() {
        self.performSegue(withIdentifier: "ToOthersProfile", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToCommentSection" {
            let commentSectionViewController = segue.destination as! CommentSectionViewController
            commentSectionViewController.secondTabBarController = self.secondTabBarController
            commentSectionViewController.postData = self.postData
        } else if segue.identifier == "ToOthersProfile" {
            let othersProfileViewController = segue.destination as! OthersProfileViewController
            othersProfileViewController.postData = self.postData
            othersProfileViewController.secondTabBarController = self.secondTabBarController
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
