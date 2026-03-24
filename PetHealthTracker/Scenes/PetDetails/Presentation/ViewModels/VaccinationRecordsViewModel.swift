//
//  VaccinationRecordsViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

enum HealthRecordStatus {
    case overdue
    case upcoming
    case completed
    
    var title: String {
        switch self {
        case .overdue:
            return "Overdue"
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        }
    }
}

struct PetPickerItemViewData {
    let id: String
    let name: String
    let breed: String
    let ageText: String
    let photoURL: String?
    let isSelected: Bool
}

enum TimelineRawRecord {
    case vaccination(VaccinationRecordResponse)
    case deworming(DewormingRecordResponse)
}

struct TimelineRecordItemViewData {
    let id: String
    let status: HealthRecordStatus
    let title: String
    let subtitle: String
    let dueText: String
    let doseText: String?
    let actionTitle: String?
    let rawRecord: TimelineRawRecord?
    let detailsText: String?
}

struct VaccinationRecordsScreenViewData {
    let selectedPet: PetPickerItemViewData
    let allPets: [PetPickerItemViewData]
    let items: [TimelineRecordItemViewData]
}

protocol VaccinationRecordsViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onDataLoaded: ((VaccinationRecordsScreenViewData) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onRecordAction: ((TimelineRawRecord) -> Void)? { get set }
    
    func load()
    func selectPet(id: String)
    func handleAction(for item: TimelineRecordItemViewData)
    func delete(record: VaccinationRecordResponse)
    func markAsComplete(record: VaccinationRecordResponse)
    func reschedule(record: VaccinationRecordResponse, nextDate: Date)
}

final class VaccinationRecordsViewModel: VaccinationRecordsViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onDataLoaded: ((VaccinationRecordsScreenViewData) -> Void)?
    var onError: ((String) -> Void)?
    var onRecordAction: ((TimelineRawRecord) -> Void)?
    
    private let getPetsUseCase: GetPetsUseCaseProtocol
    private let getVaccinationsUseCase: GetVaccinationsUseCaseProtocol
    private let deleteVaccinationUseCase: DeleteVaccinationUseCaseProtocol
    private let updateVaccinationUseCase: UpdateVaccinationUseCaseProtocol
    
    private var selectedPetId: String
    private var pets: [PetResponse] = []
    private var records: [VaccinationRecordResponse] = []
    
    init(
        petId: String,
        getPetsUseCase: GetPetsUseCaseProtocol = GetPetsUseCase(),
        getVaccinationsUseCase: GetVaccinationsUseCaseProtocol = GetVaccinationsUseCase(),
        deleteVaccinationUseCase: DeleteVaccinationUseCaseProtocol = DeleteVaccinationUseCase(),
        updateVaccinationUseCase: UpdateVaccinationUseCaseProtocol = UpdateVaccinationUseCase(),
    ) {
        self.selectedPetId = petId
        self.getPetsUseCase = getPetsUseCase
        self.getVaccinationsUseCase = getVaccinationsUseCase
        self.deleteVaccinationUseCase = deleteVaccinationUseCase
        self.updateVaccinationUseCase = updateVaccinationUseCase
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
        onRecordAction?(raw)
    }
    
    func delete(record: VaccinationRecordResponse) {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                try await deleteVaccinationUseCase.execute(id: record.id)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to delete vaccination record")
                }
            }
        }
    }
    
    private func fetchData(for petId: String) {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                async let petsTask = getPetsUseCase.execute()
                async let recordsTask = getVaccinationsUseCase.execute(petId: petId)
                
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
                    self.onError?("Failed to load vaccination records")
                }
            }
        }
    }
    
    private func makeScreenData(
        selectedPet: PetResponse,
        pets: [PetResponse],
        records: [VaccinationRecordResponse]
    ) -> VaccinationRecordsScreenViewData {
        
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
        
        return VaccinationRecordsScreenViewData(
            selectedPet: petItems.first(where: { $0.id == selectedPet.id }) ?? petItems[0],
            allPets: petItems,
            items: items
        )
    }
    
    private func mapRecord(_ record: VaccinationRecordResponse) -> TimelineRecordItemViewData {
        let status = makeStatus(record)
        
        return TimelineRecordItemViewData(
            id: record.id,
            status: status,
            title: vaccineName(record),
            subtitle: makeAutoSubtitle(record),
            dueText: makeDueText(status, record),
            doseText: nil,
            actionTitle: actionTitle(status),
            rawRecord: .vaccination(record),
            detailsText: normalizedDetails(record.notes)
        )
    }
    
    private func makeAutoSubtitle(_ record: VaccinationRecordResponse) -> String {
        let type = record.vaccineType.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        switch type {
        case "RABIES":
            return "Protects against rabies, a deadly viral disease affecting the nervous system."
            
        case "DHPP":
            return "Core protection against distemper, hepatitis, parvovirus, and parainfluenza."
            
        case "DAPP":
            return "Helps protect against distemper, adenovirus, parainfluenza, and parvovirus."
            
        case "FVRCP":
            return "Core feline vaccine protecting against rhinotracheitis, calicivirus, and panleukopenia."
            
        case "FELV":
            return "Protects cats against feline leukemia virus, which can weaken the immune system."
            
        case "BORDETELLA":
            return "Helps reduce the risk of kennel cough and other upper respiratory infections."
            
        case "LEPTOSPIROSIS":
            return "Protects against leptospirosis, a bacterial infection that can affect organs."
            
        case "LYME":
            return "Helps protect against Lyme disease transmitted by infected ticks."
            
        case "CUSTOM":
            return customVaccineSubtitle(record)
            
        default:
            return customVaccineSubtitle(record)
        }
    }
    
    private func customVaccineSubtitle(_ record: VaccinationRecordResponse) -> String {
        let notes = record.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !notes.isEmpty {
            return notes
        }
        
        if let customName = record.customName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !customName.isEmpty {
            return "\(customName) vaccination record."
        }
        
        return "Protective vaccination record."
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
    
    private func makeStatus(_ record: VaccinationRecordResponse) -> HealthRecordStatus {
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
    
    private func makeDueText(_ status: HealthRecordStatus, _ record: VaccinationRecordResponse) -> String {
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
    
    private func vaccineName(_ record: VaccinationRecordResponse) -> String {
        if let customName = record.customName,
           !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return customName
        }
        
        let type = record.vaccineType.trimmingCharacters(in: .whitespacesAndNewlines)
        if !type.isEmpty {
            return formattedVaccineType(type)
        }
        
        return "Vaccination"
    }
    
    private func formattedVaccineType(_ value: String) -> String {
        switch value.uppercased() {
        case "RABIES":
            return "Rabies"
        case "DHPP":
            return "DHPP"
        case "DAPP":
            return "DAPP"
        case "FVRCP":
            return "FVRCP"
        case "FELV":
            return "FeLV"
        case "BORDETELLA":
            return "Bordetella"
        case "LEPTOSPIROSIS":
            return "Leptospirosis"
        case "LYME":
            return "Lyme"
        default:
            return value.capitalized
        }
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
    
    private func sortDate(for record: VaccinationRecordResponse, status: HealthRecordStatus) -> Date {
        switch status {
        case .overdue, .upcoming:
            return parseDate(record.nextDueAt) ?? .distantFuture
        case .completed:
            return parseDate(record.administeredAt) ?? .distantFuture
        }
    }
    
    func markAsComplete(record: VaccinationRecordResponse) {
        onLoadingStateChanged?(true)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let request = UpdateVaccinationRequest(
            petId: record.petId,
            vaccineType: record.vaccineType,
            customName: record.customName,
            administeredAt: formatter.string(from: Date()),
            nextDueAt: nil,
            notes: record.notes
        )
        
        Task {
            do {
                _ = try await updateVaccinationUseCase.execute(id: record.id, requestModel: request)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to mark vaccination as complete")
                }
            }
        }
    }

    func reschedule(record: VaccinationRecordResponse, nextDate: Date) {
        onLoadingStateChanged?(true)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let request = UpdateVaccinationRequest(
            petId: record.petId,
            vaccineType: record.vaccineType,
            customName: record.customName,
            administeredAt: record.administeredAt,
            nextDueAt: formatter.string(from: nextDate),
            notes: record.notes
        )
        
        Task {
            do {
                _ = try await updateVaccinationUseCase.execute(id: record.id, requestModel: request)
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.load()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to reschedule vaccination")
                }
            }
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
