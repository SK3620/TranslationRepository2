//
//  PagingPhraseWordViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/27.
//

import Parchment
import UIKit

class PagingPhraseWordViewController: UIViewController {
    @IBOutlet private var pagingView: UIView!

    var tabBarController1: TabBarController!

    var phraseWordViewController: PhraseWordViewController!
    var secondPhraseWordViewController: SecondPhraseWordViewController!
    var thirdPhraseWordViewController: ThirdPhraseWordViewController!
    var allPhraseWordViewController: AllPhraseWordViewController!

    var rightBarButtonItems: [UIBarButtonItem]!

    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPagingViewController()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        //       settings for navigationController and navigationbar
        if self.tabBarController1 != nil {
            self.settingsForNavigationControllerAndBar()
        }
    }

    private func settingsForNavigationControllerAndBar() {
        self.tabBarController1.setStringToNavigationItemTitle4()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
        self.tabBarController1?.navigationItem.rightBarButtonItems = [createFolderBarButtonItem]
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        self.tabBarController1?.createFolder()
    }

    // settings for paging view
    func setPagingViewController() {
        let phraseWordViewController = storyboard?.instantiateViewController(withIdentifier: "phraseWord") as! PhraseWordViewController
        self.phraseWordViewController = phraseWordViewController
        phraseWordViewController.tabBarController1 = self.tabBarController1
        phraseWordViewController.studyViewController = self.studyViewController
        phraseWordViewController.pagingPhraseWordViewController = self

        let secondPhraseWordViewController = storyboard?.instantiateViewController(withIdentifier: "secondPhraseWord") as! SecondPhraseWordViewController
        self.secondPhraseWordViewController = secondPhraseWordViewController
        self.secondPhraseWordViewController.tabBarController1 = self.tabBarController1
        secondPhraseWordViewController.studyViewController = self.studyViewController
        secondPhraseWordViewController.pagingPhraseWordViewController = self

        let thirdPhraseWordViewController = storyboard?.instantiateViewController(withIdentifier: "thirdPhraseWord") as! ThirdPhraseWordViewController
        self.thirdPhraseWordViewController = thirdPhraseWordViewController
        thirdPhraseWordViewController.tabBarController1 = self.tabBarController1
        thirdPhraseWordViewController.studyViewController = self.studyViewController
        thirdPhraseWordViewController.pagingPhraseWordViewController = self

        let allPhraseWordViewController = storyboard?.instantiateViewController(withIdentifier: "allPhraseWord") as! AllPhraseWordViewController
        self.allPhraseWordViewController = allPhraseWordViewController
        allPhraseWordViewController.tabBarController1 = self.tabBarController1
        allPhraseWordViewController.studyViewController = self.studyViewController
        allPhraseWordViewController.pagingPhraseWordViewController = self

        phraseWordViewController.title = "星０"
        secondPhraseWordViewController.title = "星０.５"
        thirdPhraseWordViewController.title = "星１"
        allPhraseWordViewController.title = "全て"

        let pagingViewController = PagingViewController(viewControllers: [allPhraseWordViewController, phraseWordViewController, secondPhraseWordViewController, thirdPhraseWordViewController])

        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
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

    func setItemsOnNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let leftBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.tappedBackBarButtonItem(_:)))
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationItem.standardAppearance = appearence
        self.navigationItem.scrollEdgeAppearance = appearence
        self.title = "お気に入り"
    }

    @objc func tappedBackBarButtonItem(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        if self.studyViewController != nil {
            self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}
