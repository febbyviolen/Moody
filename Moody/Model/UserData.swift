//
//  UserData.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/04.
//

import Foundation
import FirebaseAuth
import FirebaseCore

class UserData {
    static let shared = UserData()
    
    var user : User!
    
    func setUser(newUser: User) {
        user = newUser
    }
    
    func getUser() -> User {
        return user
    }
}
