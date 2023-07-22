//
//  Mood.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import Foundation

enum Mood: CaseIterable{
    case happy, sad, soHappy, soSad, amazed, angry, huft, cryNotCry, suprised, foody, sick, silly, sleepy, umm, clean, drink, eat, paintt, read
    
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
        case .clean:
            return "clean"
        case .drink:
            return "drink"
        case .eat:
            return "eat"
        case .paintt:
            return "paintt"
        case .read:
            return "read"
        }
    }
}

