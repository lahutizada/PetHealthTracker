//
//  RemindersController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class RemindersController: BaseController {
    
    private let viewModel: RemindersViewModelProtocol
    
    private var isOverdueExpanded = true
    private var isUpcomingExpanded = true
    private var isCompletedExpanded = true
    
    private var overdueHeightConstraint: NSLayoutConstraint!
    private var upcomingHeightConstraint: NSLayoutConstraint!
    private var completedHeightConstraint: NSLayoutConstraint!
    
    init(viewModel: RemindersViewModelProtocol = DIContainer.shared.makeRemindersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = AppBackButton()
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reminders & Tasks"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .onboardingBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var focusCardView: ReminderFocusCardView = {
        let view = ReminderFocusCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overdueHeaderView: ReminderSectionHeaderView = {
        let view = ReminderSectionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToggleTapped = { [weak self] in
            self?.configureOverdueToggle()
        }
        return view
    }()
    
    private lazy var overdueStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var upcomingHeaderView: ReminderSectionHeaderView = {
        let view = ReminderSectionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToggleTapped = { [weak self] in
            self?.configureUpcomingToggle()
        }
        return view
    }()
    
    private lazy var upcomingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var completedHeaderView: ReminderSectionHeaderView = {
        let view = ReminderSectionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToggleTapped = { [weak self] in
            self?.configureCompletedToggle()
        }
        return view
    }()
    
    private lazy var completedStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadReminders()
    }
    
    // MARK: - Configure
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        view.addSubview(addButton)
        scrollView.addSubview(contentView)
        
        [
            backButton,
            titleLabel,
            calendarButton,
            focusCardView,
            overdueHeaderView,
            overdueStackView,
            upcomingHeaderView,
            upcomingStackView,
            completedHeaderView,
            completedStackView
        ].forEach(contentView.addSubview)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: calendarButton.leadingAnchor, constant: -12),
            
            calendarButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            calendarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calendarButton.widthAnchor.constraint(equalToConstant: 28),
            calendarButton.heightAnchor.constraint(equalToConstant: 28),
            
            focusCardView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 28),
            focusCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            focusCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            overdueHeaderView.topAnchor.constraint(equalTo: focusCardView.bottomAnchor, constant: 28),
            overdueHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overdueHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            overdueHeaderView.heightAnchor.constraint(equalToConstant: 28),
            
            overdueStackView.topAnchor.constraint(equalTo: overdueHeaderView.bottomAnchor, constant: 14),
            overdueStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overdueStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            upcomingHeaderView.topAnchor.constraint(equalTo: overdueStackView.bottomAnchor, constant: 28),
            upcomingHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upcomingHeaderView.heightAnchor.constraint(equalToConstant: 28),
            
            upcomingStackView.topAnchor.constraint(equalTo: upcomingHeaderView.bottomAnchor, constant: 14),
            upcomingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            completedHeaderView.topAnchor.constraint(equalTo: upcomingStackView.bottomAnchor, constant: 28),
            completedHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completedHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completedHeaderView.heightAnchor.constraint(equalToConstant: 28),
            
            completedStackView.topAnchor.constraint(equalTo: completedHeaderView.bottomAnchor, constant: 14),
            completedStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completedStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completedStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120),
            
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
        
        overdueHeightConstraint = overdueStackView.heightAnchor.constraint(equalToConstant: 0)
        overdueHeightConstraint.isActive = false
        
        upcomingHeightConstraint = upcomingStackView.heightAnchor.constraint(equalToConstant: 0)
        upcomingHeightConstraint.isActive = false
        
        completedHeightConstraint = completedStackView.heightAnchor.constraint(equalToConstant: 0)
        completedHeightConstraint.isActive = false
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { isLoading in
            print(isLoading ? "Loading reminders..." : "Reminders loaded")
        }
        
        viewModel.onRemindersLoaded = { [weak self] viewData in
            DispatchQueue.main.async {
                self?.configureData(viewData)
            }
        }
        
        viewModel.onError = { error in
            print("Reminders error:", error)
        }
    }
    
    // MARK: - Configure Data
    
    private func configureData(_ viewData: ReminderScreenViewData) {
        focusCardView.configure(
            taskCount: viewData.todayFocusCount,
            petsText: viewData.focusPetsText,
            pets: viewData.focusPets
        )
        
        overdueHeaderView.configure(
            title: "Overdue",
            badgeText: viewData.overdueItems.isEmpty ? nil : "\(viewData.overdueItems.count) LATE",
            isDanger: true,
            isExpanded: isOverdueExpanded
        )
        
        upcomingHeaderView.configure(
            title: "Upcoming",
            badgeText: viewData.upcomingItems.isEmpty ? nil : "\(viewData.upcomingItems.count) UPCOMING",
            isDanger: false,
            isExpanded: isUpcomingExpanded
        )
        
        completedHeaderView.configure(
            title: "Completed",
            badgeText: viewData.completedItems.isEmpty ? nil : "\(viewData.completedItems.count) COMPLETED",
            isDanger: false,
            isExpanded: isCompletedExpanded
        )
        
        configureItems(viewData.overdueItems, to: overdueStackView, emptyText: "No overdue reminders")
        configureItems(viewData.upcomingItems, to: upcomingStackView, emptyText: "No upcoming reminders")
        configureItems(viewData.completedItems, to: completedStackView, emptyText: "No completed reminders yet")
        
        overdueStackView.isHidden = !isOverdueExpanded
        upcomingStackView.isHidden = !isUpcomingExpanded
        completedStackView.isHidden = !isCompletedExpanded
    }
    
    private func configureItems(_ items: [ReminderItemViewData], to stackView: UIStackView, emptyText: String) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard !items.isEmpty else {
            let emptyView = configureEmptyStateView(text: emptyText)
            stackView.addArrangedSubview(emptyView)
            return
        }
        
        for item in items {
            let card = ReminderItemCardView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.configure(with: item)
            
            card.onToggleCompleted = { [weak self] in
                self?.viewModel.toggleReminderCompleted(id: item.id)
            }
            
            card.onDeleteTapped = { [weak self] in
                self?.configureDeleteAlert(for: item.id)
            }
            
            card.onEditTapped = { [weak self] in
                self?.configureEditReminder(for: item.id)
            }
            
            stackView.addArrangedSubview(card)
        }
    }
    
    private func configureEditReminder(for id: String) {
        guard let reminder = viewModel.reminder(by: id) else { return }
        
        let viewController = AddReminderController(mode: .edit(reminder))
        viewController.onReminderSaved = { [weak self] in
            self?.viewModel.reloadReminders()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func configureDeleteAlert(for id: String) {
        let alert = UIAlertController(
            title: "Delete Reminder",
            message: "Are you sure you want to delete this reminder?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.viewModel.deleteReminder(id: id)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func configureEmptyStateView(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    // MARK: - Toggle Sections
    
    private func configureOverdueToggle() {
        isOverdueExpanded.toggle()
        configureSectionToggle(
            isExpanded: isOverdueExpanded,
            stackView: overdueStackView,
            heightConstraint: overdueHeightConstraint
        )
    }
    
    private func configureUpcomingToggle() {
        isUpcomingExpanded.toggle()
        configureSectionToggle(
            isExpanded: isUpcomingExpanded,
            stackView: upcomingStackView,
            heightConstraint: upcomingHeightConstraint
        )
    }
    
    private func configureCompletedToggle() {
        isCompletedExpanded.toggle()
        configureSectionToggle(
            isExpanded: isCompletedExpanded,
            stackView: completedStackView,
            heightConstraint: completedHeightConstraint
        )
    }
    
    private func configureSectionToggle(
        isExpanded: Bool,
        stackView: UIStackView,
        heightConstraint: NSLayoutConstraint
    ) {
        if isExpanded {
            stackView.isHidden = false
            stackView.alpha = 0
            heightConstraint.isActive = false
        } else {
            heightConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            stackView.alpha = isExpanded ? 1 : 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if !isExpanded {
                stackView.isHidden = true
            }
        })
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addTapped() {
        let viewController = AddReminderController()
        viewController.onReminderSaved = { [weak self] in
            self?.viewModel.reloadReminders()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}
