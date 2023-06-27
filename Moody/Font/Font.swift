//
//  Font.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/17.
//

import Foundation
import UIKit

class Font {
    let fontName = "omyu_pretty"
    
    var titleSize: UIFont {
        return UIFont(name: fontName, size: 30.0)!
    }
    
    var title2Size: UIFont {
        return UIFont(name: fontName, size: 20.0)!
    }
    
    var subSize: UIFont {
        return UIFont(name: fontName, size: 17.0)!
    }
    
    var sub2Size: UIFont {
        return UIFont(name: fontName, size: 15.0)!
    }
    
    var dateSize: UIFont {
        return UIFont(name: fontName, size: 12.0)!
    }
}
