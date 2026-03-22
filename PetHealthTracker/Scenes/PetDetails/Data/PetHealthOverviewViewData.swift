//
//  PetHealthOverviewViewData.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

struct PetHealthOverviewCardViewData {
    let title: String
    let subtitle: String
    let statusText: String
}

struct PetHealthOverviewViewData {
    let vaccination: PetHealthOverviewCardViewData
    let deworming: PetHealthOverviewCardViewData
    let activity: PetHealthOverviewCardViewData
    let upcomingVetVisit: PetUpcomingVetVisitViewData?
}

struct PetUpcomingVetVisitViewData {
    let title: String
    let clinicName: String
    let dateText: String
    let badgeText: String
    let timeText: String
}
