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
    var calendar = Calendar.current
    let userDefault = UserDefaults.standard
    var userID: String {
        return userDefault.string(forKey: "userID") ?? ""
    }
    
    var userDocRef: DocumentReference {
        return Firestore.firestore().collection("users").document(userID)
    }
    
    func anonymSign(completion: @escaping () -> Void) {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
//                print("\(error.localizedDescription)")
            } else {
                guard let user = authResult?.user else {
                    // User object is nil
                    return
                }
                UserData.shared.setUser(newUser: user)
                let userID = user.uid
                self.userDefault.set(userID, forKey: "userID")
                completion()
            }
        }
    }
    
    //get data for viewcontroller
    func getDiaryData(date: Date, completion: @escaping ([String], String, String, String) -> Void){
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        
        let docRef = userDocRef.collection("\(year)")
        
        docRef.getDocuments { document, err in
            if let _ = err {
//                print("Error getting documents: \(err)")
            } else {
                for document in document!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let ID = document.documentID // (ex: 2023.06.01
                    if let sticker = data["sticker"] as? [String], let story = data["story"] as? String, let date = data["date"] as? String {
                        completion(sticker, story, date, ID)
                    }
                    
                }
            }
        }
    }
    
    //get user data
    func transferUserData(idToken: String, completion: @escaping () -> Void){
        
        formatter.dateFormat = "yyyy"
        
        var date = Date()
        for i in 0...100 {
            var dateComponents = DateComponents()
            dateComponents.year = -i
            
            if let year = calendar.date(byAdding: dateComponents, to: date) {
                date = year
            }
            let docRef = Firestore.firestore().collection("users").document(userID).collection(formatter.string(from: date))
            let destDocRef = Firestore.firestore().collection("users").document(idToken).collection(formatter.string(from: date))
            
            docRef.getDocuments { document, err in
                if let _ = err {
    //                print("Error getting documents: \(err)")
                    completion()
                } else {
                    for document in document!.documents {
    //                    print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let ID = document.documentID // (ex: 2023.06.01
                        if let sticker = data["sticker"] as? [String], let story = data["story"] as? String, let date = data["date"] as? String {
                            
                            let data : [String: Any] = [
                                "sticker" : sticker,
                                "story" : story,
                                "date" : date
                            ]
                            
                            destDocRef.document(date).setData(data, merge: true) { error in
                                if let _ = error {
                                    completion()
                                } else {
                                }
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        completion()
    }
    
    //get user data
    func transferUserDataNoMerge(idToken: String, completion: @escaping () -> Void){
        
        formatter.dateFormat = "yyyy"
        
        var date = Date()
        for i in 0...100 {
            var dateComponents = DateComponents()
            dateComponents.year = -i
            
            if let year = calendar.date(byAdding: dateComponents, to: date) {
                date = year
            }
            let docRef = Firestore.firestore().collection("users").document(userID).collection(formatter.string(from: date))
            let destDocRef = Firestore.firestore().collection("users").document(idToken).collection(formatter.string(from: date))
            
            docRef.getDocuments { document, err in
                if let _ = err {
    //                print("Error getting documents: \(err)")
                    completion()
                } else {
                    for document in document!.documents {
    //                    print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let ID = document.documentID // (ex: 2023.06.01
                        if let sticker = data["sticker"] as? [String], let story = data["story"] as? String, let date = data["date"] as? String {
                            
                            let data : [String: Any] = [
                                "sticker" : sticker,
                                "story" : story,
                                "date" : date
                            ]
                            
                            destDocRef.document(date).setData(data, merge: false) { error in
                                if let _ = error {
                                    completion()
                                } else {
                                }
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        completion()
    }
    
    func addDiary(date: Date, sticker: [String], story: String) {
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        let docRef = userDocRef.collection("\(year)").document("\(year).\(month).\(day)")
        
        let data : [String: Any] = [
            "sticker" : sticker,
            "story" : story,
            "date" : "\(year).\(month).\(day)"
        ]
        
        docRef.setData(data, merge: true) { error in
            if let _ = error {
//                print("\(error.localizedDescription)")
            } else {
//                print("success")
            }
        }
    }
    
    func deleteDiary(date: Date) {
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        let docRef = userDocRef.collection("\(year)").document("\(year).\(month).\(day)")
        
        docRef.delete() { error in
            if let _ = error {
//                print("\(error.localizedDescription)")
            } else {
//                print("success")
            }
        }
    }
    
    func deleteUser(user: String){
        let docRef = Firestore.firestore().collection("users").document("\(user)")
        docRef.delete() { error in
            if let _ = error {
//                print("\(error.localizedDescription)")
            } else {
//                print("success")
            }
        }
    }
}
