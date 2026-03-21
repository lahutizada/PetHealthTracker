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
        label.font = .systemFont(ofSize: 30, weight: .bold)
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
        return view
    }()
    
    private lazy var quickActionsTitle: UILabel = {
        let label = UILabel()
        label.text = "Quick Actions"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeActionButton(title: "Add Pet", icon: "pawprint.fill", action: #selector(addPetTapped)),
            makeActionButton(title: "Reminders", icon: "bell.fill", action: #selector(addReminderTapped)),
            makeActionButton(title: "Health Log", icon: "heart.text.square.fill", action: #selector(addHealthLogTapped))
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var remindersTitle: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Reminders"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reminderCard1 = ReminderCardView(
        title: "Vaccination",
        subtitle: "No reminders yet",
        icon: "syringe.fill"
    )
    
    private lazy var reminderCard2 = ReminderCardView(
        title: "Vet Checkup",
        subtitle: "Add reminders to see them here",
        icon: "cross.case.fill"
    )
    
    private lazy var remindersStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reminderCard1, reminderCard2])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var summaryTitle: UILabel = {
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
    
    private lazy var petsTitleLabel = makeMetricTitle("Pets")
    private lazy var petsValueLabel = makeMetricValue("0")
    
    private lazy var speciesTitleLabel = makeMetricTitle("Species")
    private lazy var speciesValueLabel = makeMetricValue("—")
    
    private lazy var mainPetTitleLabel = makeMetricTitle("Main Pet")
    private lazy var mainPetValueLabel = makeMetricValue("—")
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadHomeFromNotification),
            name: .highlightedPetChanged,
            object: nil
        )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPetDetails))
        petCardView.addGestureRecognizer(tap)
        
        petCardView.onActionTapped = { [weak self] in
            self?.openAddPet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadHome()
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(greetingLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(petCardView)
        contentView.addSubview(quickActionsTitle)
        contentView.addSubview(actionsStackView)
        contentView.addSubview(remindersTitle)
        contentView.addSubview(remindersStackView)
        contentView.addSubview(summaryTitle)
        contentView.addSubview(summaryCardView)
        contentView.addSubview(loadingView)
        
        let metric1 = makeMetricStack(title: petsTitleLabel, value: petsValueLabel)
        let metric2 = makeMetricStack(title: speciesTitleLabel, value: speciesValueLabel)
        let metric3 = makeMetricStack(title: mainPetTitleLabel, value: mainPetValueLabel)
        
        let summaryStack = UIStackView(arrangedSubviews: [metric1, metric2, metric3])
        summaryStack.axis = .vertical
        summaryStack.spacing = 16
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        
        summaryCardView.addSubview(summaryStack)
        
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryCardView.topAnchor, constant: 20),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCardView.leadingAnchor, constant: 20),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCardView.trailingAnchor, constant: -20),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCardView.bottomAnchor, constant: -20),
            
            loadingView.centerXAnchor.constraint(equalTo: petCardView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: petCardView.centerYAnchor)
        ])
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
            
            quickActionsTitle.topAnchor.constraint(equalTo: petCardView.bottomAnchor, constant: 28),
            quickActionsTitle.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            quickActionsTitle.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            actionsStackView.topAnchor.constraint(equalTo: quickActionsTitle.bottomAnchor, constant: 14),
            actionsStackView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            remindersTitle.topAnchor.constraint(equalTo: actionsStackView.bottomAnchor, constant: 28),
            remindersTitle.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            remindersTitle.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            remindersStackView.topAnchor.constraint(equalTo: remindersTitle.bottomAnchor, constant: 14),
            remindersStackView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            remindersStackView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            summaryTitle.topAnchor.constraint(equalTo: remindersStackView.bottomAnchor, constant: 28),
            summaryTitle.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            summaryTitle.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            
            summaryCardView.topAnchor.constraint(equalTo: summaryTitle.bottomAnchor, constant: 14),
            summaryCardView.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            summaryCardView.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            summaryCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            isLoading ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
        }
        
        viewModel.onHomeLoaded = { [weak self] viewData in
            self?.applyData(viewData)
        }
        
        viewModel.onError = { error in
            print("Home error:", error)
        }
    }
    
    private func applyData(_ viewData: HomeViewData) {
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
    
    private func makeActionButton(title: String, icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .mainBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .onboardingBlack
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(iconView)
        button.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 92),
            
            iconView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func makeMetricTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        return label
    }
    
    private func makeMetricValue(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        return label
    }
    
    private func makeMetricStack(title: UILabel, value: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [title, value])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }
    
    @objc private func addPetTapped() {
        let vc = AddPetController()
        vc.onPetSaved = { [weak self] _ in
            self?.viewModel.reloadHome()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addReminderTapped() {
        let vc = RemindersController()
        navigationController?.pushViewController(vc, animated: true)
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
            let vc = PetDetailsController(pet: pet)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            openAddPet()
        }
    }
    
    private func openAddPet() {
        let vc = AddPetController()
        vc.onPetSaved = { [weak self] _ in
            self?.viewModel.reloadHome()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
