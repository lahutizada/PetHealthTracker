//
//  PetResponses.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

struct PetResponse: Codable {

    let id: String
    let userId: String
    let species: String
    let name: String
    let sex: String
    let neutered: Bool
    let breed: String?
    let dob: String?
    let weight: Double?
    let photoUrl: String?

    let status: String?
    let statusText: String?

    let isHighlighted: Bool?
    let createdAt: String
    let updatedAt: String
}
enum PetFormMode {
    case create
    case edit(PetResponse)
}

struct DeletePetResponse: Codable {
    let deleted: Bool
}

enum PetStatus {

    case upToDate
    case vaccineDue
    case checkWeight

    init(apiValue: String?) {
        switch apiValue {
        case "VACCINE_DUE":
            self = .vaccineDue
        case "CHECK_WEIGHT":
            self = .checkWeight
        default:
            self = .upToDate
        }
    }

    var title: String {
        switch self {
        case .upToDate:
            return "Up to date"
        case .vaccineDue:
            return "Vaccine due"
        case .checkWeight:
            return "Check weight"
        }
    }

    var color: UIColor {
        switch self {
        case .upToDate:
            return .systemGray
        case .vaccineDue:
            return UIColor.systemBlue
        case .checkWeight:
            return UIColor.systemOrange
        }
    }
}
