//
//  AddDewormingController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class AddDewormingController: BaseController {
    
    var onRecordSaved: (() -> Void)?
    
    private let petId: String
    private let viewModel: AddDewormingViewModelProtocol
    
    private let notesPlaceholder = "Add notes"
    
    init(
        petId: String,
        viewModel: AddDewormingViewModelProtocol = AddDewormingViewModel()
    ) {
        self.petId = petId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()
    
    private let productTitleLabel = AddDewormingController.makeSectionLabel("Product Name")
    private let administeredDateTitleLabel = AddDewormingController.makeSectionLabel("Administered Date")
    private let nextDueDateTitleLabel = AddDewormingController.makeSectionLabel("Next Due Date")
    private let notesTitleLabel = AddDewormingController.makeSectionLabel("Notes")
    
    private let productField = UITextField()
    private let notesTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let nextDatePicker = UIDatePicker()
    
    private lazy var saveButton: UIButton = {
        let button = AppButtonFactory.primary(
            title: "Save Deworming",
            imageSystemName: "checkmark"
        )
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "Add Deworming"
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        
        contentStack.axis = .vertical
        contentStack.spacing = 14
        
        productField.placeholder = "Enter product name"
        productField.backgroundColor = .white
        productField.layer.cornerRadius = 16
        productField.setLeftPadding(14)
        
        notesTextView.backgroundColor = .white
        notesTextView.layer.cornerRadius = 16
        notesTextView.font = .systemFont(ofSize: 16, weight: .regular)
        notesTextView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        notesTextView.text = notesPlaceholder
        notesTextView.textColor = .placeholderText
        notesTextView.delegate = self
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(administeredDateChanged), for: .valueChanged)
        
        nextDatePicker.datePickerMode = .date
        nextDatePicker.preferredDatePickerStyle = .compact
        nextDatePicker.minimumDate = datePicker.date
        
        [scrollView, contentView, contentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(productTitleLabel)
        contentStack.addArrangedSubview(productField)
        
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
            
            productField.heightAnchor.constraint(equalToConstant: 50),
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    override var keyboardScrollView: UIScrollView? {
        scrollView
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
    
    // MARK: - Actions
    
    @objc private func saveTapped() {
        let trimmedProduct = productField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let notes: String?
        if notesTextView.textColor == .placeholderText {
            notes = nil
        } else {
            let trimmed = notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            notes = trimmed.isEmpty ? nil : trimmed
        }
        
        viewModel.save(
            petId: petId,
            productName: trimmedProduct,
            administeredAt: datePicker.date,
            nextDueAt: nextDatePicker.date,
            notes: notes
        )
    }
    
    @objc private func administeredDateChanged() {
        nextDatePicker.minimumDate = datePicker.date
        
        if nextDatePicker.date < datePicker.date {
            nextDatePicker.setDate(datePicker.date, animated: true)
        }
    }
    
    @objc private func endEditingTapped() {
        view.endEditing(true)
    }
}

extension AddDewormingController: UITextViewDelegate {
    
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
