//
//  PetDetailsController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

final class PetDetailsController: BaseController {
    
    private let viewModel: PetDetailsViewModelProtocol
    private var pet: PetResponse

    init(pet: PetResponse, viewModel: PetDetailsViewModelProtocol? = nil) {
        self.pet = pet
        self.viewModel = viewModel ??
        DIContainer.shared.makePetDetailsViewModel(petId: pet.id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .onboardingBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pet Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .onboardingBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 62
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pawprint.fill")
        imageView.tintColor = .mainBlue
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        imageView.layer.cornerRadius = 62
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)
        return imageView
    }()
    
    private lazy var petTypeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBlue
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petTypeBadgeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pawprint.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var mainActionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Main Pet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(mainActionTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Stat Cards
    
    private lazy var weightCard = makeStatCard(title: "WEIGHT")
    private lazy var sexCard = makeStatCard(title: "SEX")
    private lazy var ageCard = makeStatCard(title: "AGE")
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            weightCard.container,
            sexCard.container,
            ageCard.container
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Growth
    
    private lazy var growthCard: UIView = makeWhiteCard()
    
    private lazy var growthIconWrap: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var growthIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var growthTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Growth Progress"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var growthSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pet development"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var growthWeekBadge: UILabel = {
        let label = UILabel()
        label.text = "Week 12"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .mainBlue
        label.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressLeftLabel = makeSmallGrayLabel("0 weeks")
    
    private lazy var progressCenterLabel: UILabel = {
        let label = UILabel()
        label.text = "23% Complete"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressRightLabel = makeSmallGrayLabel("52 weeks")
    
    private lazy var progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBlue
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var growthDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Healthy progress so far. Keep tracking weight and reminders regularly."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Health Overview
    
    private lazy var healthTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Health Overview"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var healthViewAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View All", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var vaccinationCard = makeOverviewCard(
        icon: "cross.vial.fill",
        iconBackground: UIColor.systemGreen.withAlphaComponent(0.16),
        iconTint: .systemGreen,
        title: "Vaccinations",
        subtitle: "Next due: Rabies",
        badgeText: "ON TRACK",
        badgeTextColor: .systemGreen,
        badgeBackground: UIColor.systemGreen.withAlphaComponent(0.14)
    )
    
    private lazy var activityCard = makeOverviewCard(
        icon: "figure.walk",
        iconBackground: UIColor.systemOrange.withAlphaComponent(0.16),
        iconTint: .systemOrange,
        title: "Activity",
        subtitle: "Avg 45 mins/day",
        badgeText: "NEEDS WORK",
        badgeTextColor: .systemOrange,
        badgeBackground: UIColor.systemOrange.withAlphaComponent(0.14)
    )
    
    private lazy var healthCardsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            vaccinationCard.container,
            activityCard.container
        ])
        stack.axis = .horizontal
        stack.spacing = 14
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Upcoming Visit
    
    private lazy var upcomingVisitCard: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBlue
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var upcomingVisitTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Vet Visit"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var upcomingVisitBadge: UILabel = {
        let label = UILabel()
        label.text = "In 3 days"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visitDateCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.layer.cornerRadius = 38
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var visitMonthLabel: UILabel = {
        let label = UILabel()
        label.text = "OCT"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visitDayLabel: UILabel = {
        let label = UILabel()
        label.text = "14"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visitTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "General Checkup"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visitSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PetCare Clinic"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visitTimeBadge: UILabel = {
        let label = UILabel()
        label.text = "◷ 10:30 AM"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        petImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)
        
        contentView.addSubview(backButton)
        contentView.addSubview(screenTitleLabel)
        contentView.addSubview(editButton)
        
        contentView.addSubview(avatarContainer)
        avatarContainer.addSubview(petImageView)
        
        contentView.addSubview(petTypeBadge)
        petTypeBadge.addSubview(petTypeBadgeIcon)
        
        contentView.addSubview(mainActionButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.addSubview(statsStackView)
        
        contentView.addSubview(growthCard)
        growthCard.addSubview(growthIconWrap)
        growthIconWrap.addSubview(growthIcon)
        growthCard.addSubview(growthTitleLabel)
        growthCard.addSubview(growthSubtitleLabel)
        growthCard.addSubview(growthWeekBadge)
        growthCard.addSubview(progressLeftLabel)
        growthCard.addSubview(progressCenterLabel)
        growthCard.addSubview(progressRightLabel)
        growthCard.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        growthCard.addSubview(growthDescriptionLabel)
        
        contentView.addSubview(healthTitleLabel)
        contentView.addSubview(healthViewAllButton)
        contentView.addSubview(healthCardsStackView)
        
        contentView.addSubview(upcomingVisitCard)
        upcomingVisitCard.addSubview(upcomingVisitTitleLabel)
        upcomingVisitCard.addSubview(upcomingVisitBadge)
        upcomingVisitCard.addSubview(visitDateCircle)
        visitDateCircle.addSubview(visitMonthLabel)
        visitDateCircle.addSubview(visitDayLabel)
        upcomingVisitCard.addSubview(visitTitleLabel)
        upcomingVisitCard.addSubview(visitSubtitleLabel)
        upcomingVisitCard.addSubview(visitTimeBadge)
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
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            screenTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            screenTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            editButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            
            avatarContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 28),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 124),
            avatarContainer.heightAnchor.constraint(equalToConstant: 124),
            
            petImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            petImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            petImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            petImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            
            petTypeBadge.widthAnchor.constraint(equalToConstant: 36),
            petTypeBadge.heightAnchor.constraint(equalToConstant: 36),
            petTypeBadge.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 6),
            petTypeBadge.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 6),
            
            petTypeBadgeIcon.centerXAnchor.constraint(equalTo: petTypeBadge.centerXAnchor),
            petTypeBadgeIcon.centerYAnchor.constraint(equalTo: petTypeBadge.centerYAnchor),
            petTypeBadgeIcon.widthAnchor.constraint(equalToConstant: 18),
            petTypeBadgeIcon.heightAnchor.constraint(equalToConstant: 18),
            
            mainActionButton.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            mainActionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainActionButton.widthAnchor.constraint(equalToConstant: 110),
            mainActionButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: mainActionButton.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            growthCard.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 24),
            growthCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            growthCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            growthIconWrap.topAnchor.constraint(equalTo: growthCard.topAnchor, constant: 20),
            growthIconWrap.leadingAnchor.constraint(equalTo: growthCard.leadingAnchor, constant: 20),
            growthIconWrap.widthAnchor.constraint(equalToConstant: 40),
            growthIconWrap.heightAnchor.constraint(equalToConstant: 40),
            
            growthIcon.centerXAnchor.constraint(equalTo: growthIconWrap.centerXAnchor),
            growthIcon.centerYAnchor.constraint(equalTo: growthIconWrap.centerYAnchor),
            growthIcon.widthAnchor.constraint(equalToConstant: 18),
            growthIcon.heightAnchor.constraint(equalToConstant: 18),
            
            growthTitleLabel.topAnchor.constraint(equalTo: growthCard.topAnchor, constant: 20),
            growthTitleLabel.leadingAnchor.constraint(equalTo: growthIconWrap.trailingAnchor, constant: 14),
            
            growthSubtitleLabel.topAnchor.constraint(equalTo: growthTitleLabel.bottomAnchor, constant: 4),
            growthSubtitleLabel.leadingAnchor.constraint(equalTo: growthTitleLabel.leadingAnchor),
            
            growthWeekBadge.centerYAnchor.constraint(equalTo: growthTitleLabel.centerYAnchor),
            growthWeekBadge.trailingAnchor.constraint(equalTo: growthCard.trailingAnchor, constant: -20),
            growthWeekBadge.widthAnchor.constraint(equalToConstant: 90),
            growthWeekBadge.heightAnchor.constraint(equalToConstant: 28),
            
            progressLeftLabel.topAnchor.constraint(equalTo: growthIconWrap.bottomAnchor, constant: 18),
            progressLeftLabel.leadingAnchor.constraint(equalTo: growthCard.leadingAnchor, constant: 20),
            
            progressCenterLabel.centerYAnchor.constraint(equalTo: progressLeftLabel.centerYAnchor),
            progressCenterLabel.centerXAnchor.constraint(equalTo: growthCard.centerXAnchor),
            
            progressRightLabel.centerYAnchor.constraint(equalTo: progressLeftLabel.centerYAnchor),
            progressRightLabel.trailingAnchor.constraint(equalTo: growthCard.trailingAnchor, constant: -20),
            
            progressTrackView.topAnchor.constraint(equalTo: progressLeftLabel.bottomAnchor, constant: 10),
            progressTrackView.leadingAnchor.constraint(equalTo: growthCard.leadingAnchor, constant: 20),
            progressTrackView.trailingAnchor.constraint(equalTo: growthCard.trailingAnchor, constant: -20),
            progressTrackView.heightAnchor.constraint(equalToConstant: 12),
            
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: 0.23),
            
            growthDescriptionLabel.topAnchor.constraint(equalTo: progressTrackView.bottomAnchor, constant: 16),
            growthDescriptionLabel.leadingAnchor.constraint(equalTo: growthCard.leadingAnchor, constant: 20),
            growthDescriptionLabel.trailingAnchor.constraint(equalTo: growthCard.trailingAnchor, constant: -20),
            growthDescriptionLabel.bottomAnchor.constraint(equalTo: growthCard.bottomAnchor, constant: -20),
            
            healthTitleLabel.topAnchor.constraint(equalTo: growthCard.bottomAnchor, constant: 28),
            healthTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            healthViewAllButton.centerYAnchor.constraint(equalTo: healthTitleLabel.centerYAnchor),
            healthViewAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            healthCardsStackView.topAnchor.constraint(equalTo: healthTitleLabel.bottomAnchor, constant: 16),
            healthCardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            healthCardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            upcomingVisitCard.topAnchor.constraint(equalTo: healthCardsStackView.bottomAnchor, constant: 24),
            upcomingVisitCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingVisitCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upcomingVisitCard.heightAnchor.constraint(equalToConstant: 190),
            upcomingVisitCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80),
            
            upcomingVisitTitleLabel.topAnchor.constraint(equalTo: upcomingVisitCard.topAnchor, constant: 22),
            upcomingVisitTitleLabel.leadingAnchor.constraint(equalTo: upcomingVisitCard.leadingAnchor, constant: 20),
            
            upcomingVisitBadge.centerYAnchor.constraint(equalTo: upcomingVisitTitleLabel.centerYAnchor),
            upcomingVisitBadge.trailingAnchor.constraint(equalTo: upcomingVisitCard.trailingAnchor, constant: -20),
            upcomingVisitBadge.widthAnchor.constraint(equalToConstant: 82),
            upcomingVisitBadge.heightAnchor.constraint(equalToConstant: 30),
            
            visitDateCircle.topAnchor.constraint(equalTo: upcomingVisitTitleLabel.bottomAnchor, constant: 20),
            visitDateCircle.leadingAnchor.constraint(equalTo: upcomingVisitCard.leadingAnchor, constant: 20),
            visitDateCircle.widthAnchor.constraint(equalToConstant: 76),
            visitDateCircle.heightAnchor.constraint(equalToConstant: 76),
            
            visitMonthLabel.topAnchor.constraint(equalTo: visitDateCircle.topAnchor, constant: 14),
            visitMonthLabel.centerXAnchor.constraint(equalTo: visitDateCircle.centerXAnchor),
            
            visitDayLabel.topAnchor.constraint(equalTo: visitMonthLabel.bottomAnchor, constant: 2),
            visitDayLabel.centerXAnchor.constraint(equalTo: visitDateCircle.centerXAnchor),
            
            visitTitleLabel.topAnchor.constraint(equalTo: visitDateCircle.topAnchor, constant: 6),
            visitTitleLabel.leadingAnchor.constraint(equalTo: visitDateCircle.trailingAnchor, constant: 18),
            visitTitleLabel.trailingAnchor.constraint(equalTo: upcomingVisitCard.trailingAnchor, constant: -20),
            
            visitSubtitleLabel.topAnchor.constraint(equalTo: visitTitleLabel.bottomAnchor, constant: 6),
            visitSubtitleLabel.leadingAnchor.constraint(equalTo: visitTitleLabel.leadingAnchor),
            visitSubtitleLabel.trailingAnchor.constraint(equalTo: visitTitleLabel.trailingAnchor),
            
            visitTimeBadge.topAnchor.constraint(equalTo: visitSubtitleLabel.bottomAnchor, constant: 18),
            visitTimeBadge.leadingAnchor.constraint(equalTo: visitTitleLabel.leadingAnchor),
            visitTimeBadge.widthAnchor.constraint(equalToConstant: 130),
            visitTimeBadge.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    override func configureViewModel() {

        viewModel.onPetLoaded = { [weak self] pet in
            self?.pet = pet
            self?.applyPet()
        }

        viewModel.onLoadingStateChanged = { isLoading in
            print("Loading:", isLoading)
        }

        viewModel.onError = { error in
            print(error)
        }

        viewModel.loadPet()

    }
    
    // MARK: - Apply
    
    private func applyPet() {
        nameLabel.text = pet.name
        
        if pet.isHighlighted == true {
            mainActionButton.setTitle("Main Pet", for: .normal)
            mainActionButton.setTitleColor(.white, for: .normal)
            mainActionButton.backgroundColor = .mainBlue
        } else {
            mainActionButton.setTitle("Set as Main", for: .normal)
            mainActionButton.setTitleColor(.mainBlue, for: .normal)
            mainActionButton.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        }
        
        let breed = pet.breed ?? "Unknown breed"
        let ageText = makeAgeText(from: pet.dob)
        subtitleLabel.text = "\(breed) • \(ageText)"
        
        if let photoUrl = pet.photoUrl,
           let url = URL(string: photoUrl) {
            petImageView.cancelImageLoad()
            petImageView.image = nil
            petImageView.setImage(from: url)
            petImageView.contentMode = .scaleAspectFill
            petImageView.clipsToBounds = true
            petImageView.tintColor = nil
            petImageView.backgroundColor = .clear
            avatarContainer.backgroundColor = .white
        } else {
            petImageView.cancelImageLoad()
            petImageView.image = UIImage(systemName: "pawprint.fill")
            petImageView.tintColor = .mainBlue
            petImageView.contentMode = .scaleAspectFit
            petImageView.clipsToBounds = true
            petImageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
            avatarContainer.backgroundColor = .white
        }
        
        weightCard.valueLabel.text = pet.weight != nil ? formattedWeight(pet.weight!) : "—"
        weightCard.unitLabel.text = pet.weight != nil ? "kg" : ""
        
        sexCard.valueLabel.text = pet.sex.capitalized
        sexCard.unitLabel.text = ""
        
        ageCard.valueLabel.text = makeShortAgeValue(from: pet.dob)
        ageCard.unitLabel.text = makeShortAgeUnit(from: pet.dob)
        
        growthSubtitleLabel.text = pet.species.uppercased() == "DOG" ? "Puppy Stage" : "Kitten Stage"
        growthWeekBadge.text = makeWeekBadgeText(from: pet.dob)
        progressCenterLabel.text = makeProgressText(from: pet.dob)
        growthDescriptionLabel.text = makeGrowthDescription(from: pet.dob)
    }
    
    // MARK: - Builders
    
    private func makeWhiteCard() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func makeSmallGrayLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeStatCard(title: String) -> (container: UIView, titleLabel: UILabel, valueLabel: UILabel, unitLabel: UILabel) {
        let container = makeWhiteCard()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .onboardingGray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .onboardingBlack
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let unitLabel = UILabel()
        unitLabel.font = .systemFont(ofSize: 14, weight: .medium)
        unitLabel.textColor = .onboardingGray
        unitLabel.textAlignment = .center
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.alignment = .lastBaseline
        valueStack.spacing = 4
        valueStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 98),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            valueStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            valueStack.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return (container, titleLabel, valueLabel, unitLabel)
    }
    
    private func makeOverviewCard(
        icon: String,
        iconBackground: UIColor,
        iconTint: UIColor,
        title: String,
        subtitle: String,
        badgeText: String,
        badgeTextColor: UIColor,
        badgeBackground: UIColor
    ) -> (container: UIView, badgeLabel: UILabel) {
        let container = makeWhiteCard()
        
        let iconWrap = UIView()
        iconWrap.backgroundColor = iconBackground
        iconWrap.layer.cornerRadius = 18
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconTint
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .onboardingBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .onboardingGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeLabel = UILabel()
        badgeLabel.text = badgeText
        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackground
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconWrap)
        iconWrap.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 178),
            
            iconWrap.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            iconWrap.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            iconWrap.widthAnchor.constraint(equalToConstant: 36),
            iconWrap.heightAnchor.constraint(equalToConstant: 36),
            
            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: iconWrap.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            badgeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 118),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return (container, badgeLabel)
    }
    
    // MARK: - Helpers
    
    private func formattedWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
    
    private func makeAgeText(from dob: String?) -> String {
        guard let date = parseDate(dob) else { return "Age unknown" }
        
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth], from: date, to: Date())
        
        if let years = components.year, years > 0 {
            return years == 1 ? "1 Year" : "\(years) Years"
        }
        
        if let months = components.month, months > 0 {
            return months == 1 ? "1 Month" : "\(months) Months"
        }
        
        let weeks = max(1, components.weekOfMonth ?? 1)
        return weeks == 1 ? "1 Week" : "\(weeks) Weeks"
    }
    
    private func makeShortAgeValue(from dob: String?) -> String {
        guard let date = parseDate(dob) else { return "—" }
        
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth], from: date, to: Date())
        
        if let years = components.year, years > 0 { return "\(years)" }
        if let months = components.month, months > 0 { return "\(months)" }
        
        return "\(max(1, components.weekOfMonth ?? 1))"
    }
    
    private func makeShortAgeUnit(from dob: String?) -> String {
        guard let date = parseDate(dob) else { return "" }
        
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth], from: date, to: Date())
        
        if let years = components.year, years > 0 {
            return years == 1 ? "yr" : "yrs"
        }
        
        if let months = components.month, months > 0 {
            return months == 1 ? "mo" : "mos"
        }
        
        let weeks = max(1, components.weekOfMonth ?? 1)
        return weeks == 1 ? "wk" : "wks"
    }
    
    private func makeWeekBadgeText(from dob: String?) -> String {
        guard let dob, let date = parseDate(dob) else { return "Week 1" }
        let weeks = max(1, Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 1)
        return "Week \(weeks)"
    }
    
    private func makeProgressText(from dob: String?) -> String {
        guard let dob, let date = parseDate(dob) else { return "10% Complete" }
        let weeks = max(1, Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 1)
        let percent = min(100, Int((Double(weeks) / 52.0) * 100.0))
        return "\(percent)% Complete"
    }
    
    private func makeGrowthDescription(from dob: String?) -> String {
        guard let dob, let date = parseDate(dob) else {
            return "Keep tracking development, health reminders and growth regularly."
        }
        
        let weeks = max(1, Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 1)
        
        if weeks < 12 {
            return "Early growth stage. Consistent feeding, checkups and weight tracking are important now."
        } else if weeks < 28 {
            return "Healthy progress so far. Keep tracking weight and reminders regularly."
        } else {
            return "Growth is becoming more stable. Focus on routine care, activity and preventive health."
        }
    }
    
    private func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: value) {
            return date
        }
        
        let isoFormatterWithoutFraction = ISO8601DateFormatter()
        isoFormatterWithoutFraction.formatOptions = [.withInternetDateTime]
        
        if let date = isoFormatterWithoutFraction.date(from: value) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: value) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: value)
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editTapped() {
        let vc = AddPetController(mode: .edit(pet))
        
        vc.onPetSaved = { [weak self] updatedPet in
            guard let self else { return }
            self.pet = updatedPet
            self.applyPet()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func mainActionTapped() {
        viewModel.setMainPet()
    }
}

