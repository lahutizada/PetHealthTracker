//
//  AddDewormingViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

protocol AddDewormingViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onRecordSaved: ((DewormingRecordResponse) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    
    func save(
        petId: String,
        productName: String?,
        administeredAt: Date,
        nextDueAt: Date?,
        notes: String?
    )
    
    func clearError()
}

final class AddDewormingViewModel: AddDewormingViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onRecordSaved: ((DewormingRecordResponse) -> Void)?
    var onError: ((String?) -> Void)?
    
    private let createDewormingUseCase: CreateDewormingUseCaseProtocol
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    init(
        createDewormingUseCase: CreateDewormingUseCaseProtocol = CreateDewormingUseCase()
    ) {
        self.createDewormingUseCase = createDewormingUseCase
    }
    
    func save(
        petId: String,
        productName: String?,
        administeredAt: Date,
        nextDueAt: Date?,
        notes: String?
    ) {
        clearError()
        
        let cleanPetId = petId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanProductName = productName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanPetId.isEmpty else {
            onError?("Pet is required")
            return
        }
        
        if let nextDueAt, nextDueAt < administeredAt {
            onError?("Next due date cannot be earlier than administered date")
            return
        }
        
        let request = CreateDewormingRequest(
            petId: cleanPetId,
            productName: normalizedOptionalString(cleanProductName),
            administeredAt: isoFormatter.string(from: administeredAt),
            nextDueAt: nextDueAt.map { isoFormatter.string(from: $0) },
            notes: normalizedOptionalString(cleanNotes)
        )
        
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let response = try await createDewormingUseCase.execute(requestModel: request)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onRecordSaved?(response)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?(self.userFriendlyMessage(from: error))
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
        
        return "Failed to save deworming record"
    }
}
