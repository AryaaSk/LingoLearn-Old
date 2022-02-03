//
//  EmptyScreen.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 03/02/2022.
//

import UIKit

class EmptyScreen: UIView {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView()
    {
        let xibView = Bundle.main.loadNibNamed("EmptyScreen", owner: self, options: nil)![0] as! UIView
        xibView.frame = self.bounds
        addSubview(xibView)
    }
}
