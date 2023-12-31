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
    
    //MARK: USERS INFO
    func anonymSign(completion: @escaping () -> Void) {
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
                completion()
            }
        }
    }
    
    func deleteUser(user: String, date: Date){
        let docRef = userDocRef
        
        let data : [String: Any] = [
            "deleted" : "True", 
            "date" : date.description
        ]
        
        docRef.setData(data, merge: false) { error in
            if let _ = error {
//                print("\(error.localizedDescription)")
            } else {
//                print("success")
            }
        }
    }
    
    //MARK: EDITING DIARY DATA
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
            if let error = error {
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
    
    //MARK: TRANSFERING DATA
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
        
        let docRef = userDocRef.collection("subscription")
        let destDocRef = Firestore.firestore().collection("users").document(idToken).collection("subscription")
        
        docRef.getDocuments { document, err in
            if let _ = err {
//                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in document!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    if let premiumPass = data["premiumPass"] as? String, let ID = data["premiumPassID"] {
                        
                        let data : [String: Any] = [
                            "premiumPass" : premiumPass,
                            "premiumPassID" : ID
                        ]
                        
                        destDocRef.document("subscriptionInfo").setData(data, merge: true) { error in
                            if let _ = error {
                                completion()
                            } else {
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
        
        let docRef = userDocRef.collection("subscription")
        let destDocRef = Firestore.firestore().collection("users").document(idToken).collection("subscription")
        
        docRef.getDocuments { document, err in
            if let _ = err {
//                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in document!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    if let premiumPass = data["premiumPass"] as? String, let ID = data["premiumPassID"] {
                        
                        let data : [String: Any] = [
                            "premiumPass" : premiumPass,
                            "premiumPassID" : ID
                        ]
                        
                        destDocRef.document("subscriptionInfo").setData(data, merge: true) { error in
                            if let _ = error {
                                completion()
                            } else {
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        completion()
    }
    
    //MARK: SUBSCRIPTION
    func getSubscriptionInfo() {
        let docRef = userDocRef.collection("subscription")
        
        docRef.getDocuments { document, err in
            if let _ = err {
                self.userDefault.set("false", forKey: "premiumPass")
            } else {
                for document in document!.documents {
                    let data = document.data()
                    if let premiumPass = data["premiumPass"] as? String {
                        if premiumPass == "true" {
                            self.userDefault.set("true", forKey: "premiumPass")
                        } else {
                            self.userDefault.set("false", forKey: "premiumPass")
                        }
                    }
                    
                }
            }
        }
    }
    
    func saveSubscriptionInfo(premiumID: String, completion: @escaping () -> Void) {
        let docRef = userDocRef.collection("subscription").document("subsciptionInfo")
        
        let data : [String: Any] = [
            "premiumPass" : "true",
            "premiumPassID" : "\(premiumID)",
            "date" : Date().description
        ]
        
        docRef.setData(data, merge: false) { error in
            if let _ = error {
//                print("\(error.localizedDescription)")
                completion()
            } else {
//                print("success")
                completion()
            }
        }
    }
}
