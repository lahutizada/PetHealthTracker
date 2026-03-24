//
//  AddVaccinationViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

protocol AddVaccinationViewModelProtocol: AnyObject {
    
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onRecordSaved: ((VaccinationRecordResponse) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    
    var availableVaccines: [VaccineType] { get }
    
    func save(
        petId: String,
        vaccineType: VaccineType,
        customName: String?,
        administeredAt: Date,
        nextDueAt: Date?,
        notes: String?
    )
    
    func clearError()
}

// MARK: - VaccineType

enum VaccineType: String, CaseIterable {
    case rabies = "RABIES"
    case dhpp = "DHPP"
    case dapp = "DAPP"
    case fvrcp = "FVRCP"
    case felv = "FELV"
    case bordetella = "BORDETELLA"
    case leptospirosis = "LEPTOSPIROSIS"
    case lyme = "LYME"
    case custom = "CUSTOM"
    
    var title: String {
        switch self {
        case .rabies: return "Rabies"
        case .dhpp: return "DHPP"
        case .dapp: return "DAPP"
        case .fvrcp: return "FVRCP"
        case .felv: return "FeLV"
        case .bordetella: return "Bordetella"
        case .leptospirosis: return "Leptospirosis"
        case .lyme: return "Lyme"
        case .custom: return "Custom"
        }
    }
}

// MARK: - ViewModel

final class AddVaccinationViewModel: AddVaccinationViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onRecordSaved: ((VaccinationRecordResponse) -> Void)?
    var onError: ((String?) -> Void)?
    
    var availableVaccines: [VaccineType] {
        VaccineType.allCases
    }
    
    private let createVaccinationUseCase: CreateVaccinationUseCaseProtocol
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    init(
        createVaccinationUseCase: CreateVaccinationUseCaseProtocol = CreateVaccinationUseCase()
    ) {
        self.createVaccinationUseCase = createVaccinationUseCase
    }
    
    // MARK: - Save
    
    func save(
        petId: String,
        vaccineType: VaccineType,
        customName: String?,
        administeredAt: Date,
        nextDueAt: Date?,
        notes: String?
    ) {
        clearError()
        
        let cleanPetId = petId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCustomName = customName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanPetId.isEmpty else {
            onError?("Pet is required")
            return
        }
        
        if vaccineType == .custom && (cleanCustomName ?? "").isEmpty {
            onError?("Custom vaccine name is required")
            return
        }
        
        if let nextDueAt, nextDueAt < administeredAt {
            onError?("Next due date cannot be earlier than administered date")
            return
        }
        
        let request = CreateVaccinationRequest(
            petId: cleanPetId,
            vaccineType: vaccineType.rawValue,
            customName: vaccineType == .custom ? cleanCustomName : nil,
            administeredAt: isoFormatter.string(from: administeredAt),
            nextDueAt: nextDueAt.map { isoFormatter.string(from: $0) },
            notes: normalizedOptionalString(cleanNotes)
        )
        
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let response = try await createVaccinationUseCase.execute(requestModel: request)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onRecordSaved?(response)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    
                    let message = self.userFriendlyMessage(from: error)
                    self.onError?(message)
                }
            }
        }
    }
    
    func clearError() {
        onError?(nil)
    }
    
    // MARK: - Helpers
    
    private func normalizedOptionalString(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
    
    private func userFriendlyMessage(from error: Error) -> String {
        let message = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !message.isEmpty, message != "The operation couldn’t be completed." {
            return message
        }
        
        return "Failed to save vaccination record"
    }
}
