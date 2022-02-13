//
//  AppIconService.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 13/02/2022.
//

import UIKit

class AppIconService
{
    let application = UIApplication.shared
    
    enum AppIcon: String
    {
        case primaryAppIcon
        case lightModeIcon
        case darkModeIcon
    }
    
    func changeAppIcon(to appIcon: AppIcon)
    {
        application.setAlternateIconName(appIcon.rawValue) { error in
            print(error ?? "Nothing Wrong")
        }
    }
}
