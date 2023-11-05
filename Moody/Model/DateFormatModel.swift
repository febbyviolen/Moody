//
//  DateFormatModel.swift
//  Moody
//
//  Created by Ebbyy on 2023/08/03.
//

import Foundation

class DateFormatModel {
    
    let longMonthDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    let dateDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    let yearDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    let fullDateDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MMMM.dd"
        return formatter
    }()
    
    func getLongMonthString(date: Date) -> String{
        return longMonthDateFormat.string(from: date)
    }
    
    func getDateString (date: Date) -> String{
        return dateDateFormat.string(from: date)
    }
    
    func getYearString(date: Date) -> String{
        return yearDateFormat.string(from: date)
    }
    
    func getFullDateString(date: Date) -> String{
        return fullDateDateFormat.string(from: date)
    }
    
    func getFullDateDate(from date: String) -> Date? {
        return fullDateDateFormat.date(from: date)
    }
    
}
