//
//  Mood.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import Foundation

enum Mood: CaseIterable{
    case happy, sad, amazed, angry, cryNotCry, foody, huft, shy, sick, silly, sleepy, soHappy, soSad, suprised, umm, netflix, youtube
    
    var imgName: String {
        switch self {
        case .angry:
            return "angry"
        case .foody:
            return "foody"
        case .happy:
            return "happy"
        case .huft:
            return "huft"
        case .sad:
            return "sad"
        case .shy:
            return "shy"
        case .silly:
            return "silly"
        case .sleepy:
            return "sleepy"
        case .soHappy:
            return "soHappy"
        case .soSad:
            return "soSad"
        case .suprised:
            return "suprised"
        case .umm:
            return "umm"
        case .amazed:
            return "amazed"
        case .cryNotCry:
            return "cryNotCry"
        case .sick:
            return "sick"
        case .netflix:
            return "netflix"
        case .youtube:
            return "youtube"
        }
    }
}
