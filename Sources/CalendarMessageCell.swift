//
//  CalendarMessageCell.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import UIKit

/// Delegate for CalendarMessageCell RSVP interactions.
/// Implemented by GroupChatViewController which has access to Firebase and Kingfisher.
public protocol CalendarMessageCellDelegate: AnyObject {
    /// Called when the "Going" button is tapped
    func calendarCell(_ cell: CalendarMessageCell, didTapGoingForEventId eventId: String)
    /// Called when the "Not Going" button is tapped
    func calendarCell(_ cell: CalendarMessageCell, didTapNotGoingForEventId eventId: String)
    /// Called when the cell needs Firebase listeners attached for this event
    func calendarCell(_ cell: CalendarMessageCell, attachListenersForEventId eventId: String)
    /// Called when the cell is being reused — detach Firebase listeners
    func calendarCellWillReuse(_ cell: CalendarMessageCell)
}

/// A subclass of `MessageContentCell` used to display calendar messages.
open class CalendarMessageCell: MessageContentCell {
    
    // MARK: - Delegate
    
    public weak var calendarDelegate: CalendarMessageCellDelegate?
    
    // MARK: - State
    
    /// The current event ID this cell is displaying
    public var currentEventId: String?
    
    // MARK: - UI Elements
    
    /// Event title label
    public lazy var eventTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    /// Date icon
    public lazy var dateIconLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "📅"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// Event date label
    public lazy var eventDateLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    /// Time icon
    public lazy var timeIconLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "🕐"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// Event time label
    public lazy var eventTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    /// Location icon
    public lazy var locationIconLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "📍"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// Event venue label
    public lazy var eventVenueLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Separator
    
    public lazy var separatorView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        return view
    }()
    
    // MARK: - RSVP Section
    
    /// Separator between event details and RSVP section
    public lazy var rsvpSeparatorView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        return view
    }()
    
    /// "Going" button
    public lazy var goingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Going", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1.5
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        button.addTarget(self, action: #selector(goingTapped), for: .touchUpInside)
        return button
    }()
    
    /// "Not Going" button
    public lazy var notGoingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Not Going", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1.5
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        button.addTarget(self, action: #selector(notGoingTapped), for: .touchUpInside)
        return button
    }()
    
    /// Container for the two RSVP buttons
    public lazy var rsvpButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [goingButton, notGoingButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Going Section
    
    public lazy var goingSectionView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    public lazy var goingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
        return label
    }()
    
    public lazy var goingAvatarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Not Going Section
    
    public lazy var notGoingSectionView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    public lazy var notGoingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)
        return label
    }()
    
    public lazy var notGoingAvatarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Setup
    
    open func setupConstraints() {
        let padding: CGFloat = 12
        let iconSize: CGFloat = 20
        let rowSpacing: CGFloat = 8
        
        // Title
        eventTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventTitleLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: padding),
            eventTitleLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            eventTitleLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        // Separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: eventTitleLabel.bottomAnchor, constant: rowSpacing),
            separatorView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            separatorView.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Date row
        dateIconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateIconLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: rowSpacing),
            dateIconLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            dateIconLabel.widthAnchor.constraint(equalToConstant: iconSize),
            dateIconLabel.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        eventDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventDateLabel.centerYAnchor.constraint(equalTo: dateIconLabel.centerYAnchor),
            eventDateLabel.leftAnchor.constraint(equalTo: dateIconLabel.rightAnchor, constant: 6),
            eventDateLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        // Time row
        timeIconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeIconLabel.topAnchor.constraint(equalTo: dateIconLabel.bottomAnchor, constant: rowSpacing),
            timeIconLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            timeIconLabel.widthAnchor.constraint(equalToConstant: iconSize),
            timeIconLabel.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        eventTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventTimeLabel.centerYAnchor.constraint(equalTo: timeIconLabel.centerYAnchor),
            eventTimeLabel.leftAnchor.constraint(equalTo: timeIconLabel.rightAnchor, constant: 6),
            eventTimeLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        // Location row
        locationIconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationIconLabel.topAnchor.constraint(equalTo: timeIconLabel.bottomAnchor, constant: rowSpacing),
            locationIconLabel.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            locationIconLabel.widthAnchor.constraint(equalToConstant: iconSize),
            locationIconLabel.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        eventVenueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventVenueLabel.centerYAnchor.constraint(equalTo: locationIconLabel.centerYAnchor),
            eventVenueLabel.leftAnchor.constraint(equalTo: locationIconLabel.rightAnchor, constant: 6),
            eventVenueLabel.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        // RSVP Separator
        rsvpSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rsvpSeparatorView.topAnchor.constraint(equalTo: locationIconLabel.bottomAnchor, constant: rowSpacing + 4),
            rsvpSeparatorView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            rsvpSeparatorView.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding),
            rsvpSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // RSVP Buttons
        rsvpButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rsvpButtonsStack.topAnchor.constraint(equalTo: rsvpSeparatorView.bottomAnchor, constant: rowSpacing),
            rsvpButtonsStack.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            rsvpButtonsStack.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding),
            rsvpButtonsStack.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        // Going section
        goingSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goingSectionView.topAnchor.constraint(equalTo: rsvpButtonsStack.bottomAnchor, constant: rowSpacing),
            goingSectionView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            goingSectionView.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        goingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        goingAvatarsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goingCountLabel.topAnchor.constraint(equalTo: goingSectionView.topAnchor),
            goingCountLabel.leftAnchor.constraint(equalTo: goingSectionView.leftAnchor),
            goingCountLabel.rightAnchor.constraint(equalTo: goingSectionView.rightAnchor),
            
            goingAvatarsStack.topAnchor.constraint(equalTo: goingCountLabel.bottomAnchor, constant: 4),
            goingAvatarsStack.leftAnchor.constraint(equalTo: goingSectionView.leftAnchor),
            goingAvatarsStack.bottomAnchor.constraint(equalTo: goingSectionView.bottomAnchor),
            goingAvatarsStack.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Not Going section
        notGoingSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notGoingSectionView.topAnchor.constraint(equalTo: goingSectionView.bottomAnchor, constant: 4),
            notGoingSectionView.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: padding),
            notGoingSectionView.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -padding)
        ])
        
        notGoingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        notGoingAvatarsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notGoingCountLabel.topAnchor.constraint(equalTo: notGoingSectionView.topAnchor),
            notGoingCountLabel.leftAnchor.constraint(equalTo: notGoingSectionView.leftAnchor),
            notGoingCountLabel.rightAnchor.constraint(equalTo: notGoingSectionView.rightAnchor),
            
            notGoingAvatarsStack.topAnchor.constraint(equalTo: notGoingCountLabel.bottomAnchor, constant: 4),
            notGoingAvatarsStack.leftAnchor.constraint(equalTo: notGoingSectionView.leftAnchor),
            notGoingAvatarsStack.bottomAnchor.constraint(equalTo: notGoingSectionView.bottomAnchor),
            notGoingAvatarsStack.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubview(eventTitleLabel)
        messageContainerView.addSubview(separatorView)
        messageContainerView.addSubview(dateIconLabel)
        messageContainerView.addSubview(eventDateLabel)
        messageContainerView.addSubview(timeIconLabel)
        messageContainerView.addSubview(eventTimeLabel)
        messageContainerView.addSubview(locationIconLabel)
        messageContainerView.addSubview(eventVenueLabel)
        
        // RSVP section
        messageContainerView.addSubview(rsvpSeparatorView)
        messageContainerView.addSubview(rsvpButtonsStack)
        
        // Going section
        goingSectionView.addSubview(goingCountLabel)
        goingSectionView.addSubview(goingAvatarsStack)
        messageContainerView.addSubview(goingSectionView)
        
        // Not Going section
        notGoingSectionView.addSubview(notGoingCountLabel)
        notGoingSectionView.addSubview(notGoingAvatarsStack)
        messageContainerView.addSubview(notGoingSectionView)
        
        setupConstraints()
        
        // Set initial button states
        updateGoingButtonState(isSelected: false)
        updateNotGoingButtonState(isSelected: false)
    }
    
    // MARK: - Prepare For Reuse
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // Tell delegate to detach Firebase listeners for this cell
        calendarDelegate?.calendarCellWillReuse(self)
        
        // Reset UI
        currentEventId = nil
        goingSectionView.isHidden = true
        notGoingSectionView.isHidden = true
        clearAvatarStack(goingAvatarsStack)
        clearAvatarStack(notGoingAvatarsStack)
        updateGoingButtonState(isSelected: false)
        updateNotGoingButtonState(isSelected: false)
    }
    
    // MARK: - Configure Cell
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        guard case let .calendar(calendarItem) = message.kind else { return }
        eventTitleLabel.text = calendarItem.calendarEventTitle
        eventDateLabel.text = calendarItem.calendarEventDate
        eventTimeLabel.text = "\(calendarItem.calendarEventStartTime) – \(calendarItem.calendarEventEndTime)"
        eventVenueLabel.text = calendarItem.calendarEventVenue
        
        // Store eventId and ask delegate to attach Firebase listeners
        let eventId = calendarItem.calendarEventId
        currentEventId = eventId
        
        displayDelegate.configureCalendarCell(self, message: message)
        
        // After delegate is set via configureCalendarCell, ask it to attach listeners
        if !eventId.isEmpty {
            calendarDelegate?.calendarCell(self, attachListenersForEventId: eventId)
        }
    }
    
    // MARK: - Touch Handling
    
    /// Override MessageKit's tap gesture handler to intercept taps on RSVP buttons.
    /// The gesture recognizer consumes touches before UIButton can process them,
    /// so we check the hit area and invoke button actions manually.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: messageContainerView)
        
        let goingFrame = goingButton.convert(goingButton.bounds, to: messageContainerView)
        let notGoingFrame = notGoingButton.convert(notGoingButton.bounds, to: messageContainerView)
        
        if goingFrame.contains(touchLocation) {
            goingTapped()
            return
        }
        if notGoingFrame.contains(touchLocation) {
            notGoingTapped()
            return
        }
        
        // Not on a button — let MessageKit handle normally (fires didTapMessage, etc.)
        super.handleTapGesture(gesture)
    }
    
    // MARK: - RSVP Button Actions
    
    @objc private func goingTapped() {
        guard let eventId = currentEventId else { return }
        calendarDelegate?.calendarCell(self, didTapGoingForEventId: eventId)
    }
    
    @objc private func notGoingTapped() {
        guard let eventId = currentEventId else { return }
        calendarDelegate?.calendarCell(self, didTapNotGoingForEventId: eventId)
    }
    
    // MARK: - Public Update Methods (called by delegate/VC)
    
    /// Update the Going button state
    public func updateGoingButtonState(isSelected: Bool) {
        let green = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
        if isSelected {
            goingButton.backgroundColor = green
            goingButton.setTitleColor(.white, for: .normal)
            goingButton.layer.borderColor = green.cgColor
        } else {
            goingButton.backgroundColor = .clear
            goingButton.setTitleColor(green, for: .normal)
            goingButton.layer.borderColor = green.cgColor
        }
    }
    
    /// Update the Not Going button state
    public func updateNotGoingButtonState(isSelected: Bool) {
        let red = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)
        if isSelected {
            notGoingButton.backgroundColor = red
            notGoingButton.setTitleColor(.white, for: .normal)
            notGoingButton.layer.borderColor = red.cgColor
        } else {
            notGoingButton.backgroundColor = .clear
            notGoingButton.setTitleColor(red, for: .normal)
            notGoingButton.layer.borderColor = red.cgColor
        }
    }
    
    /// Update going section with count and avatar images
    public func updateGoingSection(count: Int, avatarImages: [UIImage]) {
        if count > 0 {
            goingSectionView.isHidden = false
            goingCountLabel.text = "Going (\(count))"
            clearAvatarStack(goingAvatarsStack)
            for image in avatarImages {
                addAvatarImageView(to: goingAvatarsStack, image: image)
            }
        } else {
            goingSectionView.isHidden = true
            clearAvatarStack(goingAvatarsStack)
        }
    }
    
    /// Update not going section with count and avatar images
    public func updateNotGoingSection(count: Int, avatarImages: [UIImage]) {
        if count > 0 {
            notGoingSectionView.isHidden = false
            notGoingCountLabel.text = "Not Going (\(count))"
            clearAvatarStack(notGoingAvatarsStack)
            for image in avatarImages {
                addAvatarImageView(to: notGoingAvatarsStack, image: image)
            }
        } else {
            notGoingSectionView.isHidden = true
            clearAvatarStack(notGoingAvatarsStack)
        }
    }
    
    /// Convenience: add a single avatar UIImageView to a stack (called from VC as images load)
    public func addGoingAvatar(image: UIImage) {
        goingSectionView.isHidden = false
        addAvatarImageView(to: goingAvatarsStack, image: image)
    }
    
    public func addNotGoingAvatar(image: UIImage) {
        notGoingSectionView.isHidden = false
        addAvatarImageView(to: notGoingAvatarsStack, image: image)
    }
    
    // MARK: - Private Helpers
    
    private func addAvatarImageView(to container: UIStackView, image: UIImage) {
        let avatarSize: CGFloat = 24
        let avatarView = UIImageView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        avatarView.layer.cornerRadius = avatarSize / 2
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        avatarView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        avatarView.image = image
        container.addArrangedSubview(avatarView)
    }
    
    private func clearAvatarStack(_ stack: UIStackView) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
