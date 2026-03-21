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
    let notes: String?
    let petId: String?
    let dueDate: String?
    let typeRaw: String?
    let petPhotoUrl: String?
}

struct ReminderScreenViewData {
    let todayFocusCount: Int
    let focusPetsText: String
    let focusPets: [ReminderFocusPet]
    let overdueItems: [ReminderItemViewData]
    let upcomingItems: [ReminderItemViewData]
    let completedItems: [ReminderItemViewData]
}

struct ReminderFocusPet {
    let name: String
    let photoURL: String?
}
