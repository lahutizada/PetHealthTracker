//
//  ReminderViewData.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

enum ReminderStatus {
    case overdue
    case upcoming
    case completed
}

enum ReminderCategory {
    case health
    case shopping
    case hygiene
    case general
}

struct ReminderItemViewData {
    let id: String
    let title: String
    let subtitle: String
    let petName: String
    let category: ReminderCategory
    let status: ReminderStatus
    let isCompleted: Bool
}

struct ReminderScreenViewData {
    let todayFocusCount: Int
    let focusPetNames: String
    let overdueItems: [ReminderItemViewData]
    let upcomingItems: [ReminderItemViewData]
}
