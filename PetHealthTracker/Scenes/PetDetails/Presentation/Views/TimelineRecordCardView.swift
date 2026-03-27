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
    
    // MARK: - State
    
    private var isSwipedOpen = false
    private var isExpanded = false
    private var detailsText: String?
    
    private let openOffset: CGFloat = 88
    
    private var containerLeadingConstraint: NSLayoutConstraint!
    private var containerTrailingConstraint: NSLayoutConstraint!
    private var dueLabelLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - UI
    
    private lazy var deleteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deleteIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "trash.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var markerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var markerIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.preferredSymbolConfiguration = .init(pointSize: 16, weight: .bold)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.025
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statusLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            actionButton,
            dotLabel,
            detailsButton
        ])
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.titleAlignment = .leading
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dotLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemGray3
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailsButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.titleAlignment = .leading
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var detailsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.75)
        view.layer.cornerRadius = 14
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var detailsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            doseLabel,
            actionsStack,
            detailsContainerView
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var cardTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var deleteTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDeleteTap))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(deleteBackgroundView)
        deleteBackgroundView.addSubview(deleteIconView)
        
        addSubview(containerView)
        containerView.addSubview(lineView)
        containerView.addSubview(markerCircle)
        markerCircle.addSubview(markerIconView)
        containerView.addSubview(cardView)
        
        cardView.addSubview(statusLabel)
        cardView.addSubview(dueLabel)
        cardView.addSubview(contentStack)
        
        detailsContainerView.addSubview(detailsTitleLabel)
        detailsContainerView.addSubview(detailsLabel)
        
        addGestureRecognizer(panGesture)
        cardView.addGestureRecognizer(cardTapGesture)
        deleteBackgroundView.addGestureRecognizer(deleteTapGesture)
    }
    
    // MARK: - Configure Constraints
    
    private func configureConstraints() {
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
            
            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            dueLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            dueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
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
        
        dueLabelLeadingConstraint = dueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: statusLabel.trailingAnchor, constant: 12)
        dueLabelLeadingConstraint.isActive = true
        
        containerLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        containerTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        containerLeadingConstraint.isActive = true
        containerTrailingConstraint.isActive = true
    }
    
    // MARK: - Configure Data
    
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
            configureDetailsButtonTitle()
        }
        
        dotLabel.isHidden = actionButton.isHidden || detailsButton.isHidden
        actionsStack.isHidden = actionButton.isHidden && detailsButton.isHidden
        
        configureStatusStyle(item.status)
        configureResetSwipePosition(animated: false)
        isSwipedOpen = false
    }
    
    private func configureDetailsButtonTitle() {
        var config = detailsButton.configuration
        config?.title = isExpanded ? "Hide Details" : "View Details"
        detailsButton.configuration = config
    }
    
    private func configureStatusStyle(_ status: HealthRecordStatus) {
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
            configureSwipeOffset(offset, animated: false)
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self).x
            
            if isSwipedOpen {
                if translation.x > 30 || velocity > 300 {
                    configureCloseSwipe()
                } else {
                    configureOpenSwipe()
                }
            } else {
                if translation.x < -40 || velocity < -300 {
                    configureOpenSwipe()
                } else {
                    configureCloseSwipe()
                }
            }
            
        default:
            break
        }
    }
    
    private func configureSwipeOffset(_ offset: CGFloat, animated: Bool) {
        containerLeadingConstraint.constant = offset
        containerTrailingConstraint.constant = offset
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseOut]
            ) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    private func configureOpenSwipe() {
        isSwipedOpen = true
        configureSwipeOffset(-openOffset, animated: true)
    }
    
    private func configureCloseSwipe() {
        isSwipedOpen = false
        configureSwipeOffset(0, animated: true)
    }
    
    private func configureResetSwipePosition(animated: Bool) {
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
            configureCloseSwipe()
            return
        }
        onActionTapped?()
    }
    
    @objc private func detailsTapped() {
        if isSwipedOpen {
            configureCloseSwipe()
            return
        }
        
        guard let detailsText, !detailsText.isEmpty else { return }
        
        isExpanded.toggle()
        detailsContainerView.isHidden = !isExpanded
        configureDetailsButtonTitle()
        
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
            configureCloseSwipe()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGesture,
           let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        }
        
        return true
    }
    
}

extension TimelineRecordCardView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
