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
            .filter { !isOverdue($0) || $0.completed }
            .map { reminder in
                mapReminderToItem(
                    reminder,
                    status: reminder.completed ? .completed : .upcoming
                )
            }
        
        let pendingCount = reminders.filter { !$0.completed }.count
        let petNames = extractFocusPetNames(from: reminders)
        
        return ReminderScreenViewData(
            todayFocusCount: pendingCount,
            focusPetNames: petNames,
            overdueItems: overdueItems,
            upcomingItems: upcomingItems
        )
    }
    
    private func mapReminderToItem(_ reminder: ReminderResponse, status: ReminderStatus) -> ReminderItemViewData {
        ReminderItemViewData(
            id: reminder.id,
            title: reminder.title,
            subtitle: makeSubtitle(from: reminder),
            petName: reminder.petName ?? "All Pets",
            category: mapCategory(reminder.type),
            status: status,
            isCompleted: reminder.completed
        )
    }
    
    private func mapCategory(_ type: String?) -> ReminderCategory {
        switch type?.lowercased() {
        case "health":
            return .health
        case "shopping":
            return .shopping
        case "hygiene":
            return .hygiene
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
        
        if reminder.completed {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return "Completed • \(formatter.string(from: dueDate))"
        }
        
        if calendar.isDateInToday(dueDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: dueDate))"
        }
        
        if calendar.isDateInTomorrow(dueDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Tomorrow, \(formatter.string(from: dueDate))"
        }
        
        if dueDate < Date() {
            let days = calendar.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
            if days <= 1 {
                return "Yesterday"
            } else {
                return "\(days) days ago"
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: dueDate)
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
}
