//
//  ReminderItemCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderItemCardView: UIView {
    
    var onToggleCompleted: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    
    private var isSwipedOpen = false
    private let openOffset: CGFloat = 88
    
    private var isExpanded = false
    private var currentItem: ReminderItemViewData?
    
    private let deleteTriggerOffset: CGFloat = 100
    private let maxSwipeOffset: CGFloat = 120
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deleteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deleteIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "trash.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryIconWrap: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleExpandedTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleCompletedTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        return gesture
    }()
    
    private var containerLeadingConstraint: NSLayoutConstraint!
    private var containerTrailingConstraint: NSLayoutConstraint!
    
    private var collapsedBottomConstraint: NSLayoutConstraint!
    private var expandedBottomConstraint: NSLayoutConstraint!
    private var editTrailingToExpandConstraint: NSLayoutConstraint!
    private var editTrailingToCheckConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(deleteBackgroundView)
        deleteBackgroundView.addSubview(deleteIconView)
        addSubview(containerView)
        
        addGestureRecognizer(panGesture)
        containerView.addGestureRecognizer(tapGesture)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(metaLabel)
        containerView.addSubview(notesLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(expandButton)
        containerView.addSubview(checkButton)
        containerView.addSubview(categoryIconWrap)
        categoryIconWrap.addSubview(categoryIconView)
        
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(handleDeleteTap))
        deleteTap.cancelsTouchesInView = false
        deleteBackgroundView.addGestureRecognizer(deleteTap)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            deleteBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            deleteBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            deleteBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteIconView.centerYAnchor.constraint(equalTo: deleteBackgroundView.centerYAnchor),
            deleteIconView.trailingAnchor.constraint(equalTo: deleteBackgroundView.trailingAnchor, constant: -28),
            deleteIconView.widthAnchor.constraint(equalToConstant: 22),
            deleteIconView.heightAnchor.constraint(equalToConstant: 22),
            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            editButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            editButton.widthAnchor.constraint(equalToConstant: 22),
            editButton.heightAnchor.constraint(equalToConstant: 22),
            
            expandButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            expandButton.trailingAnchor.constraint(equalTo: checkButton.leadingAnchor, constant: -12),
            expandButton.widthAnchor.constraint(equalToConstant: 22),
            expandButton.heightAnchor.constraint(equalToConstant: 22),
            
            checkButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            checkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            checkButton.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: categoryIconWrap.leadingAnchor, constant: -18),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            metaLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            notesLabel.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 14),
            notesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            notesLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            categoryIconWrap.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 20),
            categoryIconWrap.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            categoryIconWrap.widthAnchor.constraint(equalToConstant: 44),
            categoryIconWrap.heightAnchor.constraint(equalToConstant: 44),
            
            categoryIconView.centerXAnchor.constraint(equalTo: categoryIconWrap.centerXAnchor),
            categoryIconView.centerYAnchor.constraint(equalTo: categoryIconWrap.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 20),
            categoryIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        containerLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        containerTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        containerLeadingConstraint.isActive = true
        containerTrailingConstraint.isActive = true
        
        collapsedBottomConstraint = metaLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -28)
        expandedBottomConstraint = notesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22)
        collapsedBottomConstraint.isActive = true
        
        editTrailingToExpandConstraint = editButton.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -12)
        editTrailingToCheckConstraint = editButton.trailingAnchor.constraint(equalTo: checkButton.leadingAnchor, constant: -12)
        editTrailingToExpandConstraint.isActive = true
    }
    
    func configure(with item: ReminderItemViewData) {
        currentItem = item
        
        titleLabel.text = item.title
        dateLabel.text = item.subtitle
        metaLabel.text = "\(item.petName) • \(item.category.title)"
        notesLabel.text = item.notes
        
        let hasNotes = !(item.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        expandButton.isHidden = !hasNotes
        
        editTrailingToExpandConstraint.isActive = hasNotes
        editTrailingToCheckConstraint.isActive = !hasNotes
        
        if !hasNotes {
            isExpanded = false
        }
        
        let checkImageName = item.isCompleted ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: checkImageName), for: .normal)
        checkButton.tintColor = item.isCompleted ? .systemGreen : .mainBlue
        
        let expandImageName = isExpanded ? "chevron.up" : "chevron.down"
        expandButton.setImage(UIImage(systemName: expandImageName), for: .normal)
        
        configureCategoryStyle(item.category)
        configureDateStyle(item.status)
        configureCompletedStyle(item.isCompleted)
        configureExpandedState()
        configureResetSwipePosition(animated: false)
        isSwipedOpen = false
    }
    
    private func configureCategoryStyle(_ category: ReminderCategory) {
        categoryIconWrap.backgroundColor = category.color.withAlphaComponent(0.10)
        categoryIconView.image = UIImage(systemName: category.icon)
        categoryIconView.tintColor = category.color
    }
    
    private func configureDateStyle(_ status: ReminderStatus) {
        switch status {
        case .overdue:
            dateLabel.textColor = .systemRed
        case .upcoming:
            dateLabel.textColor = .mainBlue
        case .completed:
            dateLabel.textColor = .systemGray
        }
    }
    
    private func configureCompletedStyle(_ isCompleted: Bool) {
        titleLabel.alpha = isCompleted ? 0.7 : 1.0
        dateLabel.alpha = isCompleted ? 0.85 : 1.0
        metaLabel.alpha = isCompleted ? 0.75 : 1.0
        categoryIconWrap.alpha = isCompleted ? 0.75 : 1.0
        notesLabel.alpha = isCompleted ? 0.75 : 1.0
    }
    
    private func configureExpandedState() {
        let hasNotes = !(currentItem?.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let shouldExpand = isExpanded && hasNotes
        
        notesLabel.isHidden = !shouldExpand
        collapsedBottomConstraint.isActive = !shouldExpand
        expandedBottomConstraint.isActive = shouldExpand
        
        let imageName = shouldExpand ? "chevron.up" : "chevron.down"
        expandButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        UIView.performWithoutAnimation {
            self.superview?.superview?.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    private func configureSwipeOffset(_ offset: CGFloat, animated: Bool) {
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
    
    @objc private func toggleCompletedTapped() {
        UIView.animate(withDuration: 0.18, animations: {
            self.transform = CGAffineTransform(scaleX: 0.985, y: 0.985)
        }) { _ in
            UIView.animate(withDuration: 0.18) {
                self.transform = .identity
            }
        }
        
        onToggleCompleted?()
    }
    
    @objc private func toggleExpandedTapped() {
        isExpanded.toggle()
        configureExpandedState()
    }
    
    @objc private func editTapped() {
        onEditTapped?()
    }
    
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
    
    @objc private func handleCardTap() {
        if isSwipedOpen {
            configureCloseSwipe()
            return
        }
        
        let hasNotes = !(currentItem?.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        guard hasNotes else { return }
        
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.2) {
            self.configureExpandedState()
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    @objc private func handleDeleteTap() {
        onDeleteTapped?()
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

extension ReminderItemCardView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        }
        
        return false
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if touch.view is UIButton {
            return false
        }
        
        return true
    }
}
