//
//  Database.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/18.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Firebase {
    
    let formatter = DateFormatter()
    let userDefault = UserDefaults.standard
    var userID: String {
        return userDefault.string(forKey: "userID") ?? ""
//        return "admin"
    }
    
    var userDocRef: DocumentReference {
        return Firestore.firestore().collection("users").document(userID)
    }
    
    func anonymSign() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
//                print("\(error.localizedDescription)")
            } else {
                guard let user = authResult?.user else {
                    // User object is nil
                    return
                }
                let userID = user.uid
                self.userDefault.set(userID, forKey: "userID")
                
            }
        }
    }
    
    func getDiaryDetailData(date: Date, completion: @escaping ([String]?, String) -> Void){
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        let docRef = userDocRef.collection(year).document("\(month).\(day)")
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let sticker = data?["sticker"] as? [String], let story = data?["story"] as? String {
//                        print("sticker: \(sticker)")
//                        print("story: \(story)")
                        completion(sticker, story)
                    }
                    
                } else {
//                    print("Document doesnt exist ")
                }
            }
        }
        
    }
    
    func addDiary(date: Date, sticker: [String], story: String) {
        let data : [String: Any] = [
            "sticker" : sticker,
            "story" : story
        ]
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        let docRef = userDocRef.collection(year).document("\(month).\(day)")
        
        docRef.setData(data, merge: true) { error in
            if let error = error {
//                print("\(error.localizedDescription)")
            } else {
//                print("ok")
            }
        }
    }
}
