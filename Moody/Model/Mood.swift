//
//  Mood.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import Foundation

enum Mood: CaseIterable{
    case happy, sad, soHappy, soSad, amazed, angry, huft, cryNotCry, suprised, foody, shy, sick, silly, sleepy, umm, netflix, youtube, song, paint
    
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
        case .song:
            return "song"
        case .paint:
            return "paint"
        }
    }
}
