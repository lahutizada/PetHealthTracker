//
//  AddReminderController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class AddReminderController: BaseController {
    
    enum Mode {
        case create
        case edit(ReminderResponse)
    }
    
    var onReminderSaved: (() -> Void)?
    private let mode: Mode
    private let viewModel: AddReminderViewModelProtocol
    
    init(
        mode: Mode = .create,
        viewModel: AddReminderViewModelProtocol = DIContainer.shared.makeAddReminderViewModel()
    ) {
        self.mode = mode
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var petOptions: [ReminderPetItem] = []
    
    private let categoryOptions = [
        ReminderCategory.vet.title,
        ReminderCategory.vaccination.title,
        ReminderCategory.deworming.title,
        ReminderCategory.medication.title,
        ReminderCategory.grooming.title,
        ReminderCategory.shopping.title,
        ReminderCategory.general.title
    ]
    
    private let petPicker = UIPickerView()
    private let categoryPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    private var selectedPetIndex: Int = 0
    private var selectedCategory: String = "Vet Visit"
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
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
        label.text = "Add Reminder"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var heroCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var heroIconWrap: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var heroIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bell.badge.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var heroTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new task"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var heroSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set reminders for health, shopping, grooming and more."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var formCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleFieldLabel = makeFieldLabel("Reminder Title")
    private lazy var petFieldLabel = makeFieldLabel("Pet")
    private lazy var categoryFieldLabel = makeFieldLabel("Category")
    private lazy var dateFieldLabel = makeFieldLabel("Due Date")
    private lazy var notesFieldLabel = makeFieldLabel("Notes")
    
    private lazy var titleTextField: UITextField = {
        let tf = makeTextField("e.g. Vet Checkup")
        tf.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return tf
    }()
    
    private lazy var petTextField: UITextField = {
        let tf = makeTextField("Select pet")
        tf.inputView = petPicker
        tf.tintColor = .clear
        return tf
    }()
    
    private lazy var categoryTextField: UITextField = {
        let tf = makeTextField("Select category")
        tf.inputView = categoryPicker
        tf.tintColor = .clear
        tf.text = selectedCategory
        return tf
    }()
    
    private lazy var dateTextField: UITextField = {
        let tf = makeTextField("Select due date")
        tf.inputView = datePicker
        tf.tintColor = .clear
        return tf
    }()
    
    private lazy var notesTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .onboardingBlack
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statusView = StatusMessageView()
    
    private lazy var petChevron = makeTrailingIcon("chevron.down")
    private lazy var categoryChevron = makeTrailingIcon("chevron.down")
    private lazy var dateIcon = makeTrailingIcon("calendar")
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Reminder", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 58).isActive = true
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var helperLabel: UILabel = {
        let label = UILabel()
        label.text = "You can edit or reschedule this reminder later."
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePickers()
        configureDatePicker()
        configureToolbars()
        updateDateText()
        observeKeyboard()
        viewModel.loadPets()
        applyModeIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(heroCard)
        heroCard.addSubview(heroIconWrap)
        heroIconWrap.addSubview(heroIcon)
        heroCard.addSubview(heroTitleLabel)
        heroCard.addSubview(heroSubtitleLabel)
        
        contentView.addSubview(formCard)
        
        formCard.addSubview(titleFieldLabel)
        formCard.addSubview(titleTextField)
        
        formCard.addSubview(petFieldLabel)
        formCard.addSubview(petTextField)
        formCard.addSubview(petChevron)
        
        formCard.addSubview(categoryFieldLabel)
        formCard.addSubview(categoryTextField)
        formCard.addSubview(categoryChevron)
        
        formCard.addSubview(dateFieldLabel)
        formCard.addSubview(dateTextField)
        formCard.addSubview(dateIcon)
        
        formCard.addSubview(notesFieldLabel)
        formCard.addSubview(notesTextView)
        
        contentView.addSubview(statusView)
        contentView.addSubview(saveButton)
        contentView.addSubview(helperLabel)
        
        petTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 1))
        petTextField.rightViewMode = .always
        
        categoryTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 1))
        categoryTextField.rightViewMode = .always
        
        dateTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 1))
        dateTextField.rightViewMode = .always
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
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            heroCard.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            heroIconWrap.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            heroIconWrap.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            heroIconWrap.widthAnchor.constraint(equalToConstant: 48),
            heroIconWrap.heightAnchor.constraint(equalToConstant: 48),
            
            heroIcon.centerXAnchor.constraint(equalTo: heroIconWrap.centerXAnchor),
            heroIcon.centerYAnchor.constraint(equalTo: heroIconWrap.centerYAnchor),
            heroIcon.widthAnchor.constraint(equalToConstant: 20),
            heroIcon.heightAnchor.constraint(equalToConstant: 20),
            
            heroTitleLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 22),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 22),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroIconWrap.leadingAnchor, constant: -12),
            
            heroSubtitleLabel.topAnchor.constraint(equalTo: heroTitleLabel.bottomAnchor, constant: 8),
            heroSubtitleLabel.leadingAnchor.constraint(equalTo: heroTitleLabel.leadingAnchor),
            heroSubtitleLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -22),
            heroSubtitleLabel.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -22),
            
            formCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 24),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleFieldLabel.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 22),
            titleFieldLabel.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            
            titleTextField.topAnchor.constraint(equalTo: titleFieldLabel.bottomAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 56),
            
            petFieldLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            petFieldLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            petTextField.topAnchor.constraint(equalTo: petFieldLabel.bottomAnchor, constant: 10),
            petTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            petTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            petTextField.heightAnchor.constraint(equalToConstant: 56),
            
            petChevron.centerYAnchor.constraint(equalTo: petTextField.centerYAnchor),
            petChevron.trailingAnchor.constraint(equalTo: petTextField.trailingAnchor, constant: -18),
            petChevron.widthAnchor.constraint(equalToConstant: 18),
            petChevron.heightAnchor.constraint(equalToConstant: 18),
            
            categoryFieldLabel.topAnchor.constraint(equalTo: petTextField.bottomAnchor, constant: 20),
            categoryFieldLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            categoryTextField.topAnchor.constraint(equalTo: categoryFieldLabel.bottomAnchor, constant: 10),
            categoryTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            categoryTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            categoryTextField.heightAnchor.constraint(equalToConstant: 56),
            
            categoryChevron.centerYAnchor.constraint(equalTo: categoryTextField.centerYAnchor),
            categoryChevron.trailingAnchor.constraint(equalTo: categoryTextField.trailingAnchor, constant: -18),
            categoryChevron.widthAnchor.constraint(equalToConstant: 18),
            categoryChevron.heightAnchor.constraint(equalToConstant: 18),
            
            dateFieldLabel.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 20),
            dateFieldLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            dateTextField.topAnchor.constraint(equalTo: dateFieldLabel.bottomAnchor, constant: 10),
            dateTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            dateTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            dateTextField.heightAnchor.constraint(equalToConstant: 56),
            
            dateIcon.centerYAnchor.constraint(equalTo: dateTextField.centerYAnchor),
            dateIcon.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor, constant: -18),
            dateIcon.widthAnchor.constraint(equalToConstant: 18),
            dateIcon.heightAnchor.constraint(equalToConstant: 18),
            
            notesFieldLabel.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 20),
            notesFieldLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            notesTextView.topAnchor.constraint(equalTo: notesFieldLabel.bottomAnchor, constant: 10),
            notesTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            notesTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
            notesTextView.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -22),
            
            statusView.topAnchor.constraint(equalTo: formCard.bottomAnchor, constant: 16),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            helperLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            helperLabel.leadingAnchor.constraint(equalTo: saveButton.leadingAnchor),
            helperLabel.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor),
            helperLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.saveButton.isEnabled = !isLoading
            self.saveButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onPetsLoaded = { [weak self] items in
            guard let self else { return }
            self.petOptions = items
            self.petPicker.reloadAllComponents()
            
            switch self.mode {
            case .create:
                if let first = items.first {
                    self.selectedPetIndex = 0
                    self.petTextField.text = first.name
                } else {
                    self.petTextField.text = "No pets available"
                }
                
            case .edit(let reminder):
                if let index = items.firstIndex(where: { $0.id == reminder.petId }) {
                    self.selectedPetIndex = index
                    self.petTextField.text = items[index].name
                    self.petPicker.selectRow(index, inComponent: 0, animated: false)
                } else if let first = items.first {
                    self.selectedPetIndex = 0
                    self.petTextField.text = first.name
                } else {
                    self.petTextField.text = "No pets available"
                }
            }
        }
        
        viewModel.onReminderSaved = { [weak self] _ in
            guard let self else { return }
            self.onReminderSaved?()
            self.closeScreen()
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusView.show(message: message, style: .error)
            } else {
                self.statusView.hide()
            }
        }
    }
    
    private func applyModeIfNeeded() {
        switch mode {
        case .create:
            titleLabel.text = "Add Reminder"
            heroTitleLabel.text = "Create a new task"
            heroSubtitleLabel.text = "Set reminders for health, shopping, grooming and more."
            saveButton.setTitle("Save Reminder", for: .normal)
            
        case .edit(let item):
            titleLabel.text = "Edit Reminder"
            heroTitleLabel.text = "Update reminder"
            heroSubtitleLabel.text = "Edit details, reschedule or change category."
            saveButton.setTitle("Save Changes", for: .normal)
            
            titleTextField.text = item.title
            notesTextView.text = item.notes
            
            if let dueDateString = item.dueDate {
                let isoWithFraction = ISO8601DateFormatter()
                isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime]
                
                if let date = isoWithFraction.date(from: dueDateString) ?? iso.date(from: dueDateString) {
                    datePicker.date = date
                    updateDateText()
                }
            }
            
            if let type = item.type,
               let categoryIndex = categoryOptions.firstIndex(where: { $0.lowercased() == type.lowercased() }) {
                selectedCategory = categoryOptions[categoryIndex]
                categoryTextField.text = selectedCategory
                categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: false)
            }
        }
    }
    
    private func configurePickers() {
        petPicker.delegate = self
        petPicker.dataSource = self
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        
        switch mode {
        case .create:
            datePicker.minimumDate = Date()
        case .edit:
            datePicker.minimumDate = nil
        }
    }
    
    private func configureToolbars() {
        let toolbar = makeToolbar()
        petTextField.inputAccessoryView = toolbar
        categoryTextField.inputAccessoryView = toolbar
        dateTextField.inputAccessoryView = toolbar
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func updateDateText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(title: "Done", style: .prominent, target: self, action: #selector(doneTapped))
        ]
        return toolbar
    }
    
    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeTextField(_ placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 18
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(18)
        return tf
    }
    
    private func makeTrailingIcon(_ systemName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    @objc private func backTapped() {
        closeScreen()
    }
    
    @objc private func doneTapped() {
        if petTextField.isFirstResponder {
            let row = petPicker.selectedRow(inComponent: 0)
            if petOptions.indices.contains(row) {
                selectedPetIndex = row
                petTextField.text = petOptions[row].name
            }
        }
        
        if categoryTextField.isFirstResponder {
            let row = categoryPicker.selectedRow(inComponent: 0)
            selectedCategory = categoryOptions[row]
            categoryTextField.text = selectedCategory
        }
        
        if dateTextField.isFirstResponder {
            updateDateText()
        }
        
        view.endEditing(true)
    }
    
    @objc private func saveTapped() {
        print("SAVE TAPPED")
        switch mode {
        case .create:
            viewModel.createReminder(
                title: titleTextField.text,
                notes: notesTextView.text,
                dueDate: datePicker.date,
                category: selectedCategory,
                selectedPetIndex: selectedPetIndex
            )
            
        case .edit(let reminder):
            viewModel.updateReminder(
                id: reminder.id,
                title: titleTextField.text,
                notes: notesTextView.text,
                dueDate: datePicker.date,
                category: selectedCategory,
                selectedPetIndex: selectedPetIndex
            )
        }
    }
    
    private func closeScreen() {
        if let navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else if navigationController?.presentingViewController != nil {
            navigationController?.dismiss(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        }
    }
    
    @objc private func clearError() {
        viewModel.clearError()
        statusView.hide()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        scrollView.contentInset.bottom = keyboardFrame.height + 24
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height + 24
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}

extension AddReminderController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == petPicker {
            return petOptions.count
        }
        return categoryOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == petPicker {
            return petOptions[row].name
        }
        return categoryOptions[row]
    }
}
