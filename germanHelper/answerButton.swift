//
//  answerButton.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 07/12/2021.
//

import UIKit

class answerButton: UIButton {
	
	override init(frame: CGRect){
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setup()
	}
	
	func setup() {
		self.clipsToBounds = true
		self.layer.cornerRadius = 10
		
		self.setTitleColor(.label, for: .normal)
		self.setTitleColor(.gray, for: .highlighted)
		
		//backgroundColor = isHighlighted ? .systemGray3 : .systemGray6
		backgroundColor = .systemGray6
		
		self.titleLabel?.numberOfLines = 0
	}
	
}
