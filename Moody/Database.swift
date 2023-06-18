//
//  Database.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/18.
//

import Foundation
import FirebaseFirestore

class Database {
    
    let userData: [String: Any] = [
        "name" : "admin"
    ]
    let formatter = DateFormatter()
    
    var userDocRef = Firestore.firestore().collection("users").document("admin")
    
    func getDiaryDetailData(date: Date){
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        userDocRef = userDocRef.collection(year).document("\(month).\(day)")
        
        userDocRef.getDocument { (document, error) in
            if let error = error {
                
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let sticker = data?["sticker"] as? [String], let story = data?["story"] as? String {
                        print("sticker: \(sticker)")
                        print("story: \(story)")
                    }
                    
                } else {
                    print("Document doesnt exist ")
                }
            }
        }
        
    }
    
}
