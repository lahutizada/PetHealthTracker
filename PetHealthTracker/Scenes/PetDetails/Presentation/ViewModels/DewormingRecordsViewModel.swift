//
//  DewormingRecordsViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

struct DewormingRecordsScreenViewData {
    let selectedPet: PetPickerItemViewData
    let allPets: [PetPickerItemViewData]
    let items: [TimelineRecordItemViewData]
}

protocol DewormingRecordsViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onDataLoaded: ((DewormingRecordsScreenViewData) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onRecordAction: ((DewormingRecordResponse) -> Void)? { get set }
    
    func load()
    func selectPet(id: String)
    func handleAction(for item: TimelineRecordItemViewData)
    func delete(record: DewormingRecordResponse)
    func markAsComplete(record: DewormingRecordResponse)
    func reschedule(record: DewormingRecordResponse, nextDate: Date)
}

final class DewormingRecordsViewModel: DewormingRecordsViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onDataLoaded: ((DewormingRecordsScreenViewData) -> Void)?
    var onError: ((String) -> Void)?
    var onRecordAction: ((DewormingRecordResponse) -> Void)?
    
    private let getPetsUseCase: GetPetsUseCaseProtocol
    private let getDewormingUseCase: GetDewormingUseCaseProtocol
    private let deleteDewormingUseCase: DeleteDewormingUseCaseProtocol
    private let updateDewormingUseCase: UpdateDewormingUseCaseProtocol
    
    private var selectedPetId: String
    private var pets: [PetResponse] = []
    private var records: [DewormingRecordResponse] = []
    
    init(
        petId: String,
        getPetsUseCase: GetPetsUseCaseProtocol = GetPetsUseCase(),
        getDewormingUseCase: GetDewormingUseCaseProtocol = GetDewormingUseCase(),
        deleteDewormingUseCase: DeleteDewormingUseCaseProtocol = DeleteDewormingUseCase(),
        updateDewormingUseCase: UpdateDewormingUseCaseProtocol = UpdateDewormingUseCase()
    ) {
        self.selectedPetId = petId
        self.getPetsUseCase = getPetsUseCase
        self.getDewormingUseCase = getDewormingUseCase
        self.deleteDewormingUseCase = deleteDewormingUseCase
        self.updateDewormingUseCase = updateDewormingUseCase
    }
    
    func load() {
        fetchData(for: selectedPetId)
    }
    
    func selectPet(id: String) {
        selectedPetId = id
        fetchData(for: id)
    }
    
    func handleAction(for item: TimelineRecordItemViewData) {
        guard let raw = item.rawRecord else { return }
        
        switch raw {
        case .deworming(let record):
            onRecordAction?(record)
        case .vaccination:
            break
        }
    }
    
    func delete(record: DewormingRecordResponse) {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                try await deleteDewormingUseCase.execute(id: record.id)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to delete deworming record")
                }
            }
        }
    }
    
    private func fetchData(for petId: String) {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                async let petsTask = getPetsUseCase.execute()
                async let recordsTask = getDewormingUseCase.execute(petId: petId)
                
                let fetchedPets = try await petsTask
                let fetchedRecords = try await recordsTask
                
                self.pets = fetchedPets
                self.records = fetchedRecords
                
                guard let selectedPet = fetchedPets.first(where: { $0.id == petId }) ?? fetchedPets.first else {
                    await MainActor.run {
                        self.onError?("No pets found")
                        self.onLoadingStateChanged?(false)
                    }
                    return
                }
                
                self.selectedPetId = selectedPet.id
                
                let screenData = makeScreenData(
                    selectedPet: selectedPet,
                    pets: fetchedPets,
                    records: fetchedRecords
                )
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onDataLoaded?(screenData)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load deworming records")
                }
            }
        }
    }
    
    private func makeScreenData(
        selectedPet: PetResponse,
        pets: [PetResponse],
        records: [DewormingRecordResponse]
    ) -> DewormingRecordsScreenViewData {
        
        let petItems = pets.map {
            PetPickerItemViewData(
                id: $0.id,
                name: $0.name,
                breed: $0.breed ?? "Unknown breed",
                ageText: makeAgeText(from: $0.dob),
                photoURL: $0.photoUrl,
                isSelected: $0.id == selectedPet.id
            )
        }
        
        let sorted = records.sorted { lhs, rhs in
            let lhsStatus = makeStatus(lhs)
            let rhsStatus = makeStatus(rhs)
            
            let lhsPriority = priority(lhsStatus)
            let rhsPriority = priority(rhsStatus)
            
            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }
            
            let lhsDate = sortDate(for: lhs, status: lhsStatus)
            let rhsDate = sortDate(for: rhs, status: rhsStatus)
            
            return lhsDate < rhsDate
        }
        
        let items = sorted.map { mapRecord($0) }
        
        return DewormingRecordsScreenViewData(
            selectedPet: petItems.first(where: { $0.id == selectedPet.id }) ?? petItems[0],
            allPets: petItems,
            items: items
        )
    }
    
    func markAsComplete(record: DewormingRecordResponse) {
        onLoadingStateChanged?(true)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let request = UpdateDewormingRequest(
            petId: record.petId,
            productName: record.productName,
            administeredAt: formatter.string(from: Date()),
            nextDueAt: nil,
            notes: record.notes
        )
        
        Task {
            do {
                _ = try await updateDewormingUseCase.execute(id: record.id, requestModel: request)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to mark deworming as complete")
                }
            }
        }
    }

    func reschedule(record: DewormingRecordResponse, nextDate: Date) {
        onLoadingStateChanged?(true)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let request = UpdateDewormingRequest(
            petId: record.petId,
            productName: record.productName,
            administeredAt: record.administeredAt,
            nextDueAt: formatter.string(from: nextDate),
            notes: record.notes
        )
        
        Task {
            do {
                _ = try await updateDewormingUseCase.execute(id: record.id, requestModel: request)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to reschedule deworming")
                }
            }
        }
    }
    
    private func mapRecord(_ record: DewormingRecordResponse) -> TimelineRecordItemViewData {
        let status = makeStatus(record)
        
        return TimelineRecordItemViewData(
            id: record.id,
            status: status,
            title: dewormingTitle(record),
            subtitle: makeAutoSubtitle(record),
            dueText: makeDueText(status, record),
            doseText: nil,
            actionTitle: actionTitle(status),
            rawRecord: .deworming(record),
            detailsText: normalizedDetails(record.notes)
        )
    }
    
    private func makeAutoSubtitle(_ record: DewormingRecordResponse) -> String {
        let title = dewormingTitle(record)
        return "\(title) treatment record"
    }
    
    private func normalizedDetails(_ value: String?) -> String? {
        let text = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? nil : text
    }
    
    private func priority(_ status: HealthRecordStatus) -> Int {
        switch status {
        case .overdue:
            return 0
        case .upcoming:
            return 1
        case .completed:
            return 2
        }
    }
    
    private func makeStatus(_ record: DewormingRecordResponse) -> HealthRecordStatus {
        let nextDueDate = parseDate(record.nextDueAt)
        let administeredDate = parseDate(record.administeredAt)
        let now = Date()
        
        if let nextDueDate {
            return nextDueDate < now ? .overdue : .upcoming
        }
        
        if administeredDate != nil {
            return .completed
        }
        
        return .upcoming
    }
    
    private func makeDueText(_ status: HealthRecordStatus, _ record: DewormingRecordResponse) -> String {
        switch status {
        case .completed:
            return formatDate(record.administeredAt) ?? "Completed"
            
        case .overdue, .upcoming:
            if let formatted = formatDate(record.nextDueAt) {
                return "Due \(formatted)"
            }
            
            if let administered = formatDate(record.administeredAt) {
                return "Given \(administered)"
            }
            
            return "No due date"
        }
    }
    
    private func actionTitle(_ status: HealthRecordStatus) -> String? {
        switch status {
        case .overdue:
            return "Reschedule"
        case .upcoming:
            return "Mark as Complete"
        case .completed:
            return nil
        }
    }
    
    private func dewormingTitle(_ record: DewormingRecordResponse) -> String {
        if let productName = record.productName,
           !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return productName
        }
        
        return "Deworming"
    }
    
    private func makeAgeText(from dob: String?) -> String {
        guard let date = parseDate(dob) else { return "Age unknown" }
        
        let comp = Calendar.current.dateComponents([.year, .month], from: date, to: Date())
        
        if let y = comp.year, y > 0 {
            return "\(y)y \(comp.month ?? 0)m"
        }
        
        return "\(comp.month ?? 0)m"
    }
    
    private func formatDate(_ value: String?) -> String? {
        guard let date = parseDate(value) else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    private func sortDate(for record: DewormingRecordResponse, status: HealthRecordStatus) -> Date {
        switch status {
        case .overdue, .upcoming:
            return parseDate(record.nextDueAt) ?? .distantFuture
        case .completed:
            return parseDate(record.administeredAt) ?? .distantFuture
        }
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
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: value)
    }
}
