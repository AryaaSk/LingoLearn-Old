//
//  answerButton.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 07/12/2021.
//

import UIKit

var buttonClickedTag = 0 //acts like a tag

class answerButton: UIButton {
	
	override init(frame: CGRect){
		super.init(frame: frame)
		setup()
        reset()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
        reset()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setup()
	}
    
	func setup() {
		self.clipsToBounds = true
		self.layer.cornerRadius = 10
		
		self.titleLabel?.numberOfLines = 0
	}
    func reset()
    {
        self.titleLabel?.font = .systemFont(ofSize: 22)
        
        self.setTitleColor(.label, for: .normal)
        self.setTitleColor(.gray, for: .highlighted)
        
        //backgroundColor = isHighlighted ? .systemGray3 : .systemGray6
        backgroundColor = .systemGray6
    }
	
}
