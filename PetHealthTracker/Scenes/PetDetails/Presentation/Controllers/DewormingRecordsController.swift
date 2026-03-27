//
//  DewormingRecordsController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class DewormingRecordsController: BaseController {
    
    private let viewModel: DewormingRecordsViewModelProtocol
    
    private var isPetDropdownOpen = false
    private var currentData: DewormingRecordsScreenViewData?
    
    private var petDropdownContainerHeightConstraint: NSLayoutConstraint!
    private var contentBottomToTimelineConstraint: NSLayoutConstraint!
    private var contentBottomToEmptyConstraint: NSLayoutConstraint!
    
    init(viewModel: DewormingRecordsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(petId: String) {
        self.init(viewModel: DewormingRecordsViewModel(petId: petId))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
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
        label.text = "Deworming Records"
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.textAlignment = .center
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var selectedPetHeaderView: RecordPetHeaderView = {
        let view = RecordPetHeaderView(style: .regular)
        view.onChangePetTapped = { [weak self] in
            self?.togglePetDropdown()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petDropdownContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petDropdownStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var timelineTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Health Timeline"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timelineSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track deworming history & upcoming treatments."
        label.textColor = .onboardingGray
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addRecordButton: UIButton = {
        let button = AppButtonFactory.primary(title: "Add Record", imageSystemName: "plus")
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addRecordTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timelineStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No deworming records yet"
        label.textAlignment = .center
        label.textColor = .onboardingGray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Configure
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            backButton,
            titleLabel,
            selectedPetHeaderView,
            petDropdownContainerView,
            timelineTitleLabel,
            timelineSubtitleLabel,
            addRecordButton,
            timelineStackView,
            emptyStateLabel
        ].forEach(contentView.addSubview)
        
        petDropdownContainerView.addSubview(petDropdownStackView)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            selectedPetHeaderView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 18),
            selectedPetHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectedPetHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            petDropdownContainerView.topAnchor.constraint(equalTo: selectedPetHeaderView.bottomAnchor, constant: 12),
            petDropdownContainerView.leadingAnchor.constraint(equalTo: selectedPetHeaderView.leadingAnchor),
            petDropdownContainerView.trailingAnchor.constraint(equalTo: selectedPetHeaderView.trailingAnchor),
            
            petDropdownStackView.topAnchor.constraint(equalTo: petDropdownContainerView.topAnchor),
            petDropdownStackView.leadingAnchor.constraint(equalTo: petDropdownContainerView.leadingAnchor),
            petDropdownStackView.trailingAnchor.constraint(equalTo: petDropdownContainerView.trailingAnchor),
            petDropdownStackView.bottomAnchor.constraint(equalTo: petDropdownContainerView.bottomAnchor),
            
            timelineTitleLabel.topAnchor.constraint(equalTo: petDropdownContainerView.bottomAnchor, constant: 24),
            timelineTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            timelineSubtitleLabel.topAnchor.constraint(equalTo: timelineTitleLabel.bottomAnchor, constant: 6),
            timelineSubtitleLabel.leadingAnchor.constraint(equalTo: timelineTitleLabel.leadingAnchor),
            timelineSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: addRecordButton.leadingAnchor, constant: -14),
            
            addRecordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addRecordButton.centerYAnchor.constraint(equalTo: timelineTitleLabel.centerYAnchor),
            addRecordButton.widthAnchor.constraint(equalToConstant: 138),
            addRecordButton.heightAnchor.constraint(equalToConstant: 54),
            
            timelineStackView.topAnchor.constraint(equalTo: timelineSubtitleLabel.bottomAnchor, constant: 22),
            timelineStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timelineStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emptyStateLabel.topAnchor.constraint(equalTo: timelineSubtitleLabel.bottomAnchor, constant: 30),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
        
        petDropdownContainerHeightConstraint = petDropdownContainerView.heightAnchor.constraint(equalToConstant: 0)
        petDropdownContainerHeightConstraint.isActive = true
        
        contentBottomToTimelineConstraint = contentView.bottomAnchor.constraint(
            equalTo: timelineStackView.bottomAnchor,
            constant: 40
        )
        
        contentBottomToEmptyConstraint = contentView.bottomAnchor.constraint(
            equalTo: emptyStateLabel.bottomAnchor,
            constant: 40
        )
        
        contentBottomToTimelineConstraint.isActive = true
        contentBottomToEmptyConstraint.isActive = false
    }
    
    override func configureViewModel() {
        viewModel.onDataLoaded = { [weak self] data in
            self?.configureData(data)
        }
        
        viewModel.onRecordAction = { [weak self] record in
            self?.configureRecordAction(record)
        }
    }
    
    // MARK: - Data
    
    private func configureData(_ data: DewormingRecordsScreenViewData) {
        currentData = data
        
        selectedPetHeaderView.configure(with: data.selectedPet)
        
        petDropdownStackView.arrangedSubviews.forEach {
            petDropdownStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let otherPets = data.allPets.filter { $0.id != data.selectedPet.id }
        
        for pet in otherPets {
            let petView = RecordPetHeaderView(style: .compact)
            petView.configure(with: pet)
            petView.onChangePetTapped = { [weak self] in
                self?.togglePetDropdown(closeOnly: true)
                self?.viewModel.selectPet(id: pet.id)
            }
            petDropdownStackView.addArrangedSubview(petView)
        }
        
        timelineStackView.arrangedSubviews.forEach {
            timelineStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for item in data.items {
            let card = TimelineRecordCardView()
            card.configure(with: item)
            
            card.onActionTapped = { [weak self] in
                self?.viewModel.handleAction(for: item)
            }
            
            card.onDeleteTapped = { [weak self] in
                self?.configureDeleteAlert(for: item)
            }
            
            timelineStackView.addArrangedSubview(card)
        }
        
        let isEmpty = data.items.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        timelineStackView.isHidden = isEmpty
        
        contentBottomToTimelineConstraint.isActive = !isEmpty
        contentBottomToEmptyConstraint.isActive = isEmpty
        
        configurePetDropdownLayout()
        view.layoutIfNeeded()
    }
    
    private func configureRecordAction(_ record: DewormingRecordResponse) {
        let currentStatus = configureStatus(for: record)
        
        switch currentStatus {
        case .upcoming:
            configureMarkCompleteAlert(for: record)
        case .overdue:
            configureReschedulePicker(for: record)
        case .completed:
            break
        }
    }
    
    private func configureStatus(for record: DewormingRecordResponse) -> HealthRecordStatus {
        if let nextDueAt = record.nextDueAt, !nextDueAt.isEmpty {
            let isoWithFraction = ISO8601DateFormatter()
            isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = isoWithFraction.date(from: nextDueAt) {
                return date < Date() ? .overdue : .upcoming
            }
            
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            
            if let date = iso.date(from: nextDueAt) {
                return date < Date() ? .overdue : .upcoming
            }
            
            return .upcoming
        }
        
        return .completed
    }
    
    private func configureMarkCompleteAlert(for record: DewormingRecordResponse) {
        let alert = UIAlertController(
            title: "Mark as Complete",
            message: "Do you want to mark this deworming record as completed?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
                self?.viewModel.markAsComplete(record: record)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func configureReschedulePicker(for record: DewormingRecordResponse) {
        let alert = UIAlertController(
            title: "Reschedule",
            message: "\n\n\n\n\n\n\n\n",
            preferredStyle: .actionSheet
        )
        
        let picker = UIDatePicker(frame: CGRect(x: 16, y: 40, width: view.bounds.width - 64, height: 160))
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                self?.viewModel.reschedule(record: record, nextDate: picker.date)
            }
        )
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        
        present(alert, animated: true)
    }
    
    private func configureDeleteAlert(for item: TimelineRecordItemViewData) {
        guard case let .deworming(record)? = item.rawRecord else { return }
        
        let alert = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this deworming record?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.viewModel.delete(record: record)
            }
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func configurePetDropdownLayout() {
        let itemHeight: CGFloat = 78
        let spacing: CGFloat = 12
        let count = CGFloat(petDropdownStackView.arrangedSubviews.count)
        
        let targetHeight: CGFloat
        if isPetDropdownOpen, count > 0 {
            targetHeight = (count * itemHeight) + ((count - 1) * spacing)
        } else {
            targetHeight = 0
        }
        
        petDropdownContainerHeightConstraint.constant = targetHeight
        petDropdownContainerView.alpha = isPetDropdownOpen ? 1 : 0
    }
    
    // MARK: - Actions
    
    private func togglePetDropdown(closeOnly: Bool = false) {
        if closeOnly {
            isPetDropdownOpen = false
        } else {
            isPetDropdownOpen.toggle()
        }
        
        configurePetDropdownLayout()
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addRecordTapped() {
        guard let petId = currentData?.selectedPet.id else { return }
        
        let viewController = AddDewormingController(petId: petId)
        viewController.onRecordSaved = { [weak self] in
            self?.viewModel.load()
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
