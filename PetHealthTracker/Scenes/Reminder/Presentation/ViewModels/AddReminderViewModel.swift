//
//  AddReminderViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

struct ReminderPetItem {
    let id: String?
    let name: String
}

protocol AddReminderViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onPetsLoaded: (([ReminderPetItem]) -> Void)? { get set }
    var onReminderCreated: ((ReminderResponse) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    
    func loadPets()
    func createReminder(
        title: String?,
        notes: String?,
        dueDate: Date,
        category: String?,
        selectedPetIndex: Int
    )
    
    func clearError()
}

final class AddReminderViewModel: AddReminderViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onPetsLoaded: (([ReminderPetItem]) -> Void)?
    var onReminderCreated: ((ReminderResponse) -> Void)?
    var onError: ((String?) -> Void)?
    
    private let getPetsUseCase: GetPetsUseCaseProtocol
    private let createReminderUseCase: CreateReminderUseCaseProtocol
    
    private var petItems: [ReminderPetItem] = []
    
    init(
        getPetsUseCase: GetPetsUseCaseProtocol = GetPetsUseCase(),
        createReminderUseCase: CreateReminderUseCaseProtocol = CreateReminderUseCase()
    ) {
        self.getPetsUseCase = getPetsUseCase
        self.createReminderUseCase = createReminderUseCase
    }
    
    func loadPets() {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let pets = try await getPetsUseCase.execute()
                
                let items: [ReminderPetItem] = pets.map {
                    ReminderPetItem(id: $0.id, name: $0.name)
                }
                
                self.petItems = items
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onPetsLoaded?(items)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load pets")
                }
            }
        }
    }
    
    func createReminder(
        title: String?,
        notes: String?,
        dueDate: Date,
        category: String?,
        selectedPetIndex: Int
    ) {
        clearError()
        
        let cleanTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCategory = category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !cleanTitle.isEmpty else {
            onError?("Reminder title is required")
            return
        }
        
        guard !cleanCategory.isEmpty else {
            onError?("Category is required")
            return
        }
        
        let petId: String?
        if petItems.indices.contains(selectedPetIndex) {
            petId = petItems[selectedPetIndex].id
        } else {
            petId = nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let request = CreateReminderRequest(
            title: cleanTitle,
            notes: cleanNotes?.isEmpty == true ? nil : cleanNotes,
            dueDate: formatter.string(from: dueDate),
            type: cleanCategory.lowercased(),
            petId: petId
        )
        
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let reminder = try await createReminderUseCase.execute(requestModel: request)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onReminderCreated?(reminder)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to save reminder")
                }
            }
        }
    }
    
    func clearError() {
        onError?(nil)
    }
}
