//
//  PagingViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/09.
//

import Alamofire
import Firebase
import Parchment
import UIKit

class SecondPagingViewController: UIViewController {
    @IBOutlet private var pagingView: UIView!

    private var searchBar: UISearchBar!

    var secondTabBarController: SecondTabBarController!
    var postData: PostData!
    var savedTextView_text: String = ""
    var pagingViewController: PagingViewController!
    var searchViewController: SearchViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.setPagingViewController()
    }

    private func setPagingViewController() {
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

        let navigationController13 = storyboard?.instantiateViewController(withIdentifier: "NC13") as! UINavigationController
        let searchViewController = navigationController13.viewControllers[0] as! SearchViewController
        searchViewController.secondPagingViewController = self
        self.searchViewController = searchViewController

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
        navigationController13.title = "検索"

//        pagingViewControllerのインスタンス生成
        let pagingViewController = PagingViewController(viewControllers: [navigationController13, navigationController3, navigationController4, navigationController5, navigationController6, navigationController7, navigationController8, navigationController9, navigationController10, navigationController11, navigationController12])

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
        self.pagingViewController = pagingViewController

        pagingViewController.select(index: 1)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setRightBarButtonItem()
    }

    private func setRightBarButtonItem() {
        self.secondTabBarController.rightBarButtonItems = []
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.secondTabBarController.tabBar.isHidden = false
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        let searchBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(self.tappedSearchBarButtonItem(_:)))
        self.secondTabBarController.rightBarButtonItems.append(rightBarButtonItem)
        self.secondTabBarController.rightBarButtonItems.append(searchBarButtonItem)
        self.secondTabBarController.title = "タイムライン"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.navigationItem.rightBarButtonItems = self.secondTabBarController.rightBarButtonItems

        if Auth.auth().currentUser == nil {
            rightBarButtonItem.isEnabled = false
            searchBarButtonItem.isEnabled = false
        } else {
            rightBarButtonItem.isEnabled = true
            searchBarButtonItem.isEnabled = true
        }
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @objc func tappedSearchBarButtonItem(_: UIBarButtonItem) {
        if self.navigationController!.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.systemGray6
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

            // place a search bar on navigation bar
            self.setupSearchBarOnNavigationBar()
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    private func setupSearchBarOnNavigationBar() {
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "検索する"
            searchBar.tintColor = UIColor.gray
            searchBar.keyboardType = UIKeyboardType.default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
            self.searchBar.enablesReturnKeyAutomatically = true
            self.setDoneOnKeyBoard()
        }
    }

    private func setDoneOnKeyBoard() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTapped() {
        self.searchBar.endEditing(true)
    }

    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        let NCForPostViewContoller = storyboard!.instantiateViewController(withIdentifier: "Post") as! UINavigationController
        let postViewController = NCForPostViewContoller.viewControllers[0] as! PostViewController
        postViewController.secondPagingViewController = self
        postViewController.savedTextView_text = self.savedTextView_text

        present(NCForPostViewContoller, animated: true, completion: nil)
    }

    // called in other view controllers
    // screen transition to CommentSectionViewController
    func segue() {
        self.performSegue(withIdentifier: "ToCommentSection", sender: nil)
    }

    // called in other view controllers
    // screen transition to OthersProfileViewController
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
}

extension SecondPagingViewController: UISearchBarDelegate {
    // pass the entered text in the search bar to SearchViewController
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.pagingViewController.select(index: 0, animated: true)
        searchBar.endEditing(true)
        if let searchBarText = self.searchBar.text {
            self.searchViewController.shouldExcuteGetDocumentMethod = true
            self.searchViewController.getDocuments(searchBarText: searchBarText)
        }
    }
}
