//
//  RemindersViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol RemindersViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onRemindersLoaded: ((ReminderScreenViewData) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadReminders()
    func reloadReminders()
    func toggleReminderCompleted(id: String)
    func deleteReminder(id: String)
    func reminder(by id: String) -> ReminderResponse?
}

final class RemindersViewModel: RemindersViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onRemindersLoaded: ((ReminderScreenViewData) -> Void)?
    var onError: ((String) -> Void)?
    
    
    private let getRemindersUseCase: GetRemindersUseCaseProtocol
    private let updateReminderUseCase: UpdateReminderUseCaseProtocol
    private let deleteReminderUseCase: DeleteReminderUseCaseProtocol
    
    private var reminders: [ReminderResponse] = []
    
    init(
        getRemindersUseCase: GetRemindersUseCaseProtocol = GetRemindersUseCase(),
        updateReminderUseCase: UpdateReminderUseCaseProtocol = UpdateReminderUseCase(),
        deleteReminderUseCase: DeleteReminderUseCaseProtocol = DeleteReminderUseCase()
    ) {
        self.getRemindersUseCase = getRemindersUseCase
        self.updateReminderUseCase = updateReminderUseCase
        self.deleteReminderUseCase = deleteReminderUseCase
    }
    
    func reminder(by id: String) -> ReminderResponse? {
        reminders.first { $0.id == id }
    }
    
    func loadReminders() {
        fetchReminders()
    }
    
    func reloadReminders() {
        fetchReminders()
    }
    
    func toggleReminderCompleted(id: String) {
        guard let reminder = reminders.first(where: { $0.id == id }) else { return }
        
        let request = UpdateReminderRequest(
            title: nil,
            notes: nil,
            dueDate: nil,
            type: nil,
            completed: !reminder.completed,
            petId: nil
        )
        
        Task {
            do {
                let updatedReminder = try await updateReminderUseCase.execute(id: id, requestModel: request)
                
                if let index = reminders.firstIndex(where: { $0.id == id }) {
                    reminders[index] = updatedReminder
                }
                
                let viewData = makeViewData(from: reminders)
                
                await MainActor.run {
                    self.onRemindersLoaded?(viewData)
                }
            } catch {
                await MainActor.run {
                    self.onError?("Failed to update reminder")
                }
            }
        }
    }
    
    func deleteReminder(id: String) {
        Task {
            do {
                try await deleteReminderUseCase.execute(id: id)
                reminders.removeAll { $0.id == id }
                
                let viewData = makeViewData(from: reminders)
                
                await MainActor.run {
                    self.onRemindersLoaded?(viewData)
                }
            } catch {
                await MainActor.run {
                    self.onError?("Failed to delete reminder")
                }
            }
        }
    }
    
    private func fetchReminders() {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let reminders = try await getRemindersUseCase.execute()
                self.reminders = reminders
                let viewData = makeViewData(from: reminders)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onRemindersLoaded?(viewData)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load reminders")
                }
            }
        }
    }
    
    private func makeViewData(from reminders: [ReminderResponse]) -> ReminderScreenViewData {
        
        let overdueItems = reminders
            .filter { isOverdue($0) && !$0.completed }
            .map { mapReminderToItem($0, status: .overdue) }
        
        let upcomingItems = reminders
            .filter { !isOverdue($0) && !$0.completed }
            .map { mapReminderToItem($0, status: .upcoming) }
        
        let completedItems = reminders
            .filter { $0.completed }
            .map { mapReminderToItem($0, status: .completed) }
        
        let pendingCount = reminders.filter { !$0.completed }.count
        let focusPets = extractFocusPets(from: reminders)
        let focusText = makeFocusPetsText(from: focusPets)
        
        return ReminderScreenViewData(
            todayFocusCount: pendingCount,
            focusPetsText: focusText,
            focusPets: Array(focusPets.prefix(2)),
            overdueItems: overdueItems,
            upcomingItems: upcomingItems,
            completedItems: completedItems
        )
    }
    
    private func mapReminderToItem(_ reminder: ReminderResponse, status: ReminderStatus) -> ReminderItemViewData {
        ReminderItemViewData(
            id: reminder.id,
            title: reminder.title,
            subtitle: makeSubtitle(from: reminder),
            petName: reminder.petName ?? "Unknown pet",
            category: mapCategory(reminder.type),
            status: status,
            isCompleted: reminder.completed,
            notes: reminder.notes,
            petId: reminder.petId,
            dueDate: reminder.dueDate,
            typeRaw: reminder.type,
            petPhotoUrl: reminder.petPhotoUrl
        )
    }
    
    private func mapCategory(_ type: String?) -> ReminderCategory {
        switch type?.lowercased() {
        case "vet":
            return .vet
        case "vaccination":
            return .vaccination
        case "deworming":
            return .deworming
        case "medication":
            return .medication
        case "grooming":
            return .grooming
        case "shopping":
            return .shopping
        default:
            return .general
        }
    }
    
    private func isOverdue(_ reminder: ReminderResponse) -> Bool {
        guard let dueDate = parseDate(reminder.dueDate) else { return false }
        return dueDate < Date()
    }
    
    private func makeSubtitle(from reminder: ReminderResponse) -> String {
        guard let dueDate = parseDate(reminder.dueDate) else { return "No date" }
        
        let calendar = Calendar.current
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "EEE, MMM d"
        
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "MMM d, yyyy"
        
        if reminder.completed {
            if calendar.isDateInToday(dueDate) {
                return "Completed today"
            }
            
            if calendar.isDateInYesterday(dueDate) {
                return "Completed yesterday"
            }
            
            return "Completed • \(fullFormatter.string(from: dueDate))"
        }
        
        if calendar.isDateInToday(dueDate) {
            return "Today, \(timeFormatter.string(from: dueDate))"
        }
        
        if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow, \(timeFormatter.string(from: dueDate))"
        }
        
        if dueDate < Date() {
            let days = calendar.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
            
            if days <= 1 {
                return "Yesterday"
            } else {
                return "\(days) days ago"
            }
        }
        
        return shortFormatter.string(from: dueDate)
    }
    
    private func extractFocusPetNames(from reminders: [ReminderResponse]) -> String {
        let names = reminders
            .filter { !$0.completed }
            .compactMap { $0.petName }
        
        let uniqueNames = Array(Set(names)).sorted()
        
        if uniqueNames.isEmpty {
            return "For all pets"
        }
        
        if uniqueNames.count == 1 {
            return "For \(uniqueNames[0])"
        }
        
        return "For " + uniqueNames.joined(separator: " & ")
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
    
    private func extractFocusPets(from reminders: [ReminderResponse]) -> [ReminderFocusPet] {
        var seenNames = Set<String>()
        var result: [ReminderFocusPet] = []
        
        for reminder in reminders where !reminder.completed {
            guard let petName = reminder.petName, !petName.isEmpty else { continue }
            guard !seenNames.contains(petName) else { continue }
            
            seenNames.insert(petName)
            result.append(
                ReminderFocusPet(
                    name: petName,
                    photoURL: reminder.petPhotoUrl
                )
            )
        }
        
        return result
    }

    private func makeFocusPetsText(from pets: [ReminderFocusPet]) -> String {
        let names = pets.map { $0.name }
        
        if names.isEmpty {
            return "For all pets"
        }
        
        if names.count == 1 {
            return "For \(names[0])"
        }
        
        if names.count == 2 {
            return "For \(names[0]) & \(names[1])"
        }
        
        return "For all pets"
    }
}
