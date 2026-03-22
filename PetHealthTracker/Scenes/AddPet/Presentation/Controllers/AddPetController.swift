//
//  AddPetController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit
import PhotosUI

final class AddPetController: BaseController {
    
    var onPetSaved: ((PetResponse) -> Void)?
    private let mode: PetFormMode
    private let viewModel: AddPetViewModelProtocol
    
    init(
        mode: PetFormMode = .create,
        viewModel: AddPetViewModelProtocol = DIContainer.shared.makeAddPetViewModel()
    ) {
        self.mode = mode
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Species: String {
        case dog = "DOG"
        case cat = "CAT"
    }
    
    enum Gender: String {
        case male = "MALE"
        case female = "FEMALE"
    }
    
    private var selectedSpecies: Species = .dog {
        didSet {
            selectedBreed = nil
            breedTextField.text = nil
            breedTextField.placeholder = "Select breed"
            breedPicker.reloadAllComponents()
        }
    }
    
    private var selectedGender: Gender = .male
    private var selectedBreed: String?
    private var selectedImage: UIImage?
    private var shouldRemovePhoto = false
    
    private let dogBreeds = [
        "Golden Retriever", "Labrador", "German Shepherd", "Poodle",
        "Bulldog", "Beagle", "Corgi", "Husky", "Mixed Breed"
    ]
    
    private let catBreeds = [
        "British Shorthair", "Persian", "Siamese", "Maine Coon",
        "Scottish Fold", "Sphynx", "Bengal", "Ragdoll", "Mixed Breed"
    ]
    
    private var currentBreeds: [String] {
        selectedSpecies == .dog ? dogBreeds : catBreeds
    }
    
    private let breedPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
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
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Pet"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var photoContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 70
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.mainBlue.withAlphaComponent(0.25).cgColor
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera")
        imageView.tintColor = .mainBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var editPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload Photo"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var uploadSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to choose from gallery"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petTypeLabel = makeSectionLabel("Pet Type")
    private lazy var genderLabel = makeSectionLabel("Gender")
    private lazy var petNameLabel = makeSectionLabel("Pet Name")
    private lazy var breedLabel = makeSectionLabel("Breed")
    private lazy var birthDateLabel = makeSectionLabel("Birth Date")
    private lazy var weightLabel = makeSectionLabel("Weight (kg)")
    
    private lazy var speciesToggle: PetOptionToggleView = {
        let view = PetOptionToggleView(items: [
            .init(title: "Dog", selectedIcon: "dog.blue", unselectedIcon: "dog.standard"),
            .init(title: "Cat", selectedIcon: "cat.blue", unselectedIcon: "cat.standard")
        ])
        view.onSelectionChanged = { [weak self] index in
            self?.selectedSpecies = index == 0 ? .dog : .cat
        }
        return view
    }()
    
    private lazy var genderToggle: PetOptionToggleView = {
        let view = PetOptionToggleView(items: [
            .init(title: "Male", selectedIcon: "male.blue", unselectedIcon: "male.standard"),
            .init(title: "Female", selectedIcon: "female.blue", unselectedIcon: "female.standard")
        ])
        view.onSelectionChanged = { [weak self] index in
            self?.selectedGender = index == 0 ? .male : .female
        }
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let tf = makeTextField("e.g., Bella")
        tf.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return tf
    }()
    
    private lazy var breedTextField: UITextField = {
        let tf = makeTextField("Select breed")
        tf.inputView = breedPicker
        tf.tintColor = .clear
        tf.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return tf
    }()
    
    private lazy var breedChevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var birthDateTextField: UITextField = {
        let tf = makeTextField("MM/DD/YYYY")
        tf.inputView = datePicker
        tf.tintColor = .clear
        tf.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return tf
    }()
    
    private lazy var birthDateIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var weightTextField: UITextField = {
        let tf = makeTextField("0.0")
        tf.keyboardType = .decimalPad
        tf.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return tf
    }()
    
    private lazy var neuteredCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var neuteredTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Neutered / Spayed"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var neuteredSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Is your pet sterilized?"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var neuteredSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .mainBlue
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private lazy var statusView = StatusMessageView()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Pet Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePickers()
        configureDatePicker()
        configureToolbars()
        observeKeyboard()
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            backButton, headerLabel,
            photoContainer, uploadTitleLabel, uploadSubtitleLabel,
            petTypeLabel, speciesToggle,
            genderLabel, genderToggle,
            petNameLabel, nameTextField,
            breedLabel, breedTextField, breedChevron,
            birthDateLabel, birthDateTextField, birthDateIcon,
            weightLabel, weightTextField,
            neuteredCard, statusView, saveButton
        ].forEach { contentView.addSubview($0) }
        
        photoContainer.addSubview(petImageView)
        photoContainer.addSubview(editPhotoButton)
        
        neuteredCard.addSubview(neuteredTitleLabel)
        neuteredCard.addSubview(neuteredSubtitleLabel)
        neuteredCard.addSubview(neuteredSwitch)
        
        breedTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 1))
        breedTextField.rightViewMode = .always
        
        birthDateTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 1))
        birthDateTextField.rightViewMode = .always
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
            
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            photoContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 28),
            photoContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoContainer.widthAnchor.constraint(equalToConstant: 140),
            photoContainer.heightAnchor.constraint(equalToConstant: 140),
            
            petImageView.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor),
            petImageView.centerYAnchor.constraint(equalTo: photoContainer.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 44),
            petImageView.heightAnchor.constraint(equalToConstant: 44),
            
            editPhotoButton.widthAnchor.constraint(equalToConstant: 36),
            editPhotoButton.heightAnchor.constraint(equalToConstant: 36),
            editPhotoButton.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor, constant: 4),
            editPhotoButton.bottomAnchor.constraint(equalTo: photoContainer.bottomAnchor, constant: 4),
            
            uploadTitleLabel.topAnchor.constraint(equalTo: photoContainer.bottomAnchor, constant: 18),
            uploadTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            uploadSubtitleLabel.topAnchor.constraint(equalTo: uploadTitleLabel.bottomAnchor, constant: 6),
            uploadSubtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            petTypeLabel.topAnchor.constraint(equalTo: uploadSubtitleLabel.bottomAnchor, constant: 30),
            petTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            petTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            speciesToggle.topAnchor.constraint(equalTo: petTypeLabel.bottomAnchor, constant: 10),
            speciesToggle.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            speciesToggle.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            
            genderLabel.topAnchor.constraint(equalTo: speciesToggle.bottomAnchor, constant: 24),
            genderLabel.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            genderLabel.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            
            genderToggle.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 10),
            genderToggle.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            genderToggle.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            
            petNameLabel.topAnchor.constraint(equalTo: genderToggle.bottomAnchor, constant: 24),
            petNameLabel.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            petNameLabel.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: petNameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            breedLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            breedLabel.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            breedLabel.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            
            breedTextField.topAnchor.constraint(equalTo: breedLabel.bottomAnchor, constant: 10),
            breedTextField.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            breedTextField.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            breedTextField.heightAnchor.constraint(equalToConstant: 56),
            
            breedChevron.centerYAnchor.constraint(equalTo: breedTextField.centerYAnchor),
            breedChevron.trailingAnchor.constraint(equalTo: breedTextField.trailingAnchor, constant: -18),
            breedChevron.widthAnchor.constraint(equalToConstant: 18),
            breedChevron.heightAnchor.constraint(equalToConstant: 18),
            
            birthDateLabel.topAnchor.constraint(equalTo: breedTextField.bottomAnchor, constant: 24),
            birthDateLabel.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            
            weightLabel.topAnchor.constraint(equalTo: breedTextField.bottomAnchor, constant: 24),
            weightLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10),
            
            birthDateTextField.topAnchor.constraint(equalTo: birthDateLabel.bottomAnchor, constant: 10),
            birthDateTextField.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            birthDateTextField.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
            birthDateTextField.heightAnchor.constraint(equalToConstant: 60),
            
            birthDateIcon.centerYAnchor.constraint(equalTo: birthDateTextField.centerYAnchor),
            birthDateIcon.trailingAnchor.constraint(equalTo: birthDateTextField.trailingAnchor, constant: -18),
            birthDateIcon.widthAnchor.constraint(equalToConstant: 18),
            birthDateIcon.heightAnchor.constraint(equalToConstant: 18),
            
            weightTextField.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 10),
            weightTextField.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10),
            weightTextField.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            weightTextField.heightAnchor.constraint(equalToConstant: 60),
            
            neuteredCard.topAnchor.constraint(equalTo: birthDateTextField.bottomAnchor, constant: 24),
            neuteredCard.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            neuteredCard.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            neuteredCard.heightAnchor.constraint(equalToConstant: 82),
            
            neuteredTitleLabel.topAnchor.constraint(equalTo: neuteredCard.topAnchor, constant: 16),
            neuteredTitleLabel.leadingAnchor.constraint(equalTo: neuteredCard.leadingAnchor, constant: 16),
            
            neuteredSubtitleLabel.topAnchor.constraint(equalTo: neuteredTitleLabel.bottomAnchor, constant: 6),
            neuteredSubtitleLabel.leadingAnchor.constraint(equalTo: neuteredTitleLabel.leadingAnchor),
            
            neuteredSwitch.centerYAnchor.constraint(equalTo: neuteredCard.centerYAnchor),
            neuteredSwitch.trailingAnchor.constraint(equalTo: neuteredCard.trailingAnchor, constant: -16),
            
            statusView.topAnchor.constraint(equalTo: neuteredCard.bottomAnchor, constant: 12),
            statusView.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: petTypeLabel.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: petTypeLabel.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 58),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -140)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.saveButton.isEnabled = !isLoading
            self.saveButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusView.show(message: message, style: .error)
            } else {
                self.statusView.hide()
            }
        }
        
        viewModel.onPetCreated = { [weak self] pet in
            guard let self else { return }
            self.statusView.hide()
            self.onPetSaved?(pet)
            self.closeScreen()
        }
    }
    
    private func configurePickers() {
        breedPicker.delegate = self
        breedPicker.dataSource = self
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        updateDateText()
    }
    
    private func configureToolbars() {
        breedTextField.inputAccessoryView = makeToolbar()
        birthDateTextField.inputAccessoryView = makeToolbar()
        birthDateTextField.inputView = datePicker
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
    
    private func applyModeIfNeeded() {
        shouldRemovePhoto = false
        
        switch mode {
        case .create:
            showPlaceholderIcon()
            
        case .edit(let pet):
            headerLabel.text = "Edit Pet"
            saveButton.setTitle("Save Changes", for: .normal)
            
            selectedSpecies = pet.species.uppercased() == "CAT" ? .cat : .dog
            speciesToggle.selectItem(at: selectedSpecies == .dog ? 0 : 1)
            
            selectedGender = pet.sex.uppercased() == "FEMALE" ? .female : .male
            genderToggle.selectItem(at: selectedGender == .male ? 0 : 1)
            
            nameTextField.text = pet.name
            selectedBreed = pet.breed
            breedTextField.text = pet.breed
            neuteredSwitch.isOn = pet.neutered
            
            if let weight = pet.weight {
                weightTextField.text = String(weight)
            }
            
            if let date = parseDate(pet.dob) {
                datePicker.date = date
                updateDateText()
            }
            
            if let photoUrl = pet.photoUrl,
               let url = URL(string: photoUrl) {
                showPetImage(from: url)
            } else {
                showPlaceholderIcon()
            }
        }
    }
    
    private func setAddPhotoButtonStyle() {
        editPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    
    private func setChangePhotoButtonStyle() {
        editPhotoButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
    }
    
    private func showPlaceholderIcon() {
        selectedImage = nil
        photoContainer.layer.borderWidth = 1.5
        
        petImageView.image = UIImage(systemName: "camera")
        petImageView.tintColor = .mainBlue
        petImageView.contentMode = .scaleAspectFit
        petImageView.layer.cornerRadius = 0
        petImageView.clipsToBounds = false
        
        petImageView.constraints.forEach {
            if $0.firstAttribute == .width || $0.firstAttribute == .height {
                $0.constant = 44
            }
        }
        
        setAddPhotoButtonStyle()
        
        UIView.animate(withDuration: 0.2) {
            self.photoContainer.layoutIfNeeded()
        }
    }
    
    private func showPetImage(_ image: UIImage) {
        photoContainer.layer.borderWidth = 0
        
        petImageView.image = image
        petImageView.tintColor = nil
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.cornerRadius = 70
        petImageView.clipsToBounds = true
        
        petImageView.constraints.forEach {
            if $0.firstAttribute == .width || $0.firstAttribute == .height {
                $0.constant = 140
            }
        }
        
        setChangePhotoButtonStyle()
        
        UIView.animate(withDuration: 0.25) {
            self.photoContainer.layoutIfNeeded()
        }
    }
    
    private func showPetImage(from url: URL) {
        photoContainer.layer.borderWidth = 0
        
        petImageView.tintColor = nil
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.cornerRadius = 70
        petImageView.clipsToBounds = true
        
        petImageView.constraints.forEach {
            if $0.firstAttribute == .width || $0.firstAttribute == .height {
                $0.constant = 140
            }
        }
        
        setChangePhotoButtonStyle()
        petImageView.setImage(from: url)
        
        UIView.animate(withDuration: 0.25) {
            self.photoContainer.layoutIfNeeded()
        }
    }
    
    private func openPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func removePhoto() {
        selectedImage = nil
        shouldRemovePhoto = true
        showPlaceholderIcon()
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
    
    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeTextField(_ placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 18, weight: .regular)
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 18
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPadding(18)
        return tf
    }
    
    private func updateDateText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        birthDateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc private func backTapped() {
        closeScreen()
    }
    
    @objc private func selectPhotoTapped() {
        let hasPhoto = selectedImage != nil || petImageView.image != UIImage(systemName: "camera")
        
        if hasPhoto {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            sheet.addAction(UIAlertAction(title: "Change Photo", style: .default) { _ in
                self.openPhotoPicker()
            })
            
            sheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
                self.removePhoto()
            })
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(sheet, animated: true)
        } else {
            openPhotoPicker()
        }
    }
    
    @objc private func doneTapped() {
        if breedTextField.isFirstResponder {
            let row = breedPicker.selectedRow(inComponent: 0)
            let breed = currentBreeds[row]
            selectedBreed = breed
            breedTextField.text = breed
        }
        
        if birthDateTextField.isFirstResponder {
            updateDateText()
        }
        
        view.endEditing(true)
    }
    
    @objc private func saveTapped() {
        let cleanWeight = weightTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        
        let weight = Double(cleanWeight ?? "")
        
        switch mode {
        case .create:
            viewModel.createPet(
                species: selectedSpecies.rawValue,
                name: nameTextField.text,
                sex: selectedGender.rawValue,
                neutered: neuteredSwitch.isOn,
                breed: selectedBreed ?? breedTextField.text,
                dob: formattedISODate(),
                weight: weight,
                image: selectedImage
            )
            
        case .edit(let pet):
            viewModel.updatePet(
                id: pet.id,
                species: selectedSpecies.rawValue,
                name: nameTextField.text,
                sex: selectedGender.rawValue,
                neutered: neuteredSwitch.isOn,
                breed: selectedBreed ?? breedTextField.text,
                dob: formattedISODate(),
                weight: weight,
                image: selectedImage,
                removePhoto: shouldRemovePhoto
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
        
        scrollView.contentInset.bottom = keyboardFrame.height + 32
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height + 32
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    private func formattedISODate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: datePicker.date)
    }
    
    private func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        
        let isoFormatterWithFraction = ISO8601DateFormatter()
        isoFormatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatterWithFraction.date(from: value) {
            return date
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.date(from: value)
    }
}

extension AddPetController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currentBreeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currentBreeds[row]
    }
}

extension AddPetController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self, let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.selectedImage = image
                self.shouldRemovePhoto = false
                self.showPetImage(image)
            }
        }
    }
}
