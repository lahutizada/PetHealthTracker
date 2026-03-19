//
//  RemindersController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class RemindersController: BaseController {
    
    private let viewModel: RemindersViewModelProtocol
    
    init(viewModel: RemindersViewModelProtocol = DIContainer.shared.makeRemindersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .onboardingBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reminders & Tasks"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .onboardingBlack
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
        return view
    }()
    
    private lazy var upcomingStackView: UIStackView = {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadReminders()
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        view.addSubview(addButton)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(calendarButton)
        contentView.addSubview(focusCardView)
        contentView.addSubview(overdueHeaderView)
        contentView.addSubview(overdueStackView)
        contentView.addSubview(upcomingHeaderView)
        contentView.addSubview(upcomingStackView)
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
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
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
            upcomingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120),
            
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { isLoading in
            print("Reminders loading:", isLoading)
        }
        
        viewModel.onRemindersLoaded = { [weak self] viewData in
            DispatchQueue.main.async {
                self?.applyData(viewData)
            }
        }
        
        viewModel.onError = { error in
            print("Reminders error:", error)
        }
    }
    
    private func applyData(_ viewData: ReminderScreenViewData) {
        focusCardView.configure(
            taskCount: viewData.todayFocusCount,
            petsText: viewData.focusPetNames
        )
        
        overdueHeaderView.configure(
            title: "Overdue",
            badgeText: viewData.overdueItems.isEmpty ? nil : "\(viewData.overdueItems.count) LATE",
            isDanger: true
        )
        
        upcomingHeaderView.configure(
            title: "Upcoming",
            badgeText: nil,
            isDanger: false
        )
        
        applyItems(viewData.overdueItems, to: overdueStackView)
        applyItems(viewData.upcomingItems, to: upcomingStackView)
    }
    
    private func applyItems(_ items: [ReminderItemViewData], to stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for item in items {
            let card = ReminderItemCardView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.configure(with: item)
            
            card.onToggleCompleted = { [weak self] in
                self?.viewModel.toggleReminderCompleted(id: item.id)
            }
            
            card.onDeleteTapped = { [weak self] in
                self?.showDeleteAlert(for: item.id)
            }
            
            stackView.addArrangedSubview(card)
        }
    }
    
    private func showDeleteAlert(for id: String) {
        let alert = UIAlertController(
            title: "Delete Reminder",
            message: "Are you sure you want to delete this reminder?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteReminder(id: id)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addTapped() {
        let vc = AddReminderController()
        vc.onReminderSaved = { [weak self] in
            self?.viewModel.reloadReminders()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
