//
//  wordCell.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 01/02/2022.
//

import UIKit

class wordCell: UICollectionViewCell {
    @IBOutlet var wordButton: answerButton!

    
    @IBAction func buttonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("clickedWord"), object: nil, userInfo: ["tag" : self.tag])
    }
}
