//
//  HomeController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class HomeController: BaseController {
    
    private let viewModel: HomeViewModelProtocol
    private var currentPet: PetResponse?
    
    init(viewModel: HomeViewModelProtocol = DIContainer.shared.makeHomeViewModel()) {
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
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello 👋"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Here’s your pet care overview for today"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petCardView: PetCardContentView = {
        let view = PetCardContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPetDetails))
        view.addGestureRecognizer(tap)
        
        view.onActionTapped = { [weak self] in
            self?.configureOpenAddPet()
        }
        
        return view
    }()
    
    private lazy var quickActionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick Actions"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addPetIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pawprint.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var addPetButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Pet"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var addPetButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addPetTapped), for: .touchUpInside)
        
        button.addSubview(addPetIconView)
        button.addSubview(addPetButtonTitleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 92),
            
            addPetIconView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            addPetIconView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            addPetIconView.widthAnchor.constraint(equalToConstant: 22),
            addPetIconView.heightAnchor.constraint(equalToConstant: 22),
            
            addPetButtonTitleLabel.topAnchor.constraint(equalTo: addPetIconView.bottomAnchor, constant: 10),
            addPetButtonTitleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            addPetButtonTitleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        return button
    }()
    
    private lazy var remindersIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bell.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var remindersButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reminders"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var remindersButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addReminderTapped), for: .touchUpInside)
        
        button.addSubview(remindersIconView)
        button.addSubview(remindersButtonTitleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 92),
            
            remindersIconView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            remindersIconView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            remindersIconView.widthAnchor.constraint(equalToConstant: 22),
            remindersIconView.heightAnchor.constraint(equalToConstant: 22),
            
            remindersButtonTitleLabel.topAnchor.constraint(equalTo: remindersIconView.bottomAnchor, constant: 10),
            remindersButtonTitleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            remindersButtonTitleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        return button
    }()
    
    private lazy var healthLogIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.text.square.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var healthLogButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Health Log"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var healthLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addHealthLogTapped), for: .touchUpInside)
        
        button.addSubview(healthLogIconView)
        button.addSubview(healthLogButtonTitleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 92),
            
            healthLogIconView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            healthLogIconView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            healthLogIconView.widthAnchor.constraint(equalToConstant: 22),
            healthLogIconView.heightAnchor.constraint(equalToConstant: 22),
            
            healthLogButtonTitleLabel.topAnchor.constraint(equalTo: healthLogIconView.bottomAnchor, constant: 10),
            healthLogButtonTitleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            healthLogButtonTitleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        return button
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            addPetButton,
            remindersButton,
            healthLogButton
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var remindersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Reminders"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reminderCard1: ReminderCardView = {
        let view = ReminderCardView(
            title: "Vaccination",
            subtitle: "No reminders yet",
            icon: "syringe.fill"
        )
        return view
    }()
    
    private lazy var reminderCard2: ReminderCardView = {
        let view = ReminderCardView(
            title: "Vet Checkup",
            subtitle: "Add reminders to see them here",
            icon: "cross.case.fill"
        )
        return view
    }()
    
    private lazy var remindersStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reminderCard1, reminderCard2])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Health Summary"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var summaryCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pets"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petsValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petsMetricStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [petsTitleLabel, petsValueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var speciesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Species"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var speciesValueLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var speciesMetricStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [speciesTitleLabel, speciesValueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainPetTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Main Pet"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainPetValueLabel: UILabel = {
        let label = UILabel()
        label.text = "—"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainPetMetricStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainPetTitleLabel, mainPetValueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var summaryStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            petsMetricStackView,
            speciesMetricStackView,
            mainPetMetricStackView
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
        viewModel.loadHome()
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            greetingLabel,
            subtitleLabel,
            petCardView,
            quickActionsTitleLabel,
            actionsStackView,
            remindersTitleLabel,
            remindersStackView,
            summaryTitleLabel,
            summaryCardView,
            loadingView
        ].forEach(contentView.addSubview)
        
        summaryCardView.addSubview(summaryStackView)
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
            
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            petCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            petCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            petCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            petCardView.heightAnchor.constraint(equalToConstant: 130),
            
            quickActionsTitleLabel.topAnchor.constraint(equalTo: petCardView.bottomAnchor, constant: 28),
            quickActionsTitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            quickActionsTitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            actionsStackView.topAnchor.constraint(equalTo: quickActionsTitleLabel.bottomAnchor, constant: 14),
            actionsStackView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            remindersTitleLabel.topAnchor.constraint(equalTo: actionsStackView.bottomAnchor, constant: 28),
            remindersTitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            remindersTitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            remindersStackView.topAnchor.constraint(equalTo: remindersTitleLabel.bottomAnchor, constant: 14),
            remindersStackView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            remindersStackView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            summaryTitleLabel.topAnchor.constraint(equalTo: remindersStackView.bottomAnchor, constant: 28),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            summaryTitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            summaryCardView.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 14),
            summaryCardView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            summaryCardView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            summaryCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            summaryStackView.topAnchor.constraint(equalTo: summaryCardView.topAnchor, constant: 20),
            summaryStackView.leadingAnchor.constraint(equalTo: summaryCardView.leadingAnchor, constant: 20),
            summaryStackView.trailingAnchor.constraint(equalTo: summaryCardView.trailingAnchor, constant: -20),
            summaryStackView.bottomAnchor.constraint(equalTo: summaryCardView.bottomAnchor, constant: -20),
            
            loadingView.centerXAnchor.constraint(equalTo: petCardView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: petCardView.centerYAnchor)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            isLoading ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
        }
        
        viewModel.onHomeLoaded = { [weak self] viewData in
            self?.configureData(viewData)
        }
        
        viewModel.onError = { error in
            print("Home error:", error)
        }
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadHomeFromNotification),
            name: .highlightedPetChanged,
            object: nil
        )
    }
    
    private func configureData(_ viewData: HomeViewData) {
        currentPet = viewData.currentPet
        
        greetingLabel.text = viewData.greetingText
        petsValueLabel.text = viewData.petsCountText
        speciesValueLabel.text = viewData.speciesText
        mainPetValueLabel.text = viewData.mainPetText
        
        if viewData.currentPet == nil {
            petCardView.configure(
                name: "No pets yet",
                info: "Tap to add your first pet",
                photoURL: nil,
                species: "DOG",
                statusText: "Get started",
                isMain: false,
                showChevron: true,
                actionTitle: "Add"
            )
        } else {
            let species = viewData.currentPet?.species ?? "DOG"
            
            petCardView.configure(
                name: viewData.petName,
                info: viewData.petInfo,
                photoURL: viewData.petPhotoURL,
                species: species,
                statusText: viewData.petStatusText,
                isMain: false,
                showChevron: true,
                actionTitle: nil
            )
            
            petCardView.alpha = 1.0
        }
    }
    
    private func configureOpenAddPet() {
        let viewController = AddPetController()
        viewController.onPetSaved = { [weak self] _ in
            self?.viewModel.reloadHome()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func addPetTapped() {
        configureOpenAddPet()
    }
    
    @objc private func addReminderTapped() {
        let viewController = RemindersController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func addHealthLogTapped() {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "Health Log screen will be added next.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func reloadHomeFromNotification() {
        viewModel.reloadHome()
    }
    
    @objc private func openPetDetails() {
        if let pet = currentPet {
            let viewController = PetDetailsController(pet: pet)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            configureOpenAddPet()
        }
    }
}
