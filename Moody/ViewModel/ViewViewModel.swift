//
//  ViewViewModel.swift
//  Moody
//
//  Created by Ebbyy on 2023/08/03.
//

import Foundation

class ViewViewModel {
    
    private var userdefault = UserDefaults.standard
    private var fb = Firebase()
    private var dateModel = DateFormatModel()
    
    //when sending receipt? purchase ID to server but interrupted the value is still true
    //then send the receipt again to the server
    func checkInterruptedReceipt() {
        if userdefault.string(forKey: "needSendToServer") == "true" {
            if let url = Bundle.main.appStoreReceiptURL,
               let data = try? Data(contentsOf: url) {
                let receiptBase64 = data.base64EncodedString()
                // Send to server
                self.fb.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                    self.userdefault.set("false", forKey: "needSendToServer")
                })
            }
        }
    }
    
    //DATE
    func isMaybeFirstLineOfCalendar(date: Date) -> Date? {
        let dateStr = dateModel.getDateString(date: date)
        
        if dateStr == "01" || dateStr == "02" || dateStr == "03" || dateStr == "04" || dateStr == "05" || dateStr == "06" {
            let month = dateModel.getLongMonthString(date: date)
            let year = dateModel.getYearString(date: date)
            return dateModel.getFullDateDate(from: "\(year).\(month).\(15)")
        }
        else {return nil}
    }
    
}
