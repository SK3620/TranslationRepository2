//
//  CustomHeaderFooterView.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.
//

import UIKit
import SVProgressHUD

protocol SingleAccordionTableViewHeaderFooterViewDelegate: AnyObject {
    func singleAccordionTableViewHeaderFooterView(_ header: CustomHeaderFooterView, section: Int)
}


class CustomHeaderFooterView: UITableViewHeaderFooterView {
//    セクションヘッダーのタップ検知はどのセクションをタップしたかわかるようにする必要があるので section: Int を保持させるためにカスタムの UITableViewHeaderFooterView を作ります。
    weak var delegate: SingleAccordionTableViewHeaderFooterViewDelegate?
    @IBOutlet weak var inputDataLabel: UILabel!
    var section = 0
   
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    
    //    このセクションには多分、指定された（タップされた？）セクションの情報が入ってくる。
    
    override func awakeFromNib() {
        contentView.backgroundColor = .systemBackground
        inputDataLabel.numberOfLines = 0;
        
        let image1 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "arrowtriangle.down", withConfiguration: image1)
        self.button.setImage(image2, for: .normal)
        
       changeIcon()
        
        print("確認16 awakeFromNibが呼ばれた")
    }
    
//    ここでdelegateメソッドを実行（ここでは引数に値を指定してあげることで呼び出している）
//    要するにここは呼び出しだけであって、func (){ 中身 }　の中身の実際の処理は別のところで記述している。
    @IBAction func didTap (_ sender: Any) {
        print("確認16 ボタンがタップされた")
        delegate?.singleAccordionTableViewHeaderFooterView(self, section: self.section)
       
    
    }
    
    @IBAction func button2Action(_ sender: Any) {
        print("ボタン押下")
        let image5 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image6 = UIImage(systemName: "checkmark", withConfiguration: image5)
        self.button2.setImage(image6, for: .normal)
        
      
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: changeIcon)
    }
    
    func changeIcon(){
        let image3 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image4 = UIImage(systemName: "doc.text", withConfiguration: image3)
        self.button2.setImage(image4, for: .normal)
        
    }
}




