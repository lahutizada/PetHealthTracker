//
//  PetDetailsViewData.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 17.03.26.
//

import Foundation

struct PetDetailsViewData {
    let id: String
    let name: String
    let subtitle: String
    let isMainPet: Bool
    let species: String
    let photoURL: String?
    
    let weightValueText: String
    let weightUnitText: String
    
    let sexValueText: String
    let sexUnitText: String
    
    let ageValueText: String
    let ageUnitText: String
    
    let growthSubtitleText: String
    let growthWeekText: String
    let growthProgressText: String
    let growthDescriptionText: String
}
