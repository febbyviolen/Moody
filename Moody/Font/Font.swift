//
//  Font.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/17.
//

import Foundation
import UIKit

var languageCode = ""

class Font {
    let fontName = languageCode == "kor" ? "omyu_pretty" : "Dosis"
    
    var titleSize: UIFont {
        return UIFont(name: fontName, size: languageCode == "kor" ? 30.0 : 28.0)!
    }
    
    var title2Size: UIFont {
        return UIFont(name: fontName, size: languageCode == "kor" ? 20.0 : 18.0)!
    }
    
    var subSize: UIFont {
        return UIFont(name: fontName, size: languageCode == "kor" ? 17.0 : 15.0)!
    }
    
    var sub2Size: UIFont {
        
        return UIFont(name: fontName, size: languageCode == "kor" ? 15.0 : 13.0)!
    }
    
    var dateSize: UIFont {
        return UIFont(name: fontName, size: languageCode == "kor" ? 12.0 : 10.0)!
    }
}
