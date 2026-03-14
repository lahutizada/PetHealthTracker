//
//  HomeController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class HomeController: BaseController {
    
    // MARK: - Data
    private var currentUser: UserResponse?
    private var pets: [PetResponse] = []
    
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petCardView: UIView = {
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
    
    private lazy var petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dogPlaceholder")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var petNameLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets yet"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your first pet to get started"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var petStatusBadge: UILabel = {
        let label = UILabel()
        label.text = " Ready "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemGreen
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
            makeActionButton(title: "Reminder", icon: "bell.fill", action: #selector(addReminderTapped)),
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
    
    private lazy var weightTitleLabel = makeMetricTitle("Pets")
    private lazy var weightValueLabel = makeMetricValue("0")
    
    private lazy var vaccinesTitleLabel = makeMetricTitle("Species")
    private lazy var vaccinesValueLabel = makeMetricValue("—")
    
    private lazy var nextVisitTitleLabel = makeMetricTitle("Main Pet")
    private lazy var nextVisitValueLabel = makeMetricValue("—")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadHomeFromNotification),
            name: .highlightedPetChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHomeData()
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        title = ""
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(greetingLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.addSubview(petCardView)
        petCardView.addSubview(petImageView)
        petCardView.addSubview(petNameLabel)
        petCardView.addSubview(petInfoLabel)
        petCardView.addSubview(petStatusBadge)
        
        contentView.addSubview(quickActionsTitle)
        contentView.addSubview(actionsStackView)
        
        contentView.addSubview(remindersTitle)
        contentView.addSubview(remindersStackView)
        
        contentView.addSubview(summaryTitle)
        contentView.addSubview(summaryCardView)
        
        let metric1 = makeMetricStack(title: weightTitleLabel, value: weightValueLabel)
        let metric2 = makeMetricStack(title: vaccinesTitleLabel, value: vaccinesValueLabel)
        let metric3 = makeMetricStack(title: nextVisitTitleLabel, value: nextVisitValueLabel)
        
        let summaryStack = UIStackView(arrangedSubviews: [metric1, metric2, metric3])
        summaryStack.axis = .vertical
        summaryStack.spacing = 16
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        
        summaryCardView.addSubview(summaryStack)
        
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryCardView.topAnchor, constant: 20),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCardView.leadingAnchor, constant: 20),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCardView.trailingAnchor, constant: -20),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCardView.bottomAnchor, constant: -20)
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
            
            petImageView.topAnchor.constraint(equalTo: petCardView.topAnchor, constant: 20),
            petImageView.leadingAnchor.constraint(equalTo: petCardView.leadingAnchor, constant: 20),
            petImageView.widthAnchor.constraint(equalToConstant: 60),
            petImageView.heightAnchor.constraint(equalToConstant: 60),
            
            petNameLabel.topAnchor.constraint(equalTo: petCardView.topAnchor, constant: 20),
            petNameLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 16),
            petNameLabel.trailingAnchor.constraint(equalTo: petCardView.trailingAnchor, constant: -20),
            
            petInfoLabel.topAnchor.constraint(equalTo: petNameLabel.bottomAnchor, constant: 6),
            petInfoLabel.leadingAnchor.constraint(equalTo: petNameLabel.leadingAnchor),
            petInfoLabel.trailingAnchor.constraint(equalTo: petNameLabel.trailingAnchor),
            
            petStatusBadge.topAnchor.constraint(equalTo: petInfoLabel.bottomAnchor, constant: 10),
            petStatusBadge.leadingAnchor.constraint(equalTo: petNameLabel.leadingAnchor),
            petStatusBadge.bottomAnchor.constraint(equalTo: petCardView.bottomAnchor, constant: -20),
            
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
    
    override func configureViewModel() {}
    
    private func loadHomeData() {
        Task {
            do {
                async let meRequest = AuthService.shared.me()
                async let petsRequest = PetService.shared.getPets()
                
                let (me, pets) = try await (meRequest, petsRequest)
                
                DispatchQueue.main.async {
                    self.currentUser = me
                    self.pets = pets
                    self.applyData()
                }
            } catch {
                print("Home load error:", error)
            }
        }
    }
    
    private func applyData() {
        let emailName = currentUser?.email.components(separatedBy: "@").first ?? "Friend"
        greetingLabel.text = "Hello, \(emailName) 👋"
        
        let highlightedPet = pets.first(where: { $0.isHighlighted == true }) ?? pets.first
        
        if let pet = highlightedPet {
            petNameLabel.text = pet.name
            petInfoLabel.text = "\(pet.species.capitalized) • \(pet.breed ?? "Unknown breed")"
            petStatusBadge.text = " Active "
            weightValueLabel.text = "\(pets.count)"
            vaccinesValueLabel.text = pet.species.capitalized
            nextVisitValueLabel.text = pet.name
        } else {
            petNameLabel.text = "No pets yet"
            petInfoLabel.text = "Add your first pet to get started"
            petStatusBadge.text = " Ready "
            weightValueLabel.text = "0"
            vaccinesValueLabel.text = "—"
            nextVisitValueLabel.text = "—"
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
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addReminderTapped() {
        let vc = AddReminderController()
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
        loadHomeData()
    }
}
