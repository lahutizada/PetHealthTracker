//
//  VaccinationRecordsController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class VaccinationRecordsController: BaseController {
    
    private let viewModel: VaccinationRecordsViewModelProtocol
    
    private var isPetDropdownOpen = false
    private var currentData: VaccinationRecordsScreenViewData?
    
    private var timelineTopToHeader: NSLayoutConstraint!
    private var timelineTopToDropdown: NSLayoutConstraint!
    
    init(viewModel: VaccinationRecordsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(petId: String) {
        self.init(viewModel: VaccinationRecordsViewModel(petId: petId))
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
        label.text = "Vaccination Records"
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
    
    private lazy var petDropdownStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
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
        label.text = "Track immunization history & upcoming doses."
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
        label.text = "No vaccination records yet"
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
            petDropdownStackView,
            timelineTitleLabel,
            timelineSubtitleLabel,
            addRecordButton,
            timelineStackView,
            emptyStateLabel
        ].forEach(contentView.addSubview)
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
            
            petDropdownStackView.topAnchor.constraint(equalTo: selectedPetHeaderView.bottomAnchor, constant: 12),
            petDropdownStackView.leadingAnchor.constraint(equalTo: selectedPetHeaderView.leadingAnchor),
            petDropdownStackView.trailingAnchor.constraint(equalTo: selectedPetHeaderView.trailingAnchor),
            
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
            timelineStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            emptyStateLabel.topAnchor.constraint(equalTo: timelineSubtitleLabel.bottomAnchor, constant: 30),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
        
        timelineTopToHeader = timelineTitleLabel.topAnchor.constraint(
            equalTo: selectedPetHeaderView.bottomAnchor,
            constant: 24
        )
        
        timelineTopToDropdown = timelineTitleLabel.topAnchor.constraint(
            equalTo: petDropdownStackView.bottomAnchor,
            constant: 24
        )
        
        timelineTopToHeader.isActive = true
        timelineTopToDropdown.isActive = false
    }
    
    override func configureViewModel() {
        viewModel.onDataLoaded = { [weak self] data in
            self?.configureData(data)
        }
        
        viewModel.onRecordAction = { [weak self] raw in
            self?.configureRecordAction(raw)
        }
    }
    
    // MARK: - Data
    
    private func configureData(_ data: VaccinationRecordsScreenViewData) {
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
        
        emptyStateLabel.isHidden = !data.items.isEmpty
        timelineStackView.isHidden = data.items.isEmpty
        
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
        
        view.layoutIfNeeded()
    }
    
    private func configureRecordAction(_ raw: TimelineRawRecord) {
        guard case let .vaccination(record) = raw else { return }
        
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
    
    private func configureStatus(for record: VaccinationRecordResponse) -> HealthRecordStatus {
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
    
    private func configureMarkCompleteAlert(for record: VaccinationRecordResponse) {
        let alert = UIAlertController(
            title: "Mark as Complete",
            message: "Do you want to mark this vaccination as completed?",
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
    
    private func configureReschedulePicker(for record: VaccinationRecordResponse) {
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
        guard case let .vaccination(record)? = item.rawRecord else { return }
        
        let alert = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this vaccination record?",
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
    
    // MARK: - Actions
    
    private func togglePetDropdown(closeOnly: Bool = false) {
        if closeOnly {
            isPetDropdownOpen = false
        } else {
            isPetDropdownOpen.toggle()
        }
        
        petDropdownStackView.isHidden = !isPetDropdownOpen
        
        timelineTopToHeader.isActive = !isPetDropdownOpen
        timelineTopToDropdown.isActive = isPetDropdownOpen
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addRecordTapped() {
        guard let petId = currentData?.selectedPet.id else { return }
        
        let viewController = AddVaccinationController(petId: petId)
        viewController.onRecordSaved = { [weak self] in
            self?.viewModel.load()
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
