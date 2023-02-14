//
//  SecondMemoForStudyViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/14.
//

import UIKit

class SecondMemoForStudyViewController: UIViewController {
    @IBOutlet private var memoTextView: UITextView!
    
    var folderNameString: String!
    var translationId: Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
