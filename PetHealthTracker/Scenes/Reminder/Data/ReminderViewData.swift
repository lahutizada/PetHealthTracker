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

import UIKit

enum ReminderCategory: String, CaseIterable {
    
    case vet = "VET"
    case vaccination = "VACCINATION"
    case deworming = "DEWORMING"
    case medication = "MEDICATION"
    case grooming = "GROOMING"
    case shopping = "SHOPPING"
    case general = "GENERAL"
    
    // MARK: - Title
    
    var title: String {
        switch self {
        case .vet: return "Vet Visit"
        case .vaccination: return "Vaccination"
        case .deworming: return "Deworming"
        case .medication: return "Medication"
        case .grooming: return "Grooming"
        case .shopping: return "Shopping"
        case .general: return "General"
        }
    }
    
    // MARK: - Icon
    
    var icon: String {
        switch self {
        case .vet: return "stethoscope"
        case .vaccination: return "cross.vial.fill"
        case .deworming: return "pills.fill"
        case .medication: return "pills"
        case .grooming: return "scissors"
        case .shopping: return "cart"
        case .general: return "bell"
        }
    }
    
    // MARK: - Color
    
    var color: UIColor {
        switch self {
        case .vet: return .systemBlue
        case .vaccination: return .systemGreen
        case .deworming: return .systemPurple
        case .medication: return .systemOrange
        case .grooming: return .systemPink
        case .shopping: return .systemTeal
        case .general: return .systemGray
        }
    }
    
    // MARK: - Init from backend
    
    init(from string: String?) {
        self = ReminderCategory(rawValue: string ?? "") ?? .general
    }
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
