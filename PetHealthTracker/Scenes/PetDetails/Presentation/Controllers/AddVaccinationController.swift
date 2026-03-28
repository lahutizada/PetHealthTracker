//
//  AddVaccinationController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

//
//  AddVaccinationController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class AddVaccinationController: BaseController {
    
    var onRecordSaved: (() -> Void)?
    
    private let petId: String
    private let viewModel: AddVaccinationViewModelProtocol
    
    private var selectedVaccine: VaccineType = .rabies
    
    private let notesPlaceholder = "Add notes"
    
    init(
        petId: String,
        viewModel: AddVaccinationViewModelProtocol = AddVaccinationViewModel()
    ) {
        self.petId = petId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()
    
    private let vaccineTitleLabel = AddVaccinationController.makeSectionLabel("Vaccine")
    private let customNameTitleLabel = AddVaccinationController.makeSectionLabel("Custom Name")
    private let administeredDateTitleLabel = AddVaccinationController.makeSectionLabel("Administered Date")
    private let nextDueDateTitleLabel = AddVaccinationController.makeSectionLabel("Next Due Date")
    private let notesTitleLabel = AddVaccinationController.makeSectionLabel("Notes")
    
    private let vaccineButton = UIButton(type: .system)
    private let customNameField = UITextField()
    
    private let datePicker = UIDatePicker()
    private let nextDatePicker = UIDatePicker()
    private let notesTextView = UITextView()
    
    private let saveButton = AppButtonFactory.primary(
        title: "Save Vaccination",
        imageSystemName: "checkmark"
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var keyboardScrollView: UIScrollView? {
        scrollView
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "Add Vaccination"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        
        contentView.backgroundColor = .clear
        
        contentStack.axis = .vertical
        contentStack.spacing = 14
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(administeredDateChanged), for: .valueChanged)
        
        nextDatePicker.datePickerMode = .date
        nextDatePicker.preferredDatePickerStyle = .compact
        nextDatePicker.minimumDate = datePicker.date
        
        customNameField.placeholder = "Enter vaccine name"
        customNameField.backgroundColor = .white
        customNameField.layer.cornerRadius = 16
        customNameField.setLeftPadding(14)
        
        notesTextView.backgroundColor = .white
        notesTextView.layer.cornerRadius = 16
        notesTextView.font = .systemFont(ofSize: 16, weight: .regular)
        notesTextView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        notesTextView.text = notesPlaceholder
        notesTextView.textColor = .placeholderText
        notesTextView.delegate = self
        
        setupVaccineButton()
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        [scrollView, contentView, contentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(vaccineTitleLabel)
        contentStack.addArrangedSubview(vaccineButton)
        
        contentStack.addArrangedSubview(customNameTitleLabel)
        contentStack.addArrangedSubview(customNameField)
        
        contentStack.addArrangedSubview(administeredDateTitleLabel)
        contentStack.addArrangedSubview(makePickerContainer(datePicker))
        
        contentStack.addArrangedSubview(nextDueDateTitleLabel)
        contentStack.addArrangedSubview(makePickerContainer(nextDatePicker))
        
        contentStack.addArrangedSubview(notesTitleLabel)
        contentStack.addArrangedSubview(notesTextView)
        
        contentStack.addArrangedSubview(saveButton)
        
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
            
            contentStack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            vaccineButton.heightAnchor.constraint(equalToConstant: 54),
            customNameField.heightAnchor.constraint(equalToConstant: 50),
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupVaccineButton() {
        var config = UIButton.Configuration.filled()
        config.title = selectedVaccine.title
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .onboardingBlack
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        vaccineButton.configuration = config
        vaccineButton.layer.cornerRadius = 16
        vaccineButton.clipsToBounds = true
    }
    
    private func makePickerContainer(_ picker: UIDatePicker) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            container.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        return container
    }
    
    private static func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .onboardingGray
        return label
    }
    
    // MARK: - Actions
    
    @objc private func selectVaccine() {
        let alert = UIAlertController(title: "Select Vaccine", message: nil, preferredStyle: .actionSheet)
        
        viewModel.availableVaccines.forEach { type in
            alert.addAction(UIAlertAction(title: type.title, style: .default, handler: { [weak self] _ in
                self?.selectedVaccine = type
                self?.updateUI()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vaccineButton
            popover.sourceRect = vaccineButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func administeredDateChanged() {
        nextDatePicker.minimumDate = datePicker.date
        
        if nextDatePicker.date < datePicker.date {
            nextDatePicker.setDate(datePicker.date, animated: true)
        }
    }
    
    private func updateUI() {
        var config = vaccineButton.configuration
        config?.title = selectedVaccine.title
        vaccineButton.configuration = config
        
        let isCustom = selectedVaccine == .custom
        customNameTitleLabel.isHidden = !isCustom
        customNameField.isHidden = !isCustom
        
        if !isCustom {
            customNameField.text = nil
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func saveTapped() {
        let notes: String?
        if notesTextView.textColor == .placeholderText {
            notes = nil
        } else {
            let trimmed = notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            notes = trimmed.isEmpty ? nil : trimmed
        }
        
        viewModel.save(
            petId: petId,
            vaccineType: selectedVaccine,
            customName: customNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            administeredAt: datePicker.date,
            nextDueAt: nextDatePicker.date,
            notes: notes
        )
    }
    
    @objc private func endEditingTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.saveButton.isEnabled = !isLoading
            self.saveButton.alpha = isLoading ? 0.65 : 1.0
        }
        
        viewModel.onRecordSaved = { [weak self] _ in
            guard let self else { return }
            self.onRecordSaved?()
            self.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self, let message, !message.isEmpty else { return }
            
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension AddVaccinationController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            textView.text = notesPlaceholder
            textView.textColor = .placeholderText
        }
    }
}
