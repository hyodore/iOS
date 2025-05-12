//
//  Date+Utils.swift
//  Hyodor
//
//  Created by 김상준 on 5/10/25.
//

import Foundation

extension Date {
    func toKoreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: self)
    }

    func toKoreanTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }

    // D-Day 텍스트 계산 함수
    func dDayText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: today, to: target).day ?? 0

        switch diff {
        case 0:
            return "오늘"
        case -1:
            return "어제"
        case 1:
            return "내일"
        case let d where d > 0:
            return "D-\(d)"
        default:
            return "D+\(-diff)"
        }
    }
}



