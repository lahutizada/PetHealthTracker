//
//  PetDetailsViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 17.03.26.
//

import Foundation

protocol PetDetailsViewModelProtocol: AnyObject {
    
    var onPetLoaded: ((PetResponse) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onHealthOverviewLoaded: ((PetHealthOverviewViewData) -> Void)? { get set }
    
    func loadPet()
    func setMainPet()
}

final class PetDetailsViewModel: PetDetailsViewModelProtocol {
    
    var onPetLoaded: ((PetResponse) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onHealthOverviewLoaded: ((PetHealthOverviewViewData) -> Void)?
    
    private let petId: String
    
    private let getPetDetailsUseCase: GetPetDetailsUseCaseProtocol
    private let setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol
    private let getVaccinationsUseCase: GetVaccinationsUseCaseProtocol
    private let getDewormingUseCase: GetDewormingUseCaseProtocol
    private let getRemindersUseCase: GetRemindersUseCaseProtocol
    
    init(
        petId: String,
        getPetDetailsUseCase: GetPetDetailsUseCaseProtocol = GetPetDetailsUseCase(),
        setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol = SetHighlightedPetUseCase(),
        getVaccinationsUseCase: GetVaccinationsUseCaseProtocol = GetVaccinationsUseCase(),
        getDewormingUseCase: GetDewormingUseCaseProtocol = GetDewormingUseCase(),
        getRemindersUseCase: GetRemindersUseCaseProtocol = GetRemindersUseCase()
    ) {
        self.petId = petId
        self.getPetDetailsUseCase = getPetDetailsUseCase
        self.setHighlightedPetUseCase = setHighlightedPetUseCase
        self.getVaccinationsUseCase = getVaccinationsUseCase
        self.getDewormingUseCase = getDewormingUseCase
        self.getRemindersUseCase = getRemindersUseCase
    }
    
    func loadPet() {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                async let petTask = getPetDetailsUseCase.execute(id: petId)
                async let vaccinationsTask = getVaccinationsUseCase.execute(petId: petId)
                async let dewormingTask = getDewormingUseCase.execute(petId: petId)
                async let remindersTask = getRemindersUseCase.execute()
                
                let pet = try await petTask
                let vaccinations = try await vaccinationsTask
                let deworming = try await dewormingTask
                let reminders = try await remindersTask
                
                let healthOverviewViewData = makeHealthOverviewViewData(
                    vaccinations: vaccinations,
                    deworming: deworming,
                    reminders: reminders
                )

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onPetLoaded?(pet)
                    self.onHealthOverviewLoaded?(healthOverviewViewData)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load pet details")
                }
            }
        }
    }
    
    func setMainPet() {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                _ = try await setHighlightedPetUseCase.execute(id: petId)
                let pet = try await getPetDetailsUseCase.execute(id: petId)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onPetLoaded?(pet)
                    
                    NotificationCenter.default.post(
                        name: .highlightedPetChanged,
                        object: nil
                    )
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to set main pet")
                }
            }
        }
    }
    
    private func makeHealthOverviewViewData(
        vaccinations: [VaccinationRecordResponse],
        deworming: [DewormingRecordResponse],
        reminders: [ReminderResponse]
    ) -> PetHealthOverviewViewData {
        
        let latestVaccination = vaccinations.first
        let latestDeworming = deworming.first
        
        let petReminders = reminders.filter { $0.petId == petId }
        let upcomingVetReminder = petReminders
            .filter { ($0.type?.lowercased() == "vet" || $0.title.lowercased().contains("vet")) && !$0.completed }
            .sorted {
                (parseDate($0.dueDate) ?? .distantFuture) < (parseDate($1.dueDate) ?? .distantFuture)
            }
            .first
        
        return PetHealthOverviewViewData(
            vaccination: PetHealthOverviewCardViewData(
                title: "Vaccinations",
                subtitle: latestVaccination.map {
                    "Next due: \(vaccineDisplayName(type: $0.vaccineType, customName: $0.customName))"
                } ?? "No records yet",
                statusText: makePreventiveStatusText(nextDueAt: latestVaccination?.nextDueAt)
            ),
            deworming: PetHealthOverviewCardViewData(
                title: "Dewormings",
                subtitle: latestDeworming?.nextDueAt.flatMap { formatDate($0) }.map { "Next due: \($0)" } ?? "No records yet",
                statusText: makePreventiveStatusText(nextDueAt: latestDeworming?.nextDueAt)
            ),
            activity: PetHealthOverviewCardViewData(
                title: "Activity",
                subtitle: "Track walks and daily movement",
                statusText: "Coming soon"
            ),
            upcomingVetVisit: makeUpcomingVetVisit(from: upcomingVetReminder)
        )
    }
    
    private func vaccineDisplayName(type: String, customName: String?) -> String {
        switch type.uppercased() {
        case "RABIES": return "Rabies"
        case "DHPP": return "DHPP"
        case "DAPP": return "DAPP"
        case "FVRCP": return "FVRCP"
        case "FELV": return "FeLV"
        case "BORDETELLA": return "Bordetella"
        case "LEPTOSPIROSIS": return "Leptospirosis"
        case "LYME": return "Lyme"
        case "CUSTOM": return customName ?? "Custom vaccine"
        default: return type.capitalized
        }
    }
    
    private func makePreventiveSubtitle(administeredAt: String?, nextDueAt: String?) -> String {
        let lastText = administeredAt.flatMap { formatDate($0) } ?? "—"
        let nextText = nextDueAt.flatMap { formatDate($0) } ?? "—"
        return "Last: \(lastText) • Next: \(nextText)"
    }
    
    private func makePreventiveStatusText(nextDueAt: String?) -> String {
        guard let nextDueAt, let dueDate = parseDate(nextDueAt) else {
            return "No schedule"
        }
        
        let now = Date()
        let days = Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? 0
        
        if days < 0 {
            return "Overdue"
        } else if days <= 14 {
            return "Due soon"
        } else {
            return "Up to date"
        }
    }
    
    private func formatDate(_ value: String) -> String? {
        guard let date = parseDate(value) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoWithFraction.date(from: value) {
            return date
        }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: value) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
    
    private func makeUpcomingVetVisit(from reminder: ReminderResponse?) -> PetUpcomingVetVisitViewData? {
        guard let reminder,
              let dueDateString = reminder.dueDate,
              let dueDate = parseDate(dueDateString) else {
            return nil
        }
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let badgeText: String = {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
            if days <= 0 { return "Today" }
            if days == 1 { return "In 1 day" }
            return "In \(days) days"
        }()
        
        return PetUpcomingVetVisitViewData(
            title: reminder.title,
            clinicName: reminder.notes?.isEmpty == false ? reminder.notes! : "Vet appointment",
            dateText: "\(monthFormatter.string(from: dueDate).uppercased()) \(dayFormatter.string(from: dueDate))",
            badgeText: badgeText,
            timeText: timeFormatter.string(from: dueDate)
        )
    }
}
