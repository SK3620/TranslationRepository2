//
//  CustomCell2.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15.
//

import UIKit
import RealmSwift

protocol ToEditViewContollerDelegate: AnyObject {
    func ToEditViewContoller()
}


class CustomCell2: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    
    
    @IBOutlet weak var checkMarkButton: UIButton!
    
    

    
    
//    weak var delegate: ToEditViewContollerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    @IBAction func editButtonAction(_ sender: Any) {
//
//        self.delegate?.ToEditViewContoller()
//    }
    
    func setData(_ recordArrFilter: Record){
        
        if recordArrFilter.folderName != "" {
            label1.text = recordArrFilter.folderName
        } else {
            label1.text = " "
        }
        
        if recordArrFilter.number != "" {
            label2.text = recordArrFilter.number
        } else {
            label2.text = " "
        }
        
        if recordArrFilter.times != "" {
            label3.text = recordArrFilter.times
        } else {
            label3.text = " "
        }
        
        if recordArrFilter.nextReviewDate != "" {
            label4.text = recordArrFilter.nextReviewDate
        } else {
            label4.text = " "
        }
        
        if recordArrFilter.memo != "" {
            label5.text = recordArrFilter.memo
        } else {
            label5.text = " "
        }
        
    }
    
}




