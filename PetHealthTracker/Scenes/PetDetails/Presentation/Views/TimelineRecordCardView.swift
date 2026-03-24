//
//  TimelineRecordCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

//
//  TimelineRecordCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class TimelineRecordCardView: UIView {
    
    // MARK: - Callbacks
    
    var onActionTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    // MARK: - Swipe
    
    private var isSwipedOpen = false
    private let openOffset: CGFloat = 88
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    }()
    
    private var containerLeadingConstraint: NSLayoutConstraint!
    private var containerTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - UI
    
    private let deleteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let deleteIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "trash.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let containerView = UIView()
    
    private let markerCircle = UIView()
    private let markerIconView = UIImageView()
    private let lineView = UIView()
    private let cardView = UIView()
    
    private let topRowStack = UIStackView()
    private let statusLabel = PaddingLabel()
    private let dueLabel = UILabel()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let doseLabel = UILabel()
    
    private let actionsStack = UIStackView()
    private let actionButton = UIButton(type: .system)
    private let dotLabel = UILabel()
    private let detailsButton = UIButton(type: .system)
    
    private let detailsContainerView = UIView()
    private let detailsTitleLabel = UILabel()
    private let detailsLabel = UILabel()
    
    private let contentStack = UIStackView()
    
    // MARK: - State
    
    private var detailsText: String?
    private var isExpanded = false
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(deleteBackgroundView)
        deleteBackgroundView.addSubview(deleteIconView)
        addSubview(containerView)
        
        addGestureRecognizer(panGesture)
        
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(handleDeleteTap))
        deleteBackgroundView.addGestureRecognizer(deleteTap)
        
        markerCircle.backgroundColor = .white
        markerCircle.layer.cornerRadius = 18
        markerCircle.layer.borderWidth = 2
        
        markerIconView.preferredSymbolConfiguration = .init(pointSize: 16, weight: .bold)
        
        lineView.backgroundColor = UIColor.systemGray5
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.025
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        topRowStack.axis = .horizontal
        topRowStack.alignment = .center
        topRowStack.spacing = 10
        
        statusLabel.font = .systemFont(ofSize: 11, weight: .bold)
        statusLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        statusLabel.layer.cornerRadius = 11
        statusLabel.clipsToBounds = true
        
        dueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dueLabel.textColor = .onboardingGray
        dueLabel.textAlignment = .right
        dueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .onboardingBlack
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .onboardingGray
        subtitleLabel.numberOfLines = 0
        
        doseLabel.font = .systemFont(ofSize: 12, weight: .bold)
        doseLabel.textColor = .systemPurple
        
        actionsStack.axis = .horizontal
        actionsStack.alignment = .center
        actionsStack.spacing = 8
        actionsStack.distribution = .fill
        
        setupActionButton(actionButton)
        setupActionButton(detailsButton)
        
        dotLabel.text = "•"
        dotLabel.font = .systemFont(ofSize: 14, weight: .bold)
        dotLabel.textColor = .systemGray3
        dotLabel.isHidden = true
        
        detailsContainerView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.75)
        detailsContainerView.layer.cornerRadius = 14
        detailsContainerView.isHidden = true
        
        detailsTitleLabel.text = "Notes"
        detailsTitleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        detailsTitleLabel.textColor = .onboardingBlack
        
        detailsLabel.font = .systemFont(ofSize: 13, weight: .medium)
        detailsLabel.textColor = .onboardingGray
        detailsLabel.numberOfLines = 0
        
        contentStack.axis = .vertical
        contentStack.spacing = 10
        
        containerView.addSubview(lineView)
        containerView.addSubview(markerCircle)
        markerCircle.addSubview(markerIconView)
        containerView.addSubview(cardView)
        
        cardView.addSubview(topRowStack)
        cardView.addSubview(contentStack)
        
        topRowStack.addArrangedSubview(statusLabel)
        topRowStack.addArrangedSubview(UIView())
        topRowStack.addArrangedSubview(dueLabel)
        
        [titleLabel, subtitleLabel, doseLabel, actionsStack, detailsContainerView].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        actionsStack.addArrangedSubview(actionButton)
        actionsStack.addArrangedSubview(dotLabel)
        actionsStack.addArrangedSubview(detailsButton)
        actionsStack.addArrangedSubview(UIView())
        
        detailsContainerView.addSubview(detailsTitleLabel)
        detailsContainerView.addSubview(detailsLabel)
        
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.addGestureRecognizer(tapGesture)
    }
    
    private func setupActionButton(_ button: UIButton) {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.titleAlignment = .leading
        
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentHorizontalAlignment = .leading
    }
    
    private func setupConstraints() {
        [
            deleteBackgroundView,
            deleteIconView,
            containerView,
            markerCircle,
            markerIconView,
            lineView,
            cardView,
            topRowStack,
            contentStack,
            detailsTitleLabel,
            detailsLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            deleteBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            deleteBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52),
            deleteBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteIconView.centerYAnchor.constraint(equalTo: deleteBackgroundView.centerYAnchor),
            deleteIconView.trailingAnchor.constraint(equalTo: deleteBackgroundView.trailingAnchor, constant: -28),
            deleteIconView.widthAnchor.constraint(equalToConstant: 22),
            deleteIconView.heightAnchor.constraint(equalToConstant: 22),

            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            markerCircle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            markerCircle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            markerCircle.widthAnchor.constraint(equalToConstant: 36),
            markerCircle.heightAnchor.constraint(equalToConstant: 36),

            markerIconView.centerXAnchor.constraint(equalTo: markerCircle.centerXAnchor),
            markerIconView.centerYAnchor.constraint(equalTo: markerCircle.centerYAnchor),

            lineView.topAnchor.constraint(equalTo: markerCircle.bottomAnchor, constant: 4),
            lineView.centerXAnchor.constraint(equalTo: markerCircle.centerXAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 2),
            lineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            cardView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: markerCircle.trailingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            topRowStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            topRowStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            topRowStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            contentStack.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            detailsTitleLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 10),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 12),
            detailsTitleLabel.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -12),

            detailsLabel.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 5),
            detailsLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 12),
            detailsLabel.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -12),
            detailsLabel.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -10)
        ])
        
        containerLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        containerTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        containerLeadingConstraint.isActive = true
        containerTrailingConstraint.isActive = true
    }
    
    // MARK: - Configure
    
    func configure(with item: TimelineRecordItemViewData) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        dueLabel.text = item.dueText
        
        detailsText = item.detailsText
        isExpanded = false
        
        subtitleLabel.isHidden = item.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        doseLabel.isHidden = true
        actionsStack.isHidden = true
        actionButton.isHidden = true
        detailsButton.isHidden = true
        dotLabel.isHidden = true
        detailsContainerView.isHidden = true
        detailsLabel.text = nil
        
        if let dose = item.doseText, !dose.isEmpty {
            doseLabel.isHidden = false
            doseLabel.text = dose
        }
        
        if let action = item.actionTitle, !action.isEmpty {
            actionButton.isHidden = false
            var config = actionButton.configuration
            config?.title = action
            actionButton.configuration = config
        }
        
        if let details = item.detailsText, !details.isEmpty {
            detailsButton.isHidden = false
            detailsLabel.text = details
            updateDetailsButtonTitle()
        }
        
        dotLabel.isHidden = actionButton.isHidden || detailsButton.isHidden
        actionsStack.isHidden = actionButton.isHidden && detailsButton.isHidden
        
        applyStatusStyle(item.status)
        resetSwipePosition(animated: false)
        isSwipedOpen = false
    }
    
    private func updateDetailsButtonTitle() {
        var config = detailsButton.configuration
        config?.title = isExpanded ? "Hide Details" : "View Details"
        detailsButton.configuration = config
    }
    
    private func applyStatusStyle(_ status: HealthRecordStatus) {
        switch status {
        case .overdue:
            markerCircle.layer.borderColor = UIColor.systemRed.cgColor
            markerIconView.image = UIImage(systemName: "exclamationmark")
            markerIconView.tintColor = .systemRed
            
            statusLabel.text = "Overdue"
            statusLabel.textColor = .systemRed
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.10)
            
            actionButton.setTitleColor(.systemRed, for: .normal)
            detailsButton.setTitleColor(.systemBlue, for: .normal)
            
        case .upcoming:
            markerCircle.layer.borderColor = UIColor.systemPurple.cgColor
            markerIconView.image = UIImage(systemName: "calendar")
            markerIconView.tintColor = .systemPurple
            
            statusLabel.text = "Upcoming"
            statusLabel.textColor = .systemPurple
            statusLabel.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.10)
            
            actionButton.setTitleColor(.systemPurple, for: .normal)
            detailsButton.setTitleColor(.systemBlue, for: .normal)
            
        case .completed:
            markerCircle.layer.borderColor = UIColor.systemBlue.cgColor
            markerIconView.image = UIImage(systemName: "checkmark")
            markerIconView.tintColor = .systemBlue
            
            statusLabel.text = "Completed"
            statusLabel.textColor = .systemBlue
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
            
            actionButton.setTitleColor(.systemBlue, for: .normal)
            detailsButton.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    // MARK: - Swipe
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .changed:
            let offset = max(-openOffset, min(0, translation.x + (isSwipedOpen ? -openOffset : 0)))
            updateSwipeOffset(offset, animated: false)
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self).x
            
            if isSwipedOpen {
                if translation.x > 30 || velocity > 300 {
                    closeSwipe()
                } else {
                    openSwipe()
                }
            } else {
                if translation.x < -40 || velocity < -300 {
                    openSwipe()
                } else {
                    closeSwipe()
                }
            }
            
        default:
            break
        }
    }
    
    private func updateSwipeOffset(_ offset: CGFloat, animated: Bool) {
        containerLeadingConstraint.constant = offset
        containerTrailingConstraint.constant = offset
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    self.layoutIfNeeded()
                }
            )
        } else {
            layoutIfNeeded()
        }
    }
    
    private func openSwipe() {
        isSwipedOpen = true
        updateSwipeOffset(-openOffset, animated: true)
    }
    
    private func closeSwipe() {
        isSwipedOpen = false
        updateSwipeOffset(0, animated: true)
    }
    
    private func resetSwipePosition(animated: Bool) {
        containerLeadingConstraint.constant = 0
        containerTrailingConstraint.constant = 0
        
        if animated {
            UIView.animate(withDuration: 0.22) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc private func actionTapped() {
        if isSwipedOpen {
            closeSwipe()
            return
        }
        onActionTapped?()
    }
    
    @objc private func detailsTapped() {
        if isSwipedOpen {
            closeSwipe()
            return
        }
        
        guard let detailsText, !detailsText.isEmpty else { return }
        
        isExpanded.toggle()
        detailsContainerView.isHidden = !isExpanded
        updateDetailsButtonTitle()
        
        UIView.animate(withDuration: 0.22) {
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc private func handleDeleteTap() {
        onDeleteTapped?()
    }
    
    @objc private func handleCardTap() {
        if isSwipedOpen {
            closeSwipe()
        }
    }
}
