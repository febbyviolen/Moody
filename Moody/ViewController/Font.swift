//
//  Font.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/17.
//

import Foundation
import UIKit

class Font {
    let fontName = "Dongle-Regular"
    
    var titleSize: UIFont {
        return UIFont(name: fontName, size: 30.0)!
    }
    
    var subSize: UIFont {
        return UIFont(name: fontName, size: 27.0)!
    }
    
    var sub2Size: UIFont {
        return UIFont(name: fontName, size: 25.0)!
    }
    
    var dateSize: UIFont {
        return UIFont(name: fontName, size: 22.0)!
    }
}
