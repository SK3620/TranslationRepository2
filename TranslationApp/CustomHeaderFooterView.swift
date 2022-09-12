//
//  CustomHeaderFooterView.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.
//

import UIKit

protocol SingleAccordionTableViewHeaderFooterViewDelegate: AnyObject {
    func singleAccordionTableViewHeaderFooterView(_ header: CustomHeaderFooterView, section: Int)
}


class CustomHeaderFooterView: UITableViewHeaderFooterView {
//    セクションヘッダーのタップ検知はどのセクションをタップしたかわかるようにする必要があるので section: Int を保持させるためにカスタムの UITableViewHeaderFooterView を作ります。
    weak var delegate: SingleAccordionTableViewHeaderFooterViewDelegate?
    @IBOutlet weak var inputDataLabel: UILabel!
    var section = 0
//    このセクションには多分、指定された（タップされた？）セクションの情報が入ってくる。
    
    override func awakeFromNib() {
        contentView.backgroundColor = .systemBackground
        inputDataLabel.numberOfLines = 0;
        
        print("確認16 awakeFromNibが呼ばれた")
    }
    
//    ここでdelegateメソッドを実行（ここでは引数に値を指定してあげることで呼び出している）
//    要するにここは呼び出しだけであって、func (){ 中身 }　の中身の実際の処理は別のところで記述している。
    @IBAction func didTap (_ sender: Any) {
        delegate?.singleAccordionTableViewHeaderFooterView(self, section: section)
        print("確認16 ボタンがタップされた")
    
    }
}


